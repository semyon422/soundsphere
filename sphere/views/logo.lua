local logo = {}

---@param mode string
---@param x number
---@param y number
---@param size number
---@param segments number?
function logo.draw(mode, x, y, size, segments)
	local scale = size / 48
	segments = segments or 16
	local dphi = -math.pi / 2 / segments
	local c = 1
	local s = 0
	for i = 1, segments do
		local cd = math.cos(i * dphi)
		local sd = math.sin(i * dphi)
		love.graphics.polygon(
			mode,
			x + (24 + 24 * c) * scale,
			y + (24 + 24 * s) * scale,
			x + (24 + 16 * c) * scale,
			y + (24 + 16 * s) * scale,
			x + (24 + 16 * cd) * scale,
			y + (24 + 16 * sd) * scale,
			x + (24 + 24 * cd) * scale,
			y + (24 + 24 * sd) * scale
		)
		c, s = cd, sd
	end
	local sr2 = math.sqrt(2)
	love.graphics.circle(
		mode,
		x + (24 - 9 / sr2) * scale,
		y + (24 + 9 / sr2) * scale,
		15 * scale
	)
	love.graphics.rectangle(
		mode,
		x + 24 * scale,
		y + 8 * scale,
		(15 - 9 / sr2) * scale,
		(16 + 9 / sr2) * scale
	)
end

return logo
