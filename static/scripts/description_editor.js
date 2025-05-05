async function sendDescriptionToServer(quill, endpoint) {
	const json_content = JSON.stringify(quill.getContents())
	const json_length = json_content.length
	const json_length_limit = 4096

	if (json_length > json_length_limit) {
		return [false, `Too many characters! ${json_length}/${json_length_limit}`]
	}

	const headers = new Headers()
	headers.append("Content-Type", "application/json")

	const req = new Request(endpoint, {
		method: "POST",
		headers: headers,
		body: json_content,
	})

	try {
		const res = await fetch(req)
		return [res.ok, res.ok ? "Description updated!" : res.status]
	}
	catch(e) {
		return [false, e]
	}
}

function updateStatus(status_label, text) {
	if (status_label === null) {
		return
	}
	status_label.innerText = text
}

function addQuillToElement(editor_container, save_button, status_label, endpoint, post_endpoint, content, edit_mode) {
	if (editor_container === null) {
		return
	}

	const toolbar = [
		["bold", "italic", "underline", "strike"],
		[{ 'header': 1 }, { 'header': 2 }],
		["blockquote", "code-block"],
		[{ "font": [] }],
		[{ "align": [] }],
		["clean"],
		["image"],
		["video"]
	]

	// If you click on the image button in the default Quill toolbar, it will ask you to select a file from you PC.
	// This will add the image into the JSON, an entire png or jpg
	// We don't want people to store their images in our DB,
	// so we ask them to add a URL.
	function imageHandler() {
		var range = this.quill.getSelection();
		var value = prompt("Insert image URL here");
		if (value) {
			this.quill.insertEmbed(range.index, 'image', value, Quill.sources.USER);
		}
	}

	const editor_params = {
		modules: {
			toolbar: {
				container: toolbar,
				handlers: {
					image: imageHandler
				}
			},
			history: true
		},
		readOnly: !edit_mode,
		theme: "snow",
		placeholder: "I am good at..."
	}

	if (!edit_mode) {
		editor_params.modules.toolbar = false
		editor_params.modules.history = false
		editor_params.placeholder = false
	}

	while (editor_container.firstChild) { // Removing previously created editor
		editor_container.removeChild(editor_container.lastChild)
	}

	const editor = document.createElement("div")
	editor_container.appendChild(editor)

	const quill = new Quill(editor, editor_params)

	if (content == "") {
		content = "{}"
	}

	quill.setContents(JSON.parse(content))

	var can_upload = true

	const on_click = function() {
		if (!can_upload) {
			return
		}

		can_upload = false
		updateStatus(status_label, "Saving...")

		sendDescriptionToServer(quill, post_endpoint).then(function([success, err]) {
			updateStatus(status_label, err)
			can_upload = true

			setTimeout(function() {
				updateStatus(status_label, "")
			}, "3000")

			if (success) {
				// Opening the link in the same tab
				can_upload = false
				window.open(endpoint, "_self")
			}
		})
	}

	if (save_button) {
		save_button.addEventListener("click", on_click)
	}

	return quill
}
