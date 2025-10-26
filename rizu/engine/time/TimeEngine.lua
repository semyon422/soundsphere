local class = require("class")
local TimeAdjust = require("rizu.engine.time.TimeAdjust")
local LocalTimer = require("rizu.engine.time.LocalTimer")
local VisualEnhancer = require("rizu.engine.time.VisualEnhancer")

---@class rizu.TimeEngine
---@operator call: rizu.TimeEngine
local TimeEngine = class()

TimeEngine.const = false

---@param adjust_factor number
---@param adjust_time fun(): number?
function TimeEngine:new(adjust_factor, adjust_time)
	self.adjust_time = adjust_time

	self.adjust = TimeAdjust(adjust_factor)
	self.enhancer = VisualEnhancer()
	self.timer = LocalTimer()
end

---@param adjust_factor number
function TimeEngine:setAdjustFactor(adjust_factor)
	self.adjust:setFactor(adjust_factor)
end

---@param global_time number
function TimeEngine:setGlobalTime(global_time)
	local timer = self.timer
	timer:setGlobalTime(global_time)
	self:adjustTime()
	self:updateTime()
end

---@param time number
function TimeEngine:setTime(time)
	self.timer:setTime(time)
	self:updateTime()
end

---@param rate number
function TimeEngine:setRate(rate)
	self.timer:setRate(rate)
end

function TimeEngine:adjustTime()
	local adjust_time = self.adjust_time()
	if not adjust_time then
		return
	end

	local adjusted_time = self.adjust:adjust(self.timer:getTime(), adjust_time)
	if not adjusted_time then
		return
	end

	self.timer:setTime(adjusted_time)
end

function TimeEngine:updateTime()
	self.time = self.timer:getTime()

	local enh_time = self.time
	if not self.const then
		enh_time = self.enhancer:get(enh_time)
	end
	self.enh_time = enh_time
end

function TimeEngine:pause()
	self.timer:pause()
end

function TimeEngine:play()
	self.timer:play()
end

return TimeEngine
