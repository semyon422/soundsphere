local Class = require("aqua.util.Class")
local erfunc = require("libchart.erfunc")

local SearchModel = Class:new()

SearchModel.searchString = ""
SearchModel.searchFilter = ""
SearchModel.searchLamp = ""
SearchModel.searchMode = "filter"
SearchModel.collection = {path = ""}
SearchModel.stateCounter = 1

SearchModel.transformScoreEntry = function(self, scoreEntry)
	local enps = scoreEntry.rating * scoreEntry.accuracy
	scoreEntry.rating = enps * erfunc.erf(self.ratingHitTimingWindow / (scoreEntry.accuracy * math.sqrt(2)))
	return scoreEntry
end

SearchModel.setSearchString = function(self, text)
	if self.searchMode == "filter" then
		self:setSearchFilter(text)
	else
		self:setSearchLamp(text)
	end
	self.stateCounter = self.stateCounter + 1
end

SearchModel.setSearchFilter = function(self, text)
	self.searchFilter = text
	self.searchString = text
end

SearchModel.setSearchLamp = function(self, text)
	self.searchLamp = text
	self.searchString = text
end

SearchModel.setSearchMode = function(self, searchMode)
	self.searchMode = searchMode
	self.searchString = searchMode == "filter" and self.searchFilter or self.searchLamp
end

SearchModel.switchSearchMode = function(self)
	self:setSearchMode(self.searchMode == "filter" and "lamp" or "filter")
end

SearchModel.setCollection = function(self, collection)
	self.collection = collection
end

local fieldList = {
	"hash",
	"artist",
	"title",
	"name",
	"source",
	"tags",
	"creator",
	"inputMode",
	"difficulty",
	"bpm",
}

local fieldMap = {}
for _, key in ipairs(fieldList) do
	fieldMap[key] = true
end

local fieldLikePattern = {}
for _, key in ipairs(fieldList) do
	table.insert(fieldLikePattern, ("noteChartDatas.%s LIKE <substring>"):format(key))
end
fieldLikePattern = "(" .. table.concat(fieldLikePattern, " OR ") .. ")"

local operators = {"=", ">", "<", ">=", "<=", "~=", "!="}
local operatorsMap = {}
for _, operator in ipairs(operators) do
	operatorsMap[operator] = operator
	if operator == "~=" then
		operatorsMap[operator] = "!="
	end
end

SearchModel.transformSearchString = function(self, s)
	local searchString = s
	local conditions = {}

	for _, searchSubString in ipairs(searchString:split(" ")) do
		local key, operator, value = searchSubString:match("^(.-)([=><~!]+)(.+)$")
		if key and fieldMap[key] and operatorsMap[operator] and tonumber(value) then
			table.insert(conditions, ("%s %s %s"):format(key, operatorsMap[operator], tonumber(value)))
		elseif not key and searchSubString ~= "" then
			table.insert(conditions, (fieldLikePattern:gsub("<substring>", ("%q"):format("%%" .. searchSubString .. "%%"))))
		end
	end

	return table.concat(conditions, " AND ")
end

SearchModel.getConditions = function(self)
	if self.searchLamp == "" then
		return self:transformSearchString(self.searchFilter)
	end

	return
		self:transformSearchString(self.searchFilter),
		self:transformSearchString(self.searchLamp)
end

return SearchModel
