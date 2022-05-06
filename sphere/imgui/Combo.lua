local ffi = require("ffi")
local inside = require("aqua.util.inside")
local outside = require("aqua.util.outside")
local imgui = require("cimgui")

local indexOf = function(values, value)
	for i, currentValue in ipairs(values) do
		if type(currentValue) == "table" then
			local different = false
			for k, v in pairs(currentValue) do
				if v ~= value[k] then
					different = true
				end
			end
			if not different then
				return i
			end
		elseif value == currentValue then
			return i
		end
	end
	return 1
end

local valueOf = function(values, index)
	index = math.min(math.max(index, 1), #values)
	return values[index]
end

local ptr = ffi.new("int[1]")
return function(self, config)
	local values = self.values
	local displayValues = self.displayValues
	local selectedIndex = indexOf(values, inside(config, self.key))
	local selectedValue = (displayValues or values)[selectedIndex]
	ptr[0] = selectedIndex
	if imgui.BeginCombo(self.name, selectedValue, 0) then
		for i = 1, #values do
			if imgui.Selectable_Bool((displayValues or values)[i], selectedIndex == i) then
				ptr[0] = i
				outside(config, self.key, valueOf(values, ptr[0]))
			end
			if selectedIndex == i then
				imgui.SetItemDefaultFocus()
			end
		end
		imgui.EndCombo()
	end
end
