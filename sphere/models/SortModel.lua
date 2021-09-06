local Class = require("aqua.util.Class")

local SortModel = Class:new()

SortModel.getSortFunction = function(self)
	return self.sortItemsFunctions[self.name]
end

local title = function(a, b)
	return a.title < b.title
end

local artist = function(a, b)
	return a.artist < b.artist
end

local creator = function(a, b)
	return a.creator < b.creator
end

local difficulty = function(a, b)
	return a.difficulty < b.difficulty
end

SortModel.sortItemsFunctions = {
	title = function(a, b)
		if a.title ~= b.title then
			return title(a, b)
		elseif a.artist ~= b.artist then
			return artist(a, b)
		elseif a.creator ~= b.creator then
			return creator(a, b)
		end
		return difficulty(a, b)
	end,
	artist = function(a, b)
		if a.artist ~= b.artist then
			return artist(a, b)
		elseif a.title ~= b.title then
			return title(a, b)
		elseif a.creator ~= b.creator then
			return creator(a, b)
		end
		return difficulty(a, b)
	end,
	difficulty = difficulty,
}

SortModel.name = "title"
SortModel.names = {"title", "artist", "difficulty"}

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
