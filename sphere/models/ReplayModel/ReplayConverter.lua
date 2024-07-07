local class = require("class")
local ModifierModel = require("sphere.models.ModifierModel")

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

---@param replay table
function ReplayConverter:convertTimings(replay)
	local timings = replay.timings
	if not timings then
		replay.timings = self.oldTimings
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
---@param replay table
---@return boolean
function ReplayConverter:convertModifier(c, replay)
	if c.value == nil then
		for k, v in pairs(c) do
			if k ~= "name" and k ~= "version" and k ~= "id" then
				c.value = v
			end
		end
	end

	if c.name then
		-- deleted modifiers
		if c.name == "TimeRateQ" then
			replay.rate = replay.rate * 2 ^ (0.1 * c.value)
		elseif c.name == "TimeRateX" then
			replay.rate = replay.rate * c.value
		elseif c.name == "ConstSpeed" then
			replay.const = true
		elseif c.name == "SpeedMode" and c.value == "constant" then
			replay.const = true
		end

		if not replay.timings then
			if c.name == "Automap" then
				c.old = true
			elseif c.name == "MultiOverPlay" then
				c.value = c.value + 1
			elseif c.name == "MultiplePlay" then
				c.value = c.value + 1
			end
		end

		c.id = ModifierModel.Modifiers[c.name]
		if not c.id then
			return false
		end
		c.name = nil

		return true
	end

	if c.value == nil then
		return true
	end
	if c.value == false then
		return false
	end

	return true
end

---@param replay table
function ReplayConverter:convertModifiers(replay)
	local new_modifiers = {}
	for _, c in ipairs(replay.modifiers) do
		if self:convertModifier(c, replay) then
			table.insert(new_modifiers, c)
		end
	end
	replay.modifiers = new_modifiers
	ModifierModel:fixOldFormat(replay.modifiers)
end

---@param replay table
function ReplayConverter:convert(replay)
	replay.rate = replay.rate or 1
	if not replay.const then
		replay.const = false
	end
	if replay.modifiers then
		self:convertModifiers(replay)
	end
	replay.modifiers = replay.modifiers or {}
	self:convertTimings(replay)
end

return ReplayConverter
