local Class = require("aqua.util.Class")
local erfunc = require("libchart.erfunc")

local SearchModel = Class:new()

SearchModel.searchString = ""
SearchModel.searchFilter = ""
SearchModel.searchLamp = ""
SearchModel.searchMode = "filter"
SearchModel.collection = {path = ""}
SearchModel.stateCounter = 1

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

local numberFields = {
	{
		keys = {"difficulty", "d"},
		field = "noteChartDatas.difficulty",
	},
	{
		keys = {"length", "l"},
		field = "noteChartDatas.length",
		transform = function(self, v)
			if tonumber(v) then
				return tonumber(v)
			end
			local n, s = v:match("(%d+)(%a+)")
			if s == "m" then
				return n * 60
			end
		end,
	},
	{
		keys = {"bpm", "b"},
		field = "noteChartDatas.bpm",
	},
	{
		keys = {"notesCount", "nc"},
		field = "noteChartDatas.notesCount",
	},

	{
		keys = {"accuracy", "a"},
		field = "scores.accuracy * 1000",
	},
	{
		keys = {"score", "s"},
		field = "-scores.accuracy",
		transform = function(self, v)
			if not tonumber(v) then
				return
			end
			local window = self.configModel.configs.settings.gameplay.ratingHitTimingWindow
			local accuracy = window / (erfunc.erfinv(v / 10000) * math.sqrt(2))
			return accuracy == accuracy and -accuracy
		end,
	},
}

local numberFieldsMap = {}
for _, config in ipairs(numberFields) do
	for _, k in ipairs(config.keys) do
		assert(not numberFieldsMap[k], "duplicate key: " .. k)
		numberFieldsMap[k] = config
	end
end

local textFields = {
	"hash",
	"artist",
	"title",
	"name",
	"source",
	"tags",
	"creator",
	"inputMode",
}

local fieldLikePattern = {}
for _, key in ipairs(textFields) do
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

SearchModel.transformSearchString = function(self, s, addCollectionFilter)
	local searchString = s
	local conditions = {}

	if addCollectionFilter then
		table.insert(conditions, ("substr(noteCharts.path, 1, %d) = %q"):format(#self.collection.path, self.collection.path))
	end

	for _, searchSubString in ipairs(searchString:split(" ")) do
		local key, operator, value = searchSubString:match("^(.-)([=><~!]+)(.+)$")
		if key and operatorsMap[operator] then
			local config = numberFieldsMap[key]
			operator = operatorsMap[operator]
			if config then
				if config.transform then
					value = config.transform(self, value)
				else
					value = tonumber(value)
				end
				if value then
					table.insert(conditions, ("%s %s %s"):format(config.field, operator, value))
				end
			end
		elseif not key and searchSubString ~= "" then
			table.insert(conditions, (fieldLikePattern:gsub("<substring>", ("%q"):format("%%" .. searchSubString .. "%%"))))
		end
	end

	return table.concat(conditions, " AND ")
end

SearchModel.getConditions = function(self)
	if self.searchLamp == "" then
		return self:transformSearchString(self.searchFilter, true)
	end

	return
		self:transformSearchString(self.searchFilter, true),
		self:transformSearchString(self.searchLamp)
end

return SearchModel
