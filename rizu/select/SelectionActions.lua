local class = require("class")
local Path = require("Path")

---@class rizu.select.SelectionActions
---@operator call: rizu.select.SelectionActions
local SelectionActions = class()

---@param chartSelector rizu.select.ChartSelector
---@param library rizu.library.Library
---@param onlineModel sphere.OnlineModel
function SelectionActions:new(chartSelector, library, onlineModel)
	self.chartSelector = chartSelector
	self.library = library
	self.onlineModel = onlineModel
end

function SelectionActions:openDirectory()
	local chartview = self.chartSelector.chartview
	if not chartview then
		return
	end
	local location = self.library.locationsRepo:selectLocationById(chartview.location_id)
	if not location then
		return
	end

	local dir_path = Path(location.path) .. Path(chartview.dir)

	if not dir_path.absolute then
		local source = love.filesystem.getSource()
		if source:find("^.+%.love$") then
			source = love.filesystem.getSourceBaseDirectory()
		end
		dir_path = Path(source) .. dir_path
	end

	love.system.openURL(tostring(dir_path))
end

function SelectionActions:openWebNotechart()
	local chartview = self.chartSelector.chartview
	if not chartview then
		return
	end

	local hash, index = chartview.hash, chartview.index
	self.onlineModel.onlineNotechartManager:openWebNotechart(hash, index)
end

---@param force boolean?
function SelectionActions:updateCache(force)
	local chartview = self.chartSelector.chartview
	if not chartview then
		return
	end
	self.library:computeLocation(chartview.dir, chartview.location_id)
end

---@param location_id integer
function SelectionActions:updateCacheLocation(location_id)
	local library = self.library
	if not library.isProcessing then
		library:computeLocation(nil, location_id)
	else
		library:stopTask()
	end
end

return SelectionActions
