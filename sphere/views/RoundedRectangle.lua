---@param points table
---@param x number
---@param y number
local function addPoint(points, x, y)
	table.insert(points, x)
	table.insert(points, y)
end

---@param mode string
---@param x number
---@param y number
---@param w number
---@param h number
---@param r number|table
---@param rotateLeft boolean?
---@param rotateRight boolean?
local function rectangle(mode, x, y, w, h, r, rotateLeft, rotateRight)
	local r1, r2, r3, r4 = r, r, r, r
	if type(r) == "table" then
		r1, r2, r3, r4 = r[1], r[2], r[3], r[4]
	end

	local points = {}
	addPoint(points, x + r1, y)
	addPoint(points, x + w - r2, y)
	for a = -math.pi / 2, 0, math.pi / 64 do
		addPoint(points, x + w - r2 + math.cos(a) * r2, y + r2 + math.sin(a) * r2)
	end
	addPoint(points, x + w, y + h)
	addPoint(points, x, y + h)
	addPoint(points, x, y + r1)
	for a = -math.pi, -math.pi / 2, math.pi / 64 do
		addPoint(points, x + r1 + math.cos(a) * r1, y + r1 + math.sin(a) * r1)
	end
	love.graphics.polygon(mode, points)

	r = r3

	points = {}
	addPoint(points, x, y + h)
	if rotateLeft then
		addPoint(points, x - r, y + h)
		for a = math.pi / 2, 0, -math.pi / 64 do
			addPoint(points, x - r + math.cos(a) * r, y + h - r + math.sin(a) * r)
		end
		addPoint(points, x, y + h - r)
	else
		addPoint(points, x + r, y + h)
		for a = -math.pi / 2, -math.pi, -math.pi / 64 do
			addPoint(points, x + r + math.cos(a) * r, y + h + r + math.sin(a) * r)
		end
		addPoint(points, x, y + h + r)
	end
	love.graphics.polygon(mode, points)

	r = r4

	points = {}
	addPoint(points, x + w, y + h)
	if rotateRight then
		addPoint(points, x + w + r, y + h)
		for a = math.pi / 2, math.pi, math.pi / 64 do
			addPoint(points, x + w + r + math.cos(a) * r, y + h - r + math.sin(a) * r)
		end
		addPoint(points, x + w, y + h - r)
	else
		addPoint(points, x + w, y + h + r)
		for a = 0, -math.pi / 2, -math.pi / 64 do
			addPoint(points, x + w - r + math.cos(a) * r, y + h + r + math.sin(a) * r)
		end
		addPoint(points, x + w - r, y + h)
	end
	love.graphics.polygon(mode, points)
end

---@param mode string
---@param x number
---@param y number
---@param w number
---@param h number
---@param r number|table
---@param rotateLeft boolean?
---@param rotateRight boolean?
local function rr(mode, x, y, w, h, r, rotateLeft, rotateRight, rotateAll)
	love.graphics.push()

	if not rotateAll or rotateAll == 0 then
		love.graphics.translate(x, y)
		rectangle(mode, 0, 0, w, h, r, rotateLeft, rotateRight)
	elseif rotateAll == 1 then
		love.graphics.translate(x + w, y)
		love.graphics.rotate(math.pi / 2)
		rectangle(mode, 0, 0, h, w, r, rotateLeft, rotateRight)
	elseif rotateAll == 2 then
		love.graphics.translate(x + w, y + h)
		love.graphics.rotate(math.pi)
		rectangle(mode, 0, 0, w, h, r, rotateLeft, rotateRight)
	elseif rotateAll == 3 then
		love.graphics.translate(x, y + h)
		love.graphics.rotate(-math.pi / 2)
		rectangle(mode, 0, 0, h, w, r, rotateLeft, rotateRight)
	end

	love.graphics.pop()
end

return rr
