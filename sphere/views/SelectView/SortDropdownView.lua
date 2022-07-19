local Class = require("aqua.util.Class")
local just = require("just")
local transform = require("aqua.graphics.transform")
local spherefonts = require("sphere.assets.fonts")
local just_print = require("just.print")

local SortDropdownView = Class:new()

SortDropdownView.draw = function(self)
	local sortModel = self.game.sortModel

	local tf = transform(self.transform):translate(self.x, self.y)
	love.graphics.replaceTransform(tf)

	local w, h = self.w, self.h
	local padding = self.frame.padding
	local count = #sortModel.names
	local over = just.is_over(w, h)

	local scrolled, delta = just.wheel_behavior(self, over)
	local changed, active, hovered = just.button_behavior(self, over)

	if delta == -1 then
		self.navigator:scrollSortFunction(-1)
	elseif delta == 1 then
		self.navigator:scrollSortFunction(1)
	end

	if changed then
		self.isOpen = not self.isOpen
	end

	local wm = w - padding * 2
	local hm = h - padding * 2
	local hmf = h - padding * 2
	local r = hm / 2

	if self.isOpen then
		hmf = hm * count

		love.graphics.setColor(0, 0, 0, 0.8)
		love.graphics.rectangle("fill", padding, padding, wm, hmf, r, r)
	else
		love.graphics.setColor(1, 1, 1, 0.08)
		if hovered or hovered then
			love.graphics.setColor(1, 1, 1, active and 0.2 or 0.15)
		end
		love.graphics.rectangle("fill", padding, padding, wm, hm, r, r)
	end

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setFont(spherefonts.get(unpack(self.text.font)))
	love.graphics.setLineWidth(self.frame.lineWidth)
	love.graphics.setLineStyle(self.frame.lineStyle)

	love.graphics.rectangle("line", padding, padding, wm, hmf, r, r)

	if not self.isOpen then
		just_print(sortModel.name, padding, padding, wm, hm, "center", "center")
		just.next(w, h)
		return
	end

	for i = 1, count do
		local id = tostring(self) .. i

		local changed, active, hovered = just.button_behavior(id, just.is_over(wm, hm))
		if changed then
			self.navigator:setSortFunction(sortModel:fromIndexValue(i))
			self.isOpen = false
		end

		love.graphics.setColor(1, 1, 1, 0)
		if hovered or hovered then
			love.graphics.setColor(1, 1, 1, active and 0.2 or 0.1)
		end
		love.graphics.rectangle("fill", padding, padding, wm, hm, r, r)

		love.graphics.setColor(1, 1, 1, 1)
		just_print(sortModel.names[i], padding, padding, wm, hm, "center", "center")

		just.next(wm, hm)
	end
end

return SortDropdownView
