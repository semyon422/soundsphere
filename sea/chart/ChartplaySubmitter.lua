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

---@param remote sea.ISubmissionServerRemote
---@param hash string
---@return true?
---@return string?
function ChartplaySubmitter:submitChartfileData(remote, hash)
	local file, err = self.chartfilesReader:getFile(hash)
	if not file then
		return nil, err
	end

	local _hash = md5.sumhexa(file.data)
	if _hash ~= hash then
		return nil, "invalid hash"
	end

	-- submit chartfile and data
	local ok, err = remote:submitChartfileData(
		hash,
		file.name,
		#file.data,
		file.data
	)

	if not ok then
		-- show error
		return nil, err
	end

	return true
end

---@param remote sea.ISubmissionServerRemote
---@param events_hash string
---@return true?
---@return string?
function ChartplaySubmitter:submitEventsData(remote, events_hash)
	local file, err = self.replayfileReader:getFile(events_hash)
	if not file then
		return nil, err
	end

	local _hash = md5.sumhexa(file.data)
	if _hash ~= events_hash then
		return nil, "invalid hash"
	end

	local ok, err = remote:submitEventsData(
		events_hash,
		#file.data,
		file.data
	)

	if not ok then
		-- show error
		return nil, err
	end

	return true
end

return ChartplaySubmitter
