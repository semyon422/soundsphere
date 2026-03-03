local class = require("class")
local Processor = require("rizu.library.Processor")
local Database = require("rizu.library.Database")
local LoveFilesystem = require("fs.LoveFilesystem")

---@class rizu.library.Worker
---@operator call: rizu.library.Worker
local Worker = class()

---@param library rizu.library.Library
function Worker:new(library)
	self.library = library
	self.db = Database()
	self.processor = Processor(self.db, LoveFilesystem(), love.filesystem.getWorkingDirectory())
	self.errors = {}
end

function Worker:load()
	self.db:load()

	function self.processor.checkProgress(processor)
		if #processor.errors > 0 then
			for _, err in ipairs(processor.errors) do
				table.insert(self.errors, err)
			end
			processor.errors = {}
		end

		self.library:updateProgress(processor.state, processor.chartfiles_count, processor.chartfiles_current, self.errors)
		self.errors = {}

		if self.needStop then
			processor.needStop = true
			self.needStop = false
		end
	end
end

function Worker:unload()
	self.db:unload()
end

function Worker:stopTask()
	self.needStop = true
end

function Worker:computeLocation(path, location_id)
	self.processor:computeLocation(path, location_id)
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

return Worker
