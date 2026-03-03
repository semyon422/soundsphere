local dark = {
	text = {0.95, 0.95, 1, 1},
	lines = {0.65, 0.70, 0.80, 1},
	br = {0.65, 0.70, 0.80, 0.3},
	outline = {0.6, 0.65, 0.75, 0.85},
	panels = {0.08, 0.08, 0.1, 1},
	header_footer = {0.05, 0.05, 0.07, 1},
	accent = {0, 0.8, 1, 1},
	button = {0.12, 0.16, 0.21, 1},
	button_hover = {0.2, 0.2, 0.25, 1},
	button_text = {1, 1, 1, 1}
}

local Colors = dark

---@param h number
---@param s number
---@param v number
---@return number[]
function Colors.HSV(h, s, v)
	if s <= 0 then return {v, v, v, 1} end
	h = h * 6
	local c = v * s
	local x = (1 - math.abs((h % 2) - 1)) * c
	local m, r, g, b = (v - c), 0, 0, 0
	if h < 1 then
		r, g, b = c, x, 0
	elseif h < 2 then
		r, g, b = x, c, 0
	elseif h < 3 then
		r, g, b = 0, c, x
	elseif h < 4 then
		r, g, b = 0, x, c
	elseif h < 5 then
		r, g, b = x, 0, c
	else
		r, g, b = c, 0, x
	end
	return {r + m, g + m, b + m, 1}
end

---@param x number
---@return number
function Colors.convertDiffToHue(x)
	if x <= 0.5 then
		return 0.5 - x
	elseif x <= 0.75 then
		return 1 - (x - 0.5) * (1 - 0.8) / 0.25
	else
		return 0.8
	end
end

return Colors
