local class = require("class")
local ITaskContext = require("sphere.persistence.CacheModel.ITaskContext")

---@class sphere.FakeTaskContext: sphere.ITaskContext
---@operator call: sphere.FakeTaskContext
local FakeTaskContext = ITaskContext + {}

function FakeTaskContext:new()
	self.actions = {}
	self.charts = {}
end

function FakeTaskContext:getChartsByHash(hash)
	table.insert(self.actions, {"getChartsByHash", hash})
	local res = self.charts[hash]
	if res then
		return res
	end
	return nil, "not found"
end

function FakeTaskContext:checkProgress(state, count, current)
	table.insert(self.actions, {"checkProgress", state, count, current})
end

function FakeTaskContext:shouldStop()
	return false
end

function FakeTaskContext:addError(err)
	table.insert(self.actions, {"addError", err})
end

function FakeTaskContext:dbBegin()
	table.insert(self.actions, {"dbBegin"})
end

function FakeTaskContext:dbCommit()
	table.insert(self.actions, {"dbCommit"})
end

return FakeTaskContext
