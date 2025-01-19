local class = require("class")
local ChartfilesAccess = require("sea.chart.access.ChartfilesAccess")

---@class sea.Chartfiles
---@operator call: sea.Chartfiles
local Chartfiles = class()

---@param chartfilesRepo sea.IChartfilesRepo
function Chartfiles:new(chartfilesRepo)
	self.chartfilesRepo = chartfilesRepo
	self.chartfilesAccess = ChartfilesAccess()
end

---@param user sea.User
---@param file_hash string
---@return sea.Chartfile?
---@return string?
function Chartfiles:submit(user, file_hash)
	local can, err = self.chartfilesAccess:canSubmit(user)
	if not can then
		return nil, err
	end

	local chartfile = self.chartfilesRepo:getChartfileByHash(file_hash)
	if chartfile then
		return nil, "submitted before"
	end

end

return Chartfiles
