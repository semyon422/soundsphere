
local Class = require("aqua.util.Class")
local transform = require("aqua.graphics.transform")
local baseline_print = require("aqua.graphics.baseline_print")
local spherefonts		= require("sphere.assets.fonts")
local inside = require("aqua.util.inside")
local TextInput = require("aqua.util.TextInput")

local SearchFieldView = Class:new()

SearchFieldView.load = function(self)
	self.textInput = TextInput:new()
	self.textInput:setText(inside(self, self.searchString))
end

SearchFieldView.receive = function(self, event)
	if not (event.name == "textinput" or event.name == "keypressed" and event[1] == "backspace") then
		return
	end

	self.textInput:receive(event)
	self.navigator:setSearchString(self.textInput.text)
end

SearchFieldView.update = function(self)
	self.textInput:setText(inside(self, self.searchString))
end

SearchFieldView.draw = function(self)
	local tf = transform(self.transform):translate(self.x, self.y)
	love.graphics.replaceTransform(tf)

	local searchString = inside(self, self.searchString)
	if searchString == "" then
		love.graphics.setColor(1, 1, 1, 0.5)
		searchString = "Search..."
	else
		love.graphics.setColor(1, 1, 1, 1)
	end

	local font = spherefonts.get(self.text.font)
	love.graphics.setFont(font)
	baseline_print(
		searchString,
		self.text.x,
		self.text.baseline,
		self.text.limit,
		1,
		self.text.align
	)

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setLineWidth(self.frame.lineWidth)
	love.graphics.setLineStyle(self.frame.lineStyle)
	love.graphics.rectangle(
		"line",
		self.frame.x,
		self.frame.y,
		self.frame.w,
		self.frame.h,
		self.frame.h / 2,
		self.frame.h / 2
	)

	if inside(self, self.searchMode) == "lamp" then
		love.graphics.circle(
			"line",
			self.frame.x + self.frame.w - self.frame.h / 2,
			self.frame.y + self.frame.h / 2,
			self.point.r
		)
		love.graphics.circle(
			"fill",
			self.frame.x + self.frame.w - self.frame.h / 2,
			self.frame.y + self.frame.h / 2,
			self.point.r
		)
	end

	if inside(self, self.collapse) then
		love.graphics.circle(
			"line",
			self.frame.x + self.frame.w - self.frame.h,
			self.frame.y + self.frame.h / 2,
			self.point.r
		)
	end
end

return SearchFieldView
