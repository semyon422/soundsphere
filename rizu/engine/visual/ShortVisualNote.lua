local VisualNote = require("rizu.engine.visual.VisualNote")

---@class rizu.ShortVisualNote: rizu.VisualNote
---@operator call: rizu.ShortVisualNote
local ShortVisualNote = VisualNote + {}

ShortVisualNote.type = "short"

function ShortVisualNote:update()
	local info = self.visual_info

	local visualPoint = self.linked_note.startNote.visualPoint
	local visualTime = self:getVisualTime(visualPoint)

	self.start_dt = (info.time - visualTime - info.visual_offset) * info.rate
end

ShortVisualNote.__lt = VisualNote.__lt

return ShortVisualNote
