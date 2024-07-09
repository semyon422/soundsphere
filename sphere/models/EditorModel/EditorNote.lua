local class = require("class")
local table_util = require("table_util")

---@class sphere.EditorNote
---@operator call: sphere.EditorNote
local EditorNote = class()

---@param absoluteTime number
---@param column ncdk2.Column
---@return sphere.EditorNote?
function EditorNote:create(absoluteTime, column) end

---@param t number
---@param part string
---@param deltaColumn number
---@param lockSnap boolean
function EditorNote:grab(t, part, deltaColumn, lockSnap) end

---@param t number
function EditorNote:drop(t) end

---@param t number
function EditorNote:updateGrabbed(t) end

---@param point chartedit.Point
function EditorNote:copy(point) end

---@param point chartedit.Point
function EditorNote:paste(point) end

function EditorNote:remove() end

function EditorNote:add() end

function EditorNote:clone()
	local note = table_util.copy(self)
	setmetatable(note, getmetatable(self))
	return note
end

---@return ncdk2.Note[]
function EditorNote:getNotes()
	return {}
end

return EditorNote
