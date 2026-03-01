local class = require("class")

---@class sphere.ITaskContext
---@operator call: sphere.ITaskContext
local ITaskContext = class()

---@param hash string
---@return ncdk2.Chart[]?
---@return string?
function ITaskContext:getChartsByHash(hash)
	error("not implemented")
end

---@param state integer
---@param count integer
---@param current integer
function ITaskContext:checkProgress(state, count, current)
	error("not implemented")
end

---@return boolean
function ITaskContext:shouldStop()
	error("not implemented")
end

---@param err any
function ITaskContext:addError(err)
	error("not implemented")
end

function ITaskContext:dbBegin()
	error("not implemented")
end

function ITaskContext:dbCommit()
	error("not implemented")
end

return ITaskContext
