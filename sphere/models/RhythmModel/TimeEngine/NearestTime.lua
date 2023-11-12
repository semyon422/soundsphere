local class = require("class")

---@class sphere.NearestTime
---@operator call: sphere.NearestTime
local NearestTime = class()

NearestTime.speedThreshold = 10
NearestTime.speedWindow = 0.01

---@param window number
function NearestTime:new(window)
	self.window = window
	self.timeList = {}
	self.currentIndex = 1
end

---@param noteChart ncdk.NoteChart
function NearestTime:loadTimePoints(noteChart)
	local timeList = {}

	local layerData = noteChart:getLayerData(1)
	local timePointList = layerData.timePointList

	local th = self.speedThreshold
	for i = 1, #timePointList - 1 do
		local tp = timePointList[i]
		local next_tp = timePointList[i + 1]

		if tp.currentSpeed <= th and next_tp.currentSpeed > th then
			table.insert(timeList, tp.absoluteTime)
		end
		if tp.currentSpeed > th and next_tp.currentSpeed <= th then
			table.insert(timeList, tp.absoluteTime)
		end
	end
	for i = 1, #timeList - 1 do
		assert(timeList[i] ~= timeList[i + 1])
	end

	self.timeList = timeList
	self.currentIndex = 1
end

---@param currentTime number
function NearestTime:updatePosition(currentTime)
	local timeList = self.timeList
	while timeList[self.currentIndex + 1] and currentTime >= timeList[self.currentIndex + 1] do
		self.currentIndex = self.currentIndex + 1
	end
	while timeList[self.currentIndex - 1] and currentTime < timeList[self.currentIndex] do
		self.currentIndex = self.currentIndex - 1
	end
end

---@param currentTime number
---@return number?
function NearestTime:getNextTime(currentTime)
	self:updatePosition(currentTime)
	return self.timeList[self.currentIndex + 1]
end

---@param currentTime number
---@return number?
function NearestTime:getPrevTime(currentTime)
	self:updatePosition(currentTime)
	local ct = self.timeList[self.currentIndex]
	if ct == currentTime then
		return self.timeList[self.currentIndex - 1]
	end
	return ct
end

---@param currentTime number
---@return number?
---@return boolean?
function NearestTime:getTime(currentTime)
	local timeList = self.timeList
	self:updatePosition(currentTime)

	local prevTime = timeList[self.currentIndex]
	local nextTime = timeList[self.currentIndex + 1]

	if not prevTime or not nextTime then
		return
	end

	if not prevTime then
		return nextTime
	end

	if prevTime > currentTime then
		return
	end

	if self.currentIndex % 2 == 1 and nextTime - prevTime <= self.speedWindow then
		return prevTime, true
	end

	local prevDelta = math.abs(currentTime - prevTime)
	local nextDelta = math.abs(currentTime - nextTime)

	return prevDelta < nextDelta and prevTime or nextTime
end

---@param current number
---@return number
function NearestTime:getVisualTime(current)
	local nearest, force = self:getTime(current)
	if nearest and (force or math.abs(current - nearest) <= self.window) then
		return nearest
	end
	return current
end

return NearestTime
