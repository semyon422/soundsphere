// Default params for sweetalert
var SWEET_ALERT_PARAMS = {
	animation: false,
	customClass: {
		confirmButton: "button is-danger",
		denyButton: "button",
	}
}

function main() {
	let theme = localStorage.getItem("theme")

	if (!theme) {
		if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
			theme = "dark"
		}
		else {
			theme = "light"
		}

		localStorage.setItem("theme", theme)
	}

	const html = document.querySelector("html")
	html.setAttribute("data-theme", theme)

	document.addEventListener("htmx:responseError", (event) => {
		Swal.fire({
			...SWEET_ALERT_PARAMS,
			title: "Server Error",
			confirmButtonText: "Reload page",
			width: "70em",
			html: "<div align='left'>" + event.detail.xhr.responseText + "</div>",
		}).then((result) => {
			if (result.isConfirmed) {
				window.location.reload();
			}
		})
	})
}

main()
