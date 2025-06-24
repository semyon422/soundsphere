local class = require("class")

---@class sea.DifftablesServerRemoteValidation: sea.DifftablesServerRemote
---@operator call: sea.DifftablesServerRemoteValidation
local DifftablesServerRemoteValidation = class()

---@param remote sea.DifftablesServerRemote
function DifftablesServerRemoteValidation:new(remote)
	self.remote = remote
end

---@return sea.Difftable[]
function DifftablesServerRemoteValidation:getDifftables()
	return self.remote:getDifftables()
end

---@param difftable_id integer
---@param since integer
---@param limit integer?
---@return sea.DifftableChartmeta[]?
---@return string?
function DifftablesServerRemoteValidation:getDifftableChartmetas(difftable_id, since, limit)
	assert(type(difftable_id) == "number")
	assert(type(since) == "number")
	assert(type(limit) == "number" or type(limit) == "nil")
	return self.remote:getDifftableChartmetas(difftable_id, since, limit)
end

return DifftablesServerRemoteValidation
