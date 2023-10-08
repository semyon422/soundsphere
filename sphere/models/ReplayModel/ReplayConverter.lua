local class = require("class")

---@class sphere.ReplayConverter
---@operator call: sphere.ReplayConverter
local ReplayConverter = class()

ReplayConverter.oldTimings = {
	ShortNote = {
		hit = {-0.12, 0.12},
		miss = {-0.16, 0.12}
	},
	LongNoteStart = {
		hit = {-0.12, 0.12},
		miss = {-0.16, 0.12},
	},
	LongNoteEnd = {
		hit = {-0.12, 0.12},
		miss = {-0.16, 0.12}
	}
}

---@param object table
function ReplayConverter:convertTimings(object)
	local timings = object.timings
	if not timings then
		object.timings = self.oldTimings
		return
	end

	if not timings.ShortNote then
		timings.ShortNote = timings.ShortScoreNote
		timings.LongNoteStart = {
			hit = timings.LongScoreNote.startHit,
			miss = timings.LongScoreNote.startMiss,
		}
		timings.LongNoteEnd = {
			hit = timings.LongScoreNote.endHit,
			miss = timings.LongScoreNote.endMiss,
		}
		timings.ShortScoreNote = nil
		timings.LongScoreNote = nil
	end
	if not timings.LongNoteStart then
		timings.LongNoteStart = {
			hit = timings.LongNote.startHit,
			miss = timings.LongNote.startMiss,
		}
		timings.LongNoteEnd = {
			hit = timings.LongNote.endHit,
			miss = timings.LongNote.endMiss,
		}
		timings.LongNote = nil
	end
end

---@param c table
---@param object table
---@return boolean
function ReplayConverter:convertModifier(c, object)
	if c.value == nil then
		for k, v in pairs(c) do
			if k ~= "name" then
				c.value = v
			end
		end
	end
	if c.value == nil then
		return true
	end
	if c.value == false then
		return false
	end

	if not object.timings then
		if c.name == "Automap" then
			c.old = true
		elseif c.name == "MultiOverPlay" then
			c.value = c.value + 1
		elseif c.name == "MultiplePlay" then
			c.value = c.value + 1
		end
	end

	return true
end

---@param object table
function ReplayConverter:convertModifiers(object)
	local new_modifiers = {}
	for _, c in ipairs(object.modifiers) do
		if self:convertModifier(c, object) then
			table.insert(new_modifiers, c)
		end
	end
	object.modifiers = new_modifiers
end

---@param object table
function ReplayConverter:convert(object)
	if object.modifiers then
		self:convertModifiers(object)
	end

	self:convertTimings(object)
end

return ReplayConverter
