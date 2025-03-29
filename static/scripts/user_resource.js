async function sendDescriptionToServer(quill, user_id) {
	const json_content = JSON.stringify(quill.getContents())
	const json_length = json_content.length
	const json_length_limit = 4096

	if (quill.getLength() === 1) {
		return [false, "Description is empty"]
	}

	if (json_length > json_length_limit) {
		return [false, `Too many characters! ${json_length}/${json_length_limit}`]
	}

	const headers = new Headers()
	headers.append("Content-Type", "application/json")

	const req = new Request(`/users/${user_id}/edit_description`, {
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

function addQuillToElement(parent_element, content, edit_mode) {
	if (parent_element === null) {
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

	const editor = document.createElement("div")
	parent_element.appendChild(editor)

	const quill = new Quill(editor, editor_params)
	quill.setContents(content)
	return quill
}
