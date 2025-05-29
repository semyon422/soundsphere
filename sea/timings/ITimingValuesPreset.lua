local class = require("class")

---@class sea.ITimingValuesPreset
---@operator call: sea.ITimingValuesPreset
local ITimingValuesPreset = class()

---@param tvs sea.TimingValues
---@return sea.Timings?
---@return sea.Subtimings?
function ITimingValuesPreset:match(tvs) end

return ITimingValuesPreset
