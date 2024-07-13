local class = require("class")

---@class sphere.LogicalNote
---@operator call: sphere.LogicalNote
---@field logicEngine sphere.LogicEngine
local LogicalNote = class()

LogicalNote.state = ""

---@return string
function LogicalNote:getTimeState()
	return "none"
end

---@param config table
---@return number
function LogicalNote:getLastTimeFromConfig(config)
	return math.max(config.hit[2], config.miss[2])
end

---@param config table
---@return number
function LogicalNote:getFirstTimeFromConfig(config)
	return math.min(config.hit[1], config.miss[1])
end

---@param config table
---@param deltaTime number
---@return string
function LogicalNote:getTimeStateFromConfig(config, deltaTime)
	local hit, miss = config.hit, config.miss
	if deltaTime >= hit[1] and deltaTime <= hit[2] then
		return "exactly"
	elseif deltaTime >= miss[1] and deltaTime < hit[1] then
		return "early"
	elseif deltaTime > hit[2] and deltaTime <= miss[2] then
		return "late"
	elseif deltaTime < miss[1] then
		return "too early"
	elseif deltaTime > miss[2] then
		return "too late"
	end
	return "unknown"
end

---@param name string
function LogicalNote:switchState(name)
	self.state = name
end

---@return sphere.LogicalNote?
function LogicalNote:getNext()
	return self.nextNote
end

---@return sphere.LogicalNote?
function LogicalNote:getNextPlayable()
	if self.nextPlayable then
		return self.nextPlayable
	end

	local nextNote = self:getNext()
	while nextNote and not nextNote.isPlayable do
		nextNote = nextNote:getNext()
	end

	if nextNote then
		self.nextPlayable = nextNote
	end

	return nextNote
end

function LogicalNote:next()
	self.ended = true
end

---@param side string?
---@return number
function LogicalNote:getNoteTime(side)
	local offset = 0
	if self.isPlayable then
		offset = self.logicEngine:getInputOffset()
	end
	return self.startNote:getTime() + offset
end

---@return boolean
function LogicalNote:isHere()
	return self:getNoteTime() <= self.logicEngine:getEventTime()
end

---@return boolean
function LogicalNote:isReachable()
	return true
end

---@return number
function LogicalNote:getEventTime()
	return self.eventTime or self.logicEngine:getEventTime()
end

function LogicalNote:update() end

return LogicalNote
