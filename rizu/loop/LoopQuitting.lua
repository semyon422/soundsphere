local class = require("class")
local thread = require("thread")
local delay = require("delay")

---@class rizu.LoopQuitting
---@operator call: rizu.LoopQuitting
local LoopQuitting = class()

function LoopQuitting:new(loop)
	self.loop = loop
end

---@return number?
function LoopQuitting:update()
	love.event.pump()

	for name, a, b, c, d, e, f in love.event.poll() do
		if name == "quit" then
			self.loop:send({name = "quit"})
			return 0
		end
	end

	thread.update()
	delay.update()

	if thread.current == 0 then
		self.loop:send({name = "quit"})
		return 0
	end

	if love.graphics and love.graphics.isActive() then
		love.graphics.clear(love.graphics.getBackgroundColor())
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.printf("waiting for " .. thread.current .. " coroutines", 0, 0, 1000, "left")
		love.graphics.present()
	end

	love.timer.sleep(0.1)
end

return LoopQuitting
