local Class = require("Class")

local ReplayConverter = Class:new()

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

ReplayConverter.convertTimings = function(self, object)
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

ReplayConverter.convertModifier = function(self, c, object)
	if c.value == nil then
		for k, v in pairs(c) do
			if k ~= "name" then
				c.value = v
			end
		end
	end
	if c.value == nil then
		c.value = true
		return
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
end

ReplayConverter.convertModifiers = function(self, object)
	for _, c in ipairs(object.modifiers) do
		self:convertModifier(c, object)
	end
end

ReplayConverter.convert = function(self, object)
	if object.modifiers then
		self:convertModifiers(object)
	end

	self:convertTimings(object)
end

return ReplayConverter
