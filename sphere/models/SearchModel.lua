local class = require("class")
local erfunc = require("libchart.erfunc")

---@class sphere.SearchModel
---@operator call: sphere.SearchModel
local SearchModel = class()

SearchModel.filterString = ""
SearchModel.lampString = ""
SearchModel.collection = {path = ""}
SearchModel.stateCounter = 1

---@param searchMode string
---@param text string
function SearchModel:setSearchString(searchMode, text)
	if searchMode == "filter" then
		self:setFilterString(text)
	else
		self:setLampString(text)
	end
end

---@param text string
function SearchModel:setFilterString(text)
	if text ~= self.filterString then
		self.stateCounter = self.stateCounter + 1
	end
	self.filterString = text
end

---@param text string
function SearchModel:setLampString(text)
	if text ~= self.lampString then
		self.stateCounter = self.stateCounter + 1
	end
	self.lampString = text
end

---@param collection any?
function SearchModel:setCollection(collection)
	self.collection = collection
end

local number_fields = {
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
		keys = {"noteCount", "nc"},
		field = "noteChartDatas.noteCount",
	},
	{
		keys = {"level", "lv"},
		field = "noteChartDatas.level",
	},
	{
		keys = {"longNotes", "ln"},
		field = "noteChartDatas.longNoteRatio",
		transform = function(self, v)
			return v / 100
		end
	},
	{
		keys = {"missCount", "m"},
		field = "scores.missCount",
	},
	{
		keys = {"accuracy", "a"},
		field = "scores.accuracy",
		transform = function(self, v)
			return v / 1000
		end
	},
	{
		keys = {"score", "s"},
		field = "scores.accuracy",
		flip = true,
		transform = function(self, v)
			if not tonumber(v) then
				return
			end
			v = tonumber(v)
			if v <= 0 then return 1000 end
			if v >= 10000 then return 0 end
			local window = self.configModel.configs.settings.gameplay.ratingHitTimingWindow
			local accuracy = window / (erfunc.erfinv(v / 10000) * math.sqrt(2))
			if accuracy ~= accuracy or math.abs(accuracy) == math.huge then
				return 0
			end
			return accuracy
		end,
	},
}

local fields_map = {}
for _, config in ipairs(number_fields) do
	for _, k in ipairs(config.keys) do
		assert(not fields_map[k], "duplicate key: " .. k)
		fields_map[k] = config
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

local operators = {
	["="] = "eq",
	["~="] = "ne",
	["!="] = "ne",
	[">"] = "gt",
	["<"] = "lt",
	[">="] = "gte",
	["<="] = "lte",
}

local inverse_operators = {
	eq = "ne",
	ne = "eq",
	gt = "lte",
	lt = "gte",
	gte = "lt",
	lte = "gt",
}

local flip_operators = {
	gt = "lt",
	lt = "gt",
	gte = "lte",
	lte = "gte",
}

---@param s string
---@param cond table?
---@return table
function SearchModel:transformSearchString(s, cond)
	cond = cond or {}

	for _, _s in ipairs(s:split(" ")) do
		local key, operator, value = _s:match("^(.-)([=><~!]+)(.+)$")
		if _s == "!" or _s == "~" then
			cond.scoreId__isnull = true
		elseif key and operators[operator] then
			local config = fields_map[key]
			operator = operators[operator]
			if config then
				if config.inverse then
					operator = inverse_operators[operator] or operator
				end
				if config.flip then
					operator = flip_operators[operator] or operator
				end
				if config.transform then
					value = config.transform(self, value)
				else
					value = tonumber(value)
				end
				if value then
					cond[config.field .. "__" .. operator] = value
				end
			end
		elseif not key and _s ~= "" then
			local _cond = {"or"}
			for _, k in ipairs(textFields) do
				_cond["noteChartDatas." .. k .. "__contains"] = _s
			end
			table.insert(cond, _cond)
		end
	end

	return cond
end

---@return table?
function SearchModel:getFilter()
	local configs = self.configModel.configs
	local filters = configs.filters
	local select = configs.select

	for _, filter in ipairs(filters.notechart) do
		if filter.name == select.filterName then
			return filter
		end
	end
end

---@return table
---@return table?
function SearchModel:getConditions()
	local configs = self.configModel.configs
	local settings = configs.settings

	local cond = {}
	local path = self.collection.path .. "/"

	cond.path__startswith = path

	if not settings.miscellaneous.showNonManiaCharts then
		cond["noteChartDatas.inputMode__notin"] = {"1osu", "1taiko", "1fruits"}
	end

	local filterString = self.filterString
	local filter = self:getFilter()
	if filter then
		if filter.string then
			filterString = filterString .. " " .. filter.string
		end
		if filter.condition then
			table.insert(cond, filter.condition)
		end
	end

	if self.lampString == "" then
		return self:transformSearchString(filterString, cond)
	end

	return
		self:transformSearchString(filterString, cond),
		self:transformSearchString(self.lampString)
end

return SearchModel
