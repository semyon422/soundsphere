local class = require("class")
local ThreadRemote = require("threadremote.ThreadRemote")
local DlcTask = require("rizu.dlc.DlcTask")
local Observable = require("Observable")

---@class rizu.dlc.DlcManager
---@operator call: rizu.dlc.DlcManager
local DlcManager = class()

---@param library rizu.library.Library
---@param configModel sphere.ConfigModel
function DlcManager:new(library, configModel)
	self.library = library
	self.configModel = configModel
	self.tasks = {} ---@type {[string|number]: rizu.dlc.DlcTask}
	self.is_sync = false
	self.onTaskUpdated = Observable()
	self.onDlcCompletedSignal = Observable()
	self.workingDirectory = love.filesystem.getSource()
end

---@param is_sync boolean
function DlcManager:setSync(is_sync)
	self.is_sync = is_sync
end

function DlcManager:load()
	local osuConfig = self.configModel.configs.urls.osu
	if self.is_sync then
		self.worker = self:createAndLoadWorker(self.workingDirectory, osuConfig)
	else
		self.tr = ThreadRemote("rizu.dlc.DlcManager", self)
		self.worker = self.tr:start(self.createAndLoadWorker, self.workingDirectory, osuConfig)
	end
end

---@param workingDirectory string
---@param osuConfig table?
function DlcManager:createAndLoadWorker(workingDirectory, osuConfig)
	require("preload")
	local DlcWorker = require("rizu.dlc.DlcWorker")
	local worker = DlcWorker(self, workingDirectory, osuConfig)
	return worker
end

function DlcManager:update()
	if self.tr then
		self.tr:update()
	end
end

---@param query string
---@param type rizu.dlc.DlcType
---@param filters table?
---@param provider_name string?
---@return table[]? results, string? error
function DlcManager:search(query, type, filters, provider_name)
	return self.worker:search(query, type, filters, provider_name)
end

---@param id string|number
---@param type rizu.dlc.DlcType
---@param provider_name string?
---@param metadata table?
function DlcManager:download(id, type, provider_name, metadata)
	provider_name = provider_name or "mino"
	if self.tasks[id] then return end

	local task = DlcTask(id, provider_name, type, metadata)
	self.tasks[id] = task
	self.onTaskUpdated:send({task = task})

	coroutine.wrap(function()
		local ok, err = self.worker:download(id, type, provider_name, metadata)
		if not ok then
			task.status = "error"
			task.error = err
			self.onTaskUpdated:send({task = task})
		end
	end)()
end

--- Internal method called by worker via ThreadRemote
---@param id string|number
---@param updates table
function DlcManager:updateTask(id, updates)
	local task = self.tasks[id]
	if not task then return end

	for k, v in pairs(updates) do
		task[k] = v
	end
	self.onTaskUpdated:send({task = task})
end

--- Internal method called by worker via ThreadRemote
---@param id string|number
---@param type rizu.dlc.DlcType
---@param metadata table?
function DlcManager:onDlcCompleted(id, type, metadata)
	self.onDlcCompletedSignal:send({id = id, type = type, metadata = metadata})
	
	if type == "chart" then
		-- Trigger library import
		self.library:computeLocation("downloads", 1)
	end
end

return DlcManager
