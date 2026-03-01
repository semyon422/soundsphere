local class = require("class")
local CacheManager = require("sphere.persistence.CacheModel.CacheManager")
local GameDatabase = require("sphere.persistence.CacheModel.GameDatabase")

---@class sphere.CacheWorker
---@operator call: sphere.CacheWorker
---@field remote table
local CacheWorker = class()

function CacheWorker:init()
	local LoveFilesystem = require("fs.LoveFilesystem")
	self.gdb = GameDatabase()
	self.gdb:load()
	self.cacheManager = CacheManager(self.gdb, LoveFilesystem(), love.filesystem.getWorkingDirectory())
	self.errors = {}
	
	local last_update = 0
	-- Override checkProgress to send updates via remote
	function self.cacheManager.checkProgress(manager)
		if #manager.errors > 0 then
			for _, err in ipairs(manager.errors) do
				table.insert(self.errors, err)
			end
			manager.errors = {}
		end

		local time = love.timer.getTime()
		if time - last_update > 0.05 or #self.errors > 0 then
			self.remote.updateProgress(manager.state, manager.chartfiles_count, manager.chartfiles_current, self.errors)
			self.errors = {}
			last_update = time
		end
		
		if self.needStop then
			manager.needStop = true
			self.needStop = false
		end
	end
end

function CacheWorker:unload()
	if self.gdb then
		self.gdb:unload()
		self.gdb = nil
	end
end

function CacheWorker:computeCacheLocation(path, location_id)
	self.cacheManager:computeCacheLocation(path, location_id)
end

function CacheWorker:computeChartdiffs()
	self.cacheManager:computeChartdiffs()
end

function CacheWorker:computeIncompleteChartdiffs(prefer_preview)
	self.cacheManager:computeIncompleteChartdiffs(prefer_preview)
end

function CacheWorker:computeChartplays()
	self.cacheManager:computeChartplays()
end

function CacheWorker:stopTask()
	self.needStop = true
end

return CacheWorker
