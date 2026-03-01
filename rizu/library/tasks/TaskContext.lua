local class = require("class")
local ITaskContext = require("rizu.library.tasks.ITaskContext")

---@class rizu.library.TaskContext: rizu.library.ITaskContext
---@operator call: rizu.library.TaskContext
local TaskContext = ITaskContext + {}

---@param libraryProcessor rizu.library.Processor
function TaskContext:new(libraryProcessor)
	self.libraryProcessor = libraryProcessor
end

function TaskContext:getChartsByHash(hash)
	return self.libraryProcessor:getChartsByHash(hash)
end

function TaskContext:checkProgress(state, count, current)
	self.libraryProcessor.state = state
	self.libraryProcessor.chartfiles_count = count
	self.libraryProcessor.chartfiles_current = current
	self.libraryProcessor:checkProgress()
end

function TaskContext:shouldStop()
	self.libraryProcessor:checkProgress()
	return self.libraryProcessor.needStop == true
end

function TaskContext:addError(err)
	self.libraryProcessor:addError(err)
end

function TaskContext:dbBegin()
	self.libraryProcessor:begin()
end

function TaskContext:dbCommit()
	self.libraryProcessor:commit()
end

return TaskContext
