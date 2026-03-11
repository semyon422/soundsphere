local class = require("class")

---@class rizu.dlc.DlcTask
---@operator call: rizu.dlc.DlcTask
local DlcTask = class()

---@param id string|number
---@param provider string
---@param type rizu.dlc.DlcType
---@param metadata table
function DlcTask:new(id, provider, type, metadata)
	self.id = id
	self.provider = provider
	self.type = type
	self.metadata = metadata
	self.status = "queued"
	self.progress = 0
	self.speed = 0
	self.total = 0
	self.size = 0
	self.error = nil
end

return DlcTask
