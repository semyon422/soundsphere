
local just = require("just")
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
	if self.navigator.searchMode ~= self.searchMode then
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

	local changed, active, hovered = just.button(self, just.is_over(self.w, self.h))
	if changed then
		self.navigator:setSearchMode(self.searchMode)
	end

	local padding = self.frame.padding
	local h = self.h - padding * 2

	love.graphics.setColor(1, 1, 1, 0.08)
	if hovered then
		love.graphics.setColor(1, 1, 1, active and 0.2 or 0.15)
	end

	love.graphics.rectangle(
		"fill",
		padding,
		padding,
		self.w - padding * 2,
		h,
		h / 2,
		h / 2
	)

	local searchString = inside(self, self.searchString)
	if searchString == "" then
		love.graphics.setColor(1, 1, 1, 0.5)
		searchString = self.placeholder or "Search..."
	else
		love.graphics.setColor(1, 1, 1, 1)
	end

	love.graphics.setFont(spherefonts.get(unpack(self.text.font)))
	baseline_print(
		searchString,
		self.text.x,
		self.text.baseline,
		self.text.limit,
		1,
		self.text.align
	)

	if self.navigator.searchMode ~= self.searchMode then
		return
	end

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setLineWidth(self.frame.lineWidth)
	love.graphics.setLineStyle(self.frame.lineStyle)

	love.graphics.rectangle(
		"line",
		padding,
		padding,
		self.w - padding * 2,
		h,
		h / 2,
		h / 2
	)
end

return SearchFieldView
