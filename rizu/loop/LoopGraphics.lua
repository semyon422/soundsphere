local class = require("class")
local just = require("just")

---@class rizu.LoopGraphics
---@operator call: rizu.LoopGraphics
local LoopGraphics = class()

---@param loop rizu.Loop
function LoopGraphics:new(loop)
	self.loop = loop
	self.dwm_flush = false
	self.dwmapi = nil
	if love.system.getOS() == "Windows" then
		local ffi = require("ffi")
		local ok, res = pcall(ffi.load, "dwmapi")
		if ok then
			self.dwmapi = res
			ffi.cdef("void DwmFlush();")
		end
	end
end

---@return number
function LoopGraphics:draw()
	local frame_end_time = love.timer.getTime()

	if love.graphics and love.graphics.isActive() then
		local timings_draw_start = love.timer.getTime()
		love.graphics.origin()
		love.graphics.clear(love.graphics.getBackgroundColor())
		self.loop.events:dispatchEvent("draw")
		just._end()
		love.graphics.origin()
		love.graphics.getStats(self.loop.stats)
		self.loop.timings.draw = love.timer.getTime() - timings_draw_start

		local timings_present_start = love.timer.getTime()
		love.graphics.present()
		self:onPresent()
		self.loop.timings.present = love.timer.getTime() - timings_present_start

		frame_end_time = love.timer.getTime()
	end

	return frame_end_time
end

function LoopGraphics:onPresent()
	if self.dwmapi and self.dwm_flush then
		self.dwmapi.DwmFlush()
	end
end

return LoopGraphics
