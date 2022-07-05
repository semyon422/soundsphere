
local just = require("just")
local Class = require("aqua.util.Class")
local transform = require("aqua.graphics.transform")
local spherefonts		= require("sphere.assets.fonts")
local baseline_print = require("aqua.graphics.baseline_print")
local inside = require("aqua.util.inside")

local UserInfoView = Class:new()

UserInfoView.load = function(self)
	if not self.file or not love.filesystem.getInfo(self.file) then
		return
	end

	self.imageObject = love.graphics.newImage(self.file)
end

UserInfoView.draw = function(self)
	local tf = transform(self.transform):translate(self.x, self.y)
	love.graphics.replaceTransform(tf)

	local x, y = love.graphics.inverseTransformPoint(love.mouse.getPosition())
	local over = 0 <= x and x <= self.h and 0 <= y and y <= self.h

	local changed, active, hovered = just.button_behavior(self, over)
	if changed then
		self.navigator:call(self.action)
	end

	love.graphics.setFont(spherefonts.get(unpack(self.text.font)))
	love.graphics.setColor(1, 1, 1, 1)

	local username = self.username and inside(self, self.username) or ""
	baseline_print(
		username,
		self.text.x,
		self.text.baseline,
		self.text.limit,
		1,
		self.text.align
	)

	local imageObject = self.imageObject
	if self.imageObject then
		love.graphics.draw(
			imageObject,
			self.image.x,
			self.image.y,
			0,
			self.image.w / imageObject:getWidth(),
			self.image.h / imageObject:getHeight()
		)
	end

	love.graphics.circle(
		"line",
		self.image.x + self.image.w / 2,
		self.image.y + self.image.h / 2,
		self.image.h / 2
	)
	if hovered then
		local alpha = active and 0.2 or 0.1
		love.graphics.setColor(1, 1, 1, alpha)
		love.graphics.circle(
			"fill",
			self.image.x + self.image.w / 2,
			self.image.y + self.image.h / 2,
			self.image.h / 2
		)
	end

	local session = self.session and inside(self, self.session)
	if session and session.active then
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.circle(
			"fill",
			self.marker.x,
			self.marker.y,
			self.marker.r
		)
		love.graphics.circle(
			"line",
			self.marker.x,
			self.marker.y,
			self.marker.r
		)
	end
end

return UserInfoView
