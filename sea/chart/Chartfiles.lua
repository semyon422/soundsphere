local class = require("class")
local ChartfilesAccess = require("sea.chart.access.ChartfilesAccess")

---@class sea.Chartfiles
---@operator call: sea.Chartfiles
local Chartfiles = class()

---@param charts_repo sea.IChartsRepo
function Chartfiles:new(charts_repo)
	self.charts_repo = charts_repo
	self.chartfilesAccess = ChartfilesAccess()
end

---@param user sea.User
---@param hash string
---@param name string
---@param size integer
---@param data string
---@return sea.Chartfile?
---@return string?
function Chartfiles:submit(user, hash, name, size, data)
	local can, err = self.chartfilesAccess:canSubmit(user)
	if not can then
		return nil, err
	end

	local chartfile = self.charts_repo:getChartfileByHash(hash)
	if not chartfile then
		return nil, "missing chartfile"
	end

	chartfile.submitted_at = os.time()

end

return Chartfiles
