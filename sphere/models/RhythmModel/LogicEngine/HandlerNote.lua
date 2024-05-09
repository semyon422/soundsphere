local class = require("class")

---@class sphere.HandlerNote
---@operator call: sphere.HandlerNote
---@field note sphere.LogicalNote
local HandlerNote = class()

---@param note ncdk2.Note
---@param column number
function HandlerNote:new(note, column)
	self._note = note
	self.column = column
end

---@param a sphere.HandlerNote
---@param b sphere.HandlerNote
---@return boolean
function HandlerNote.__lt(a, b)
	return a._note.visualPoint.point.absoluteTime < b._note.visualPoint.point.absoluteTime
end

return HandlerNote
