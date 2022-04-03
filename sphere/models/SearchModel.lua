local Class = require("aqua.util.Class")

local SearchModel = Class:new()

SearchModel.searchString = ""
SearchModel.searchMode = "hide"
SearchModel.collection = {path = ""}

SearchModel.setSearchString = function(self, text)
	self.searchString = text
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

SearchModel.getConditions = function(self)
	local searchString = self.searchString
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

SearchModel.search = function(self, list)
	local foundMap = {}
	for i = 1, #list do
		foundMap[list[i]] = true
	end
	-- print(self:getConditions())
	return list, foundMap
end

SearchModel.check = function(self, noteChartDataEntry, noteChartEntry, noteChartSetEntry)
	return true
end

return SearchModel
