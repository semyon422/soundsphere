local transform = {{1 / 2, -16 / 9 / 2}, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}

local Logo = {
	class = "LogoView",
	transform = transform,
	x = 279,
	y = 0,
	w = 454,
	h = 89,
	image = {
		x = 21,
		y = 20,
		w = 48,
		h = 48
	},
	text = {
		x = 89,
		baseline = 56,
		limit = 365,
		align = "left",
		font = {
			filename = "Noto Sans",
			size = 32,
		},
	}
}

local UserInfo = {
	class = "UserInfoView",
	transform = transform,
	username = "gameController.configModel.configs.online.username",
	session = "gameController.configModel.configs.online.session",
	file = "userdata/avatar.png",
	x = 1187,
	y = 0,
	w = 454,
	h = 89,
	image = {
		x = 386,
		y = 20,
		w = 48,
		h = 48
	},
	marker = {
		x = 1641 - 1187 + 8,
		-- x = 386 + 48 + 21 + 8,
		-- x = 1641 + 8,
		y = 20 + 24,
		r = 8,
	},
	text = {
		x = 0,
		baseline = 54,
		limit = 365,
		align = "right",
		font = {
			filename = "Noto Sans",
			size = 26,
		},
	}
}

return {
	Logo,
	UserInfo,
}
