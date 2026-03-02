local class = require("class")
local table_util = require("table_util")

---@class rizu.select.SelectionQueryBuilder
---@operator call: rizu.select.SelectionQueryBuilder
local SelectionQueryBuilder = class()

---@param configModel sphere.ConfigModel
---@param sortModel sphere.SortModel
---@param searchModel sphere.SearchModel
---@param filterModel sphere.FilterModel
function SelectionQueryBuilder:new(configModel, sortModel, searchModel, filterModel)
	self.configModel = configModel
	self.sortModel = sortModel
	self.searchModel = searchModel
	self.filterModel = filterModel
end

---@param config table The 'select' config from configModel
---@param collectionItem table? Current collection item
---@return table params
function SelectionQueryBuilder:build(config, collectionItem)
	local settings_select = self.configModel.configs.settings.select
	local params = {}

	-- Sorting
	local order, group_allowed = self.sortModel:getOrder(config.sortFunction)
	params.order = table_util.copy(order)
	table.insert(params.order, "chartmeta_id")

	-- Grouping (Collapse)
	local group = group_allowed and settings_select.collapse and settings_select.chartviews_table == "chartviews"
	if group then
		params.group = {"chartfile_set_id"}
	end

	-- Conditions (Search & Filters)
	local where, lamp = self.searchModel:getConditions()
	table_util.append(where, self.filterModel.combined_filters)

	-- Collection Filtering
	if collectionItem then
		local path = collectionItem.path
		if path then
			where.set_dir__startswith = path
		end
		where.location_id = collectionItem.location_id
	end

	params.where = where
	params.lamp = lamp
	params.difficulty = settings_select.diff_column
	params.chartviews_table = settings_select.chartviews_table

	return params
end

return SelectionQueryBuilder
