local Note = require("ncdk2.notes.Note")

---@alias notechart.NoteType
---| "tap"
---| "hold"
---| "laser"
---| "drumroll"
---| "mine"
---| "shade"
---| "fake"
---| "sample"
---| "sprite"

---@class notechart.Note: ncdk2.Note
---@operator call: notechart.Note
---@field type notechart.NoteType
---@field data {sounds: {[1]: string, [2]: number}[]?, images: string[]?}
local _Note = Note + {}

_Note.__tostring = Note.__tostring
_Note.__eq = Note.__eq
_Note.__lt = Note.__lt

return _Note
