local class = require("class")

---@class refchart.Note
---@operator call: refchart.Note
---@field point refchart.VisualPointReference
---@field column ncdk2.Column
---@field type ncdk2.NoteType
---@field weight integer
local Note = class()

---@param note ncdk2.Note
---@param point refchart.VisualPointReference
function Note:new(note, point)
	self.point = point
	self.column = note.column
	self.type = note.type
	self.weight = note.weight
	self.data = note.data
end

return Note
