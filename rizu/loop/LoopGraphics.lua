local class = require("class")
local just = require("just")

---@class rizu.loop.LoopGraphics
---@operator call: rizu.loop.LoopGraphics
local LoopGraphics = class()

---@param loop rizu.loop.Loop
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
	local timings_draw_start = love.timer.getTime()
	local frame_end_time = love.timer.getTime()

	if love.graphics and love.graphics.isActive() then
		love.graphics.origin()
		love.graphics.clear(love.graphics.getBackgroundColor())
		self.loop.events:dispatchEvent("draw")
		just._end()
		love.graphics.origin()
		love.graphics.getStats(self.loop.stats)
		love.graphics.present()
		self:onPresent()
		frame_end_time = love.timer.getTime()
	end

	self.loop.timings.draw = love.timer.getTime() - timings_draw_start
	return frame_end_time
end

function LoopGraphics:onPresent()
	if self.dwmapi and self.dwm_flush then
		self.dwmapi.DwmFlush()
	end
end

return LoopGraphics
