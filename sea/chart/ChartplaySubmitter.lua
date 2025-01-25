local class = require("class")
local md5 = require("md5")

---@class sea.ChartplaySubmitter
---@operator call: sea.ChartplaySubmitter
local ChartplaySubmitter = class()

---@param chartfilesReader sea.ChartfilesReader
---@param replayfileReader sea.ReplayfileReader
function ChartplaySubmitter:new(chartfilesReader, replayfileReader)
	self.chartfilesReader = chartfilesReader
	self.replayfileReader = replayfileReader
end

---@param hash string
---@return {name: string, data: string}?
---@return string?
function ChartplaySubmitter:getChartfileData(hash)
	local file, err = self.chartfilesReader:getFile(hash)
	if not file then
		return nil, err
	end

	if md5.sumhexa(file.data) ~= hash then
		return nil, "invalid hash"
	end

	return file
end

---@param events_hash string
---@return string?
---@return string?
function ChartplaySubmitter:getEventsData(events_hash)
	local file, err = self.replayfileReader:getFile(events_hash)
	if not file then
		return nil, err
	end

	if md5.sumhexa(file.data) ~= events_hash then
		return nil, "invalid hash"
	end

	return file.data
end

return ChartplaySubmitter
