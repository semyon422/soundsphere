local just = require("just")
local imgui = require("imgui")

local size = 0.75
return function(id, w, h, list, preview, to_string)
	local _i, _name
	if imgui.Spoiler(id, w, h, preview) then
		love.graphics.setColor(0, 0, 0, 1)
		love.graphics.rectangle("fill", 0, 0, w, h * size * #list)
		love.graphics.setColor(1, 1, 1, 1)
		for i, name in ipairs(list) do
			if to_string then
				name = to_string(name)
			end
			just.indent(-h * (1 - size) / 2)
			if imgui.TextOnlyButton("spoiler" .. i, name, w, h * size, "center") then
				_i, _name = i, name
				just.focus()
			end
		end
		imgui.Spoiler()
	end
	return _i, _name
end
