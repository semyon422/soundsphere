local class = require("class")

---@alias sea.TimingObjectValues {hit: {[1]: number, [2]: number}, miss: {[1]: number, [2]: number}}

-- TODO: user NoteType+weight as key

---@class sea.TimingValues
---@operator call: sea.TimingValues
---@field ShortNote sea.TimingObjectValues
---@field LongNoteStart sea.TimingObjectValues
---@field LongNoteEnd sea.TimingObjectValues
local TimingValues = class()

function TimingValues:new()
	self:setSimple(0, 0)
end

---@param h number
---@param m number
---@return sea.TimingValues
function TimingValues:setSimple(h, m)
	self.ShortNote = {hit = {h, h}, miss = {m, m}}
	self.LongNoteStart = {hit = {h, h}, miss = {m, m}}
	self.LongNoteEnd = {hit = {h, h}, miss = {m, m}}
	return self
end

return TimingValues
