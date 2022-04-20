local round = require("aqua.math").round
local map = require("aqua.math").map
local inside = require("aqua.util.inside")
local outside = require("aqua.util.outside")
local imgui = require("cimgui")
local ImguiElement = require("sphere.imgui.ImguiElement")

local Combo = ImguiElement:new()

local indexOf = function(values, value)
	for i, currentValue in ipairs(values) do
		if value == currentValue then
			return i
		end
	end
	return 1
end

local valueOf = function(values, index)
	index = math.min(math.max(index, 1), #values)
	return values[index]
end

Combo.render = function(self)
	local ptr = self:getPointer("int[1]")
	local values = self.values
	local displayValues = self.displayValues
	local selectedIndex = indexOf(values, inside(self, self.key))
	local selectedValue = (displayValues or values)[selectedIndex]
	ptr[0] = selectedIndex
	if imgui.BeginCombo(self.name, selectedValue, 0) then
		for i = 1, #values do
			if imgui.Selectable_Bool((displayValues or values)[i], selectedIndex == i) then
				ptr[0] = i
				outside(self, self.key, valueOf(values, ptr[0]))
			end
			if selectedIndex == i then
				imgui.SetItemDefaultFocus()
			end
		end
		imgui.EndCombo()
	end
end

return Combo
