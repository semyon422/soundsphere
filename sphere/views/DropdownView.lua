local Class = require("aqua.util.Class")
local just = require("just")
local transform = require("aqua.graphics.transform")
local spherefonts = require("sphere.assets.fonts")
local just_print = require("just.print")

local DropdownView = Class:new()

DropdownView.padding = 6
DropdownView.font = {"Noto Sans", 20}

DropdownView.scroll = function(self, delta) end
DropdownView.select = function(self, i) end

DropdownView.getCount = function(self) end
DropdownView.getPreview = function(self) end
DropdownView.getItemText = function(self, i) end

DropdownView.draw = function(self)
	local tf = transform(self.transform):translate(self.x, self.y)
	love.graphics.replaceTransform(tf)

	local w, h = self.w, self.h
	local padding = self.padding

	local count = self:getCount()

	local over = just.is_over(w, h)

	local scrolled, delta = just.wheel_behavior(self, over)
	local changed, active, hovered = just.button_behavior(self, over)

	if scrolled then
		self:scroll(delta)
	end

	if changed then
		self.isOpen = not self.isOpen
	end

	local wm = w - padding * 2
	local hm = h - padding * 2
	local hmf = h - padding * 2
	local r = hm / 2

	if self.closedBackgroundColor then
		love.graphics.setColor(self.closedBackgroundColor)
		love.graphics.rectangle("fill", padding, padding, wm, hmf, r, r)
	end

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
	love.graphics.setFont(spherefonts.get(unpack(self.font)))
	love.graphics.setLineWidth(1)
	love.graphics.setLineStyle("smooth")

	love.graphics.rectangle("line", padding, padding, wm, hmf, r, r)

	if not self.isOpen then
		just_print(self:getPreview(), padding, padding, wm, hm, "center", "center")
		just.next(w, h)
		return
	end

	for i = 1, count do
		local id = tostring(self) .. i

		local changed, active, hovered = just.button_behavior(id, just.is_over(wm, hm))
		if changed then
			self:select(i)
			self.isOpen = false
		end

		love.graphics.setColor(1, 1, 1, 0)
		if hovered or hovered then
			love.graphics.setColor(1, 1, 1, active and 0.2 or 0.1)
		end
		love.graphics.rectangle("fill", padding, padding, wm, hm, r, r)

		love.graphics.setColor(1, 1, 1, 1)
		just_print(self:getItemText(i), padding, padding, wm, hm, "center", "center")

		just.next(wm, hm)
	end
end

return DropdownView
