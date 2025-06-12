---@class sea.AppConfig
local AppConfig = {
	sessions_secret = "secret",

	is_register_enabled = true,
	is_login_enabled = true,
	is_register_captcha_enabled = false,
	is_login_captcha_enabled = false,
	recaptcha = {
		site_key = "",
		secret_key = "",
		required_score = 0.5,
	},

	osu_api = {
		client_id = 0,
		client_secret = "",
		redirect_uri = "",
	},

	multiplayer = {
		address = "*",
		port = 9000,
	},

	responsible_person = {
		name = "Name",
		email = "email@example.com",
	},
}

return AppConfig
