return function(self)
	local editorModel = self.game.editorModel
	local onsetsDeltaDist = editorModel.onsetsDeltaDist
	if not onsetsDeltaDist or not editorModel.bins then
		return
	end

	local w, h = love.graphics.getDimensions()

	love.graphics.origin()
	love.graphics.setLineWidth(1)

	for i, obj in ipairs(onsetsDeltaDist) do
		local y = h / 2
		love.graphics.line(obj.t * w, y, obj.t * w, y + obj.v * h / 10)
	end

	for i = 0, editorModel.binsSize - 1 do
		local v = editorModel.bins[i]
		local x = i / editorModel.binsSize
		love.graphics.line(x * w, 0, x * w, v * h / 10)
	end
end
