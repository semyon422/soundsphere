local SpoilerImView = require("sphere.imviews.SpoilerImView")
local TextButtonImView = require("sphere.imviews.TextButtonImView")
local just = require("just")

local size = 0.75
return function(id, w, h, list, preview, to_string)
	local _i, _name
	if SpoilerImView(id, w, h, preview) then
		love.graphics.setColor(0, 0, 0, 1)
		love.graphics.rectangle("fill", 0, 0, w, h * size * #list)
		love.graphics.setColor(1, 1, 1, 1)
		for i, name in ipairs(list) do
			if to_string then
				name = to_string(name)
			end
			just.indent(-h * (1 - size) / 2)
			if TextButtonImView("spoiler" .. i, name, w, h * size, "center") then
				_i, _name = i, name
				just.focus()
			end
		end
		SpoilerImView()
	end
	return _i, _name
end
