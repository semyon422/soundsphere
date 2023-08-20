local class = require("class")
local math_util = require("math_util")
local Observable = require("Observable")
local TimeManager = require("sphere.models.RhythmModel.TimeEngine.TimeManager")

---@class sphere.TimeEngine
---@operator call: sphere.TimeEngine
local TimeEngine = class()

TimeEngine.timeToPrepare = 2

function TimeEngine:new()
	self.observable = Observable()

	self.timer = TimeManager()
	self.timer.timeEngine = self
end

TimeEngine.startTime = 0
TimeEngine.currentTime = 0
TimeEngine.currentVisualTime = 0
TimeEngine.timeRate = 1
TimeEngine.targetTimeRate = 1
TimeEngine.baseTimeRate = 1
TimeEngine.windUp = nil

function TimeEngine:load()
	self.timer:pause()
	self.timer:setRate(self.timeRate)
	self.timer.adjustRate = self.adjustRate
	self:loadTimePoints()

	local t = -self.timeToPrepare * self.baseTimeRate
	self.timer:setTime(t)

	self.startTime = t
	self.currentTime = t
	self.currentVisualTime = t

	if self.noteChart then
		self.minTime = self.noteChart.metaData.minTime
		self.maxTime = self.noteChart.metaData.maxTime
	end
end

---@param event table
function TimeEngine:sync(event)
	local timer = self.timer

	timer.eventTime = event.time

	if self.windUp then
		self:updateWindUp()
	end

	if self.timeRate ~= self.targetTimeRate then
		timer:setRate(self.timeRate)
	end

	self.currentTime = timer:getTime()

	if not self.nextTimeIndex then
		return
	end
	self:updateNextTimeIndex()
	self.currentVisualTime = self:getVisualTime()
end

---@return number
function TimeEngine:getVisualTime()
	local nearestTime = self:getNearestTime()
	local currentTime = self.currentTime
	if math.abs(currentTime - nearestTime) < 0.001 then
		return nearestTime
	end
	return currentTime
end

function TimeEngine:skipIntro()
	local skipTime = self.minTime - self.timeToPrepare * self.timeRate
	if self.currentTime < skipTime and self.timer.isPlaying then
		self:setPosition(skipTime)
	end
end

function TimeEngine:updateWindUp()
	local startTime = self.noteChart.metaData.minTime
	local endTime = self.noteChart.metaData.maxTime
	local currentTime = self.currentTime

	local a, b = unpack(self.windUp)
	local timeRate = math_util.map(currentTime, startTime, endTime, a, b)
	timeRate = math.min(math.max(timeRate, a), b)

	self:setTimeRate(timeRate * self.baseTimeRate)
end

---@param delta number
function TimeEngine:increaseTimeRate(delta)
	local target = self.targetTimeRate
	local newTarget = math.floor((target + delta) / delta + 0.5) * delta

	if newTarget >= 0.1 then
		self:setTimeRate(newTarget)
	end
end

---@param position number
function TimeEngine:setPosition(position)
	local timer = self.timer
	local audioEngine = self.rhythmModel.audioEngine

	audioEngine:setPosition(position)
	timer:setTime(position)
	self.currentTime = timer:getTime()
	self.currentVisualTime = self:getVisualTime()

	audioEngine.forcePosition = true
	self.rhythmModel.logicEngine:update()
	audioEngine.forcePosition = false
end

function TimeEngine:pause()
	self.timer:pause()
end

function TimeEngine:play()
	self.timer:play()
end

---@param timeRate number
function TimeEngine:setBaseTimeRate(timeRate)
	self.baseTimeRate = timeRate
	self:setTimeRate(timeRate)
end

---@param timeRate any
function TimeEngine:setTimeRate(timeRate)
	self.targetTimeRate = timeRate
	self.timeRate = timeRate
	self.timer:setRate(timeRate)
end

function TimeEngine:loadTimePoints()
	local absoluteTimes = {}

	local noteChart = self.noteChart
	if not noteChart then
		return
	end
	for _, layerData in noteChart:getLayerDataIterator() do
		local timePointList = layerData.timePointList
		for timePointIndex = 1, #timePointList do
			local timePoint = timePointList[timePointIndex]
			absoluteTimes[timePoint.absoluteTime] = true
		end
	end

	local absoluteTimeList = {}
	for time in pairs(absoluteTimes) do
		absoluteTimeList[#absoluteTimeList + 1] = time
	end
	table.sort(absoluteTimeList)

	self.absoluteTimeList = absoluteTimeList
	self.nextTimeIndex = 1
end

function TimeEngine:updateNextTimeIndex()
	local timeList = self.absoluteTimeList
	while true do
		if
			timeList[self.nextTimeIndex + 1] and
			self.currentTime >= timeList[self.nextTimeIndex]
		then
			self.nextTimeIndex = self.nextTimeIndex + 1
		else
			break
		end
	end
end

---@return number
function TimeEngine:getNearestTime()
	local timeList = self.absoluteTimeList
	local prevTime = timeList[self.nextTimeIndex - 1]
	local nextTime = timeList[self.nextTimeIndex]

	if not prevTime then
		return nextTime
	end

	local currentTime = self.currentTime
	local prevDelta = math.abs(currentTime - prevTime)
	local nextDelta = math.abs(currentTime - nextTime)

	return prevDelta < nextDelta and prevTime or nextTime
end

return TimeEngine
