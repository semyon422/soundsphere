local just = require("just")

return function(f, self)
	if not f then
		return
	end

	love.graphics.origin()
	love.graphics.setColor(0, 0, 0, 0.8)
	love.graphics.rectangle("fill", 0, 0, love.graphics.getDimensions())

	if just.button("close modal", true) then
		return true
	end
	if f(self) then
		return true
	end
end
