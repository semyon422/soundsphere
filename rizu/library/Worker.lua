local class = require("class")
local Processor = require("rizu.library.Processor")
local Database = require("rizu.library.Database")

---@class rizu.library.Worker
---@operator call: rizu.library.Worker
---@field remote table
local Worker = class()

function Worker:init()
	local LoveFilesystem = require("fs.LoveFilesystem")
	self.gdb = Database()
	self.gdb:load()
	self.processor = Processor(self.gdb, LoveFilesystem(), love.filesystem.getWorkingDirectory())
	self.errors = {}
	
	local last_update = 0
	-- Override checkProgress to send updates via remote
	function self.processor.checkProgress(processor)
		if #processor.errors > 0 then
			for _, err in ipairs(processor.errors) do
				table.insert(self.errors, err)
			end
			processor.errors = {}
		end

		local time = love.timer.getTime()
		if time - last_update > 0.05 or #self.errors > 0 then
			self.remote.updateProgress(processor.state, processor.chartfiles_count, processor.chartfiles_current, self.errors)
			self.errors = {}
			last_update = time
		end
		
		if self.needStop then
			processor.needStop = true
			self.needStop = false
		end
	end
end

function Worker:unload()
	if self.gdb then
		self.gdb:unload()
		self.gdb = nil
	end
end

function Worker:computeCacheLocation(path, location_id)
	self.processor:computeCacheLocation(path, location_id)
end

function Worker:computeChartdiffs()
	self.processor:computeChartdiffs()
end

function Worker:computeIncompleteChartdiffs(prefer_preview)
	self.processor:computeIncompleteChartdiffs(prefer_preview)
end

function Worker:computeChartplays()
	self.processor:computeChartplays()
end

function Worker:stopTask()
	self.needStop = true
end

return Worker
