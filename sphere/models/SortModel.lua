local Class = require("Class")

local function sort(...)
	local fields = {...}
	for i, field in ipairs(fields) do
		fields[i] = "noteChartDatas." .. field .. " ASC"
	end
	return table.concat(fields, ",")
end

local SortModel = Class:new()

SortModel.getOrderBy = function(self)
	local f = self.sortItemsFunctions[self.name]
	return f[1], f[2]
end

SortModel.sortItemsFunctions = {
	id = {sort("id"), true},
	title = {sort("title", "artist", "creator", "inputMode", "difficulty", "name", "id"), true},
	artist = {sort("artist", "title", "creator", "inputMode", "difficulty", "name", "id"), true},
	difficulty = {sort("difficulty", "name", "id"), false},
	level = {sort("level", "id"), false},
	length = {sort("length", "id"), false},
	bpm = {sort("bpm", "id"), false},
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
