local Class = require("aqua.util.Class")

local SortModel = Class:new()

SortModel.getSortFunction = function(self)
	return self.sortItemsFunctions[self.name]
end

SortModel.sortItemsFunctions = {
	id = function(a, b)
		return a.id < b.id
	end,
	title = function(a, b)
		if a.title ~= b.title then
			return a.title < b.title
		elseif a.artist ~= b.artist then
			return a.artist < b.artist
		elseif a.creator ~= b.creator then
			return a.creator < b.creator
		elseif a.difficulty ~= b.difficulty then
			return a.difficulty < b.difficulty
		end
		return a.id < b.id
	end,
	artist = function(a, b)
		if a.artist ~= b.artist then
			return a.artist < b.artist
		elseif a.title ~= b.title then
			return a.title < b.title
		elseif a.creator ~= b.creator then
			return a.creator < b.creator
		elseif a.difficulty ~= b.difficulty then
			return a.difficulty < b.difficulty
		end
		return a.id < b.id
	end,
	difficulty = function(a, b)
		if a.difficulty ~= b.difficulty then
			return a.difficulty < b.difficulty
		end
		return a.id < b.id
	end,
	level = function(a, b)
		if a.level ~= b.level then
			return a.level < b.level
		end
		return a.id < b.id
	end,
	length = function(a, b)
		if a.length ~= b.length then
			return a.length < b.length
		end
		return a.id < b.id
	end,
	bpm = function(a, b)
		if a.bpm ~= b.bpm then
			return a.bpm < b.bpm
		end
		return a.id < b.id
	end,
}

SortModel.name = "title"
SortModel.names = {"id", "title", "artist", "difficulty", "level", "length", "bpm"}

SortModel.toIndexValue = function(self, name)
	for i, currentName in ipairs(self.names) do
		if name == currentName then
			return i
		end
	end
	return 1
end

SortModel.fromIndexValue = function(self, indexValue)
	return self.names[math.min(math.max(indexValue, 1), #self.names)] or ""
end

SortModel.increase = function(self, delta)
	local indexValue = self:toIndexValue(self.name)
	self.name = self:fromIndexValue(indexValue + delta)
end

return SortModel
