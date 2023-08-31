local class = require("class")

---@class sphere.EditorNote
---@operator call: sphere.EditorNote
local EditorNote = class()

---@param absoluteTime number
---@return sphere.EditorNote?
function EditorNote:create(absoluteTime) end

---@param t number
---@param part string
---@param deltaColumn number
---@param lockSnap boolean
function EditorNote:grab(t, part, deltaColumn, lockSnap) end

---@param t number
function EditorNote:drop(t) end

---@param t number
function EditorNote:updateGrabbed(t) end

---@param copyTimePoint ncdk.IntervalTimePoint
function EditorNote:copy(copyTimePoint) end

---@param timePoint ncdk.IntervalTimePoint
function EditorNote:paste(timePoint) end

function EditorNote:remove() end

function EditorNote:add() end

return EditorNote
