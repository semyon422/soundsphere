local UserInfoView = require("sphere.views.UserInfoView")
local LogoView = require("sphere.views.LogoView")
local _transform = require("aqua.graphics.transform")
local just = require("just")

local transform = {{1 / 2, -16 / 9 / 2}, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}

local Layout = {}

local Frames = {draw = function()
	local width, height = love.graphics.getDimensions()

	love.graphics.replaceTransform(_transform(transform))

	local _x, _y = love.graphics.inverseTransformPoint(0, 0)
	local _xw, _yh = love.graphics.inverseTransformPoint(width, height)
	local _w, _h = _xw - _x, _yh - _y

	local x_int = 24
	local y_int = 55

	local x1, w1 = just.layout(_x, _w, {y_int, -1/3, x_int, -1/3, x_int, -1/3, y_int})

	local y0, h0 = just.layout(0, 1080, {89, y_int, -1, y_int, 89})

	Layout.x1, Layout.w1 = x1, w1
	Layout.y0, Layout.h0 = y0, h0

	-- love.graphics.setColor(0, 0, 0, 0.8)
	-- love.graphics.rectangle("fill", _x, _y, _w, h0[1])
	-- love.graphics.rectangle("fill", _x, _yh - h0[5], _w, h0[1])
end}

local Logo = LogoView:new({
	transform = transform,
	draw = function(self)
		self.x = Layout.x1[2]
		self.y = Layout.y0[1]
		self.w = Layout.w1[2]
		self.h = Layout.h0[1]
		self.__index.draw(self)
	end,
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
		font = {"Noto Sans", 32},
	}
})

local UserInfo = UserInfoView:new({
	transform = transform,
	username = "game.configModel.configs.online.user.name",
	session = "game.configModel.configs.online.session",
	file = "userdata/avatar.png",
	action = "openOnline",
	draw = function(self)
		self.x = Layout.x1[7] - Layout.h0[1]
		self.y = Layout.y0[1]
		self.w = Layout.w1[2]
		self.h = Layout.h0[1]
		self.__index.draw(self)
	end,
	image = {
		x = 21,
		y = 20,
		w = 48,
		h = 48
	},
	marker = {
		x = 97,
		y = 44,
		r = 8,
	},
	text = {
		x = -454 + 89,
		baseline = 54,
		limit = 365,
		align = "right",
		font = {"Noto Sans", 26},
	}
})

return {
	Frames,
	Logo,
	UserInfo,
}
