
local just = require("just")
local Class = require("aqua.util.Class")
local transform = require("aqua.graphics.transform")
local baseline_print = require("aqua.graphics.baseline_print")
local spherefonts = require("sphere.assets.fonts")

local SearchFieldView = Class:new()

SearchFieldView.padding = 6

SearchFieldView.setText = function(self, text) end
SearchFieldView.getText = function(self) return "" end

SearchFieldView.draw = function(self)
	if just.focused_id == self then
		local changed, text = just.textinput(self:getText())
		if changed == "text" then
			self:setText(text)
		end
	end

	local tf = transform(self.transform):translate(self.x, self.y)
	love.graphics.replaceTransform(tf)

	local changed, active, hovered = just.button(self, just.is_over(self.w, self.h))
	if changed then
		just.focus(self)
		self.screenView:setSearchMode(self.searchMode)
	end

	local padding = self.padding
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

	local searchString = self:getText()
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

	if just.focused_id ~= self then
		return
	end

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setLineWidth(1)
	love.graphics.setLineStyle("smooth")

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
