local class = require("class")

---@class sea.ChartplaySubmitter
---@operator call: sea.ChartplaySubmitter
local ChartplaySubmitter = class()

---@param remote sea.ISubmissionServerRemote
---@param hash string
---@return true?
---@return string?
function ChartplaySubmitter:requireChartfileData(remote, hash)
	---@type sea.Chartfile
	local chartfile
	local data = ""

	-- submit chartfile and data
end

---@param remote sea.ISubmissionServerRemote
---@param events_hash string
---@return true?
---@return string?
function ChartplaySubmitter:requireEventsData(remote, events_hash)

	-- submit events
end

return ChartplaySubmitter
