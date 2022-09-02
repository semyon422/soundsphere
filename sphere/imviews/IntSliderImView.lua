local map = require("aqua.math").map
local SliderImView = require("sphere.imviews.SliderImView")

return function(id, value, min, max, w, h)
	local _value = map(value, min, max, 0, 1)
	local new_value = SliderImView(id, _value, w, h)
	if not new_value then
		return value
	end
	return math.floor(map(new_value, 0, 1, min, max))
end
