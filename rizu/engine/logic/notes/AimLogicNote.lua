local TapLogicNote = require("rizu.engine.logic.notes.TapLogicNote")

---@class rizu.AimLogicNote: rizu.TapLogicNote
---@operator call: rizu.AimLogicNote
local AimLogicNote = TapLogicNote + {}

AimLogicNote.is_bottom = true

---@param note ncdk2.LinkedNote
---@param logic_info rizu.LogicInfo
function AimLogicNote:new(note, logic_info)
	assert(note:getType() == "aim")
	assert(note:isShort())

	TapLogicNote.new(self, note, logic_info)
end

AimLogicNote.__lt = TapLogicNote.__lt

return AimLogicNote
