local cursor = {}

function cursor:setCircleCursor()
	if not self.circleCursor then
		self:createCircle()
	end
	love.mouse.setCursor(self.circleCursor)
end

function cursor:setArrowCursor()
	if not self.arrowCursor then
		self:createArrow()
	end
	love.mouse.setCursor(self.arrowCursor)
end

function cursor:setSystemCursor()
	love.mouse.setCursor()
end

function cursor:createCircle()
	local oldCanvas = love.graphics.getCanvas()
	local canvas = love.graphics.newCanvas(32, 32)
	love.graphics.setCanvas(canvas)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.circle("line", 16, 16, 8, 64)
	love.graphics.circle("fill", 16, 16, 8, 64)
	love.graphics.setCanvas(oldCanvas)
	self.circleCursor = love.mouse.newCursor(canvas:newImageData(), 16, 16)
end

function cursor:createArrow()
	local oldCanvas = love.graphics.getCanvas()
	local canvas = love.graphics.newCanvas(32, 32)
	love.graphics.setCanvas(canvas)
	love.graphics.setColor(1, 1, 1, 1)
	local vertices = {0, 0, 16, 16, 0, 16 * math.sqrt(2)}
	love.graphics.polygon("line", vertices)
	love.graphics.polygon("fill", vertices)
	love.graphics.setCanvas(oldCanvas)
	self.arrowCursor = love.mouse.newCursor(canvas:newImageData(), 0, 0)
end

return cursor
