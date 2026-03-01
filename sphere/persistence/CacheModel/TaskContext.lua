local class = require("class")
local ITaskContext = require("sphere.persistence.CacheModel.ITaskContext")

---@class sphere.TaskContext: sphere.ITaskContext
---@operator call: sphere.TaskContext
local TaskContext = ITaskContext + {}

---@param manager sphere.CacheManager
function TaskContext:new(manager)
	self.manager = manager
end

function TaskContext:getChartsByHash(hash)
	return self.manager:getChartsByHash(hash)
end

function TaskContext:checkProgress(state, count, current)
	self.manager.state = state
	self.manager.chartfiles_count = count
	self.manager.chartfiles_current = current
	self.manager:checkProgress()
end

function TaskContext:shouldStop()
	self.manager:checkProgress()
	return self.manager.needStop == true
end

function TaskContext:addError(err)
	self.manager:addError(err)
end

function TaskContext:dbBegin()
	self.manager:begin()
end

function TaskContext:dbCommit()
	self.manager:commit()
end

return TaskContext
