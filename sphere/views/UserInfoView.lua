
local Class = require("aqua.util.Class")
local transform = require("aqua.graphics.transform")
local spherefonts		= require("sphere.assets.fonts")
local baseline_print = require("aqua.graphics.baseline_print")
local inside = require("aqua.util.inside")
local belong		= require("aqua.math").belong

local UserInfoView = Class:new()

UserInfoView.load = function(self)
	local config = self.config
	local state = self.state

	if not config.file or not love.filesystem.getInfo(config.file) then
		return
	end

	state.image = love.graphics.newImage(config.file)
end

UserInfoView.receive = function(self, event)
	if event.name ~= "mousepressed" then
		return
	end

	local config = self.config
	local tf = transform(config.transform)
	local mx, my = tf:inverseTransformPoint(event[1], event[2])
	tf:release()

	local x, y, w, h = config.x, config.y, config.w, config.h
	if belong(mx, x, x + w) and belong(my, y, y + h) then
		local button = event[3]
		if button == 1 then
			self.navigator:call("quickLogin")
		end
	end
end

UserInfoView.draw = function(self)
	local config = self.config
	local state = self.state

	local tf = transform(config.transform):translate(config.x, config.y)
	love.graphics.replaceTransform(tf)
	tf:release()
	love.graphics.setColor(1, 1, 1, 1)

	local font = spherefonts.get(config.text.font)
	love.graphics.setFont(font)

	local username = config.username and inside(self, config.username) or ""
	baseline_print(
		username,
		config.text.x,
		config.text.baseline,
		config.text.limit,
		1,
		config.text.align
	)

	local image = state.image
	if state.image then
		love.graphics.draw(
			image,
			config.image.x,
			config.image.y,
			0,
			config.image.w / image:getWidth(),
			config.image.h / image:getHeight()
		)
	end

	love.graphics.circle(
		"line",
		config.image.x + config.image.w / 2,
		config.image.y + config.image.h / 2,
		config.image.h / 2
	)

	local session = config.session and inside(self, config.session)
	if session and session.active then
		love.graphics.circle(
			"fill",
			config.marker.x,
			config.marker.y,
			config.marker.r
		)
		love.graphics.circle(
			"line",
			config.marker.x,
			config.marker.y,
			config.marker.r
		)
	end
end

return UserInfoView
