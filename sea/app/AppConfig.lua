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
	},

	multiplayer = {
		address = "*",
		port = 9000,
	},
}

return AppConfig
