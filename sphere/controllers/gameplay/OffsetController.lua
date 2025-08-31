local class = require("class")
local math_util = require("math_util")
local ChartmetaUserData = require("sea.chart.ChartmetaUserData")

---@class sphere.OffsetController
---@operator call: sphere.OffsetController
local OffsetController = class()

---@param cacheModel sphere.CacheModel
---@param computeContext sea.ComputeContext
---@param offsetModel sphere.OffsetModel
---@param rhythmModel sphere.RhythmModel
---@param notificationModel sphere.NotificationModel
function OffsetController:new(
	cacheModel,
	computeContext,
	offsetModel,
	rhythmModel,
	notificationModel
)
	self.cacheModel = cacheModel
	self.computeContext = computeContext
	self.offsetModel = offsetModel
	self.rhythmModel = rhythmModel
	self.notificationModel = notificationModel
end

function OffsetController:updateOffsets()
	local chartmeta = assert(self.computeContext.chartmeta)
	local input_offset, visual_offset = self.offsetModel:getInputVisual(chartmeta.hash, chartmeta.index)

	self.rhythmModel:setInputOffset(input_offset)
	self.rhythmModel:setVisualOffset(visual_offset)
end

---@param delta number
function OffsetController:increaseLocalOffset(delta)
	local chartsRepo = self.cacheModel.chartsRepo
	local chartmeta = assert(self.computeContext.chartmeta)

	local chartmeta_user_data = chartsRepo:getUserChartmetaUserData(chartmeta.hash, chartmeta.index, 1)
	if not chartmeta_user_data then
		chartmeta_user_data = ChartmetaUserData()
		chartmeta_user_data.user_id = 1
		chartmeta_user_data.hash = chartmeta.hash
		chartmeta_user_data.index = chartmeta.index
		chartmeta_user_data = chartsRepo:createChartmetaUserData(chartmeta_user_data)
	end

	chartmeta_user_data.local_offset = math_util.round((chartmeta_user_data.local_offset or 0) + delta, delta)
	chartsRepo:updateChartmetaUserData(chartmeta_user_data)

	self.notificationModel:notify("local offset: " .. chartmeta_user_data.local_offset * 1000 .. "ms")
	self:updateOffsets()
end

function OffsetController:resetLocalOffset()
	local chartsRepo = self.cacheModel.chartsRepo
	local chartmeta = assert(self.computeContext.chartmeta)

	local chartmeta_user_data = chartsRepo:getUserChartmetaUserData(chartmeta.hash, chartmeta.index, 1)
	if not chartmeta_user_data then
		return
	end

	chartmeta_user_data.local_offset = nil
	chartsRepo:updateChartmetaUserDataFull(chartmeta_user_data)

	self.notificationModel:notify("local offset reseted")

	self:updateOffsets()
end

return OffsetController
