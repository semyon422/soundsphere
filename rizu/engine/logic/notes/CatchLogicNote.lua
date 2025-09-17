local LogicNote = require("rizu.engine.logic.notes.LogicNote")

---@class rizu.CatchLogicNote: rizu.LogicNote
---@operator call: rizu.CatchLogicNote
local CatchLogicNote = LogicNote + {}

CatchLogicNote.is_bottom = true

---@param note ncdk2.LinkedNote
---@param logic_info rizu.LogicInfo
function CatchLogicNote:new(note, logic_info)
	assert(note:getType() == "catch")
	assert(note:isShort())

	LogicNote.new(self, note, logic_info)
end

---@return boolean
function CatchLogicNote:isActive()
	return self.state == "clear"
end

---@param value any
function CatchLogicNote:input(value)
	self.input_value = value
end

function CatchLogicNote:update()
	if self:getDeltaTime() < 0 then
		return
	end

	if not self.input_value then
		self:switchState("missed")
		return
	end

	self:switchState("passed")
end

---@return number
function CatchLogicNote:getStartTime()
	return self.note:getStartTime()
end

---@param state rizu.TapLogicNoteState
function CatchLogicNote:switchState(state)
	local old_state = self.state
	self.state = state

	-- send to event score engine

	self.observable:send({
		delta_time = 0,
		old_state = old_state,
		new_state = state,
	})
end

CatchLogicNote.__lt = LogicNote.__lt

return CatchLogicNote
