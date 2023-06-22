return function(self)
	local ncbtContext = self.game.editorModel.ncbtContext
	local onsetsDeltaDist = ncbtContext.onsetsDeltaDist
	if not onsetsDeltaDist or not ncbtContext.bins then
		return
	end

	local w, h = love.graphics.getDimensions()

	love.graphics.origin()
	love.graphics.setLineWidth(1)

	for i, obj in ipairs(onsetsDeltaDist) do
		local y = h / 2
		love.graphics.line(obj.t * w, y, obj.t * w, y + obj.v * h / 10)
	end

	for i = 0, ncbtContext.binsSize - 1 do
		local v = ncbtContext.bins[i]
		local x = i / ncbtContext.binsSize
		love.graphics.line(x * w, 0, x * w, v * h / 10)
	end
end
