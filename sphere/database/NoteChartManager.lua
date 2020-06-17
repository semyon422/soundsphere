local NoteChartResourceLoader	= require("sphere.database.NoteChartResourceLoader")
local CacheDatabase				= require("sphere.database.CacheDatabase")
local CacheManager				= require("sphere.database.CacheManager")
local ThreadPool				= require("aqua.thread.ThreadPool")
local Log						= require("aqua.util.Log")
local Observable				= require("aqua.util.Observable")

local NoteChartManager = {}

NoteChartManager.init = function(self)
	self.log = Log:new()
	self.log.console = true
	self.log.path = "userdata/NoteChartManager.log"

	self.observable = Observable:new()

	ThreadPool.observable:add(self)

	NoteChartResourceLoader:init()
end

NoteChartManager.load = function(self)
	CacheManager:select()
end

NoteChartManager.send = function(self, event)
	return self.observable:send(event)
end

NoteChartManager.receive = function(self, event)
	if event.name == "CacheProgress" then
		if event.state == 3 then
			self.lock = false
			CacheManager:select()
			self.isUpdating = false
		end
		self:send({
			name = "NoteChartManagerState",
			state = event.state,
			noteChartSetCount = event.noteChartSetCount,
			noteChartCount = event.noteChartCount,
			cachePercent = event.cachePercent
		})
	end
end

NoteChartManager.stopCache = function(self)
	ThreadPool:receive({
		name = "NoteChartManager",
		action = "stop"
	})
end

NoteChartManager.updateCache = function(self, path, force)
	self.lock = true
	if not self.isUpdating then
		self.isUpdating = true
		return ThreadPool:execute(
			[[
				local CacheDatabase				= require("sphere.database.CacheDatabase")
				local CacheManager				= require("sphere.database.CacheManager")

				CacheDatabase:init()
				CacheManager:init()

				CacheManager:generateCacheFull(...)
			]],
			{path, force}
		)
	end
end

return NoteChartManager
