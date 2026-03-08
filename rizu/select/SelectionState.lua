local class = require("class")
local Observable = require("Observable")

---@class rizu.select.SelectionState
---@operator call: rizu.select.SelectionState
local SelectionState = class()

function SelectionState:new()
	---@type number
	self.chartview_set_index = 1
	---@type number
	self.chartview_index = 1
	---@type number
	self.scoreItemIndex = 1

	---@type number?
	self.chartSetId = nil
	---@type number?
	self.chartId = nil
	---@type number?
	self.scoreId = nil

	self.onChanged = Observable()
end

---@param index number
---@param id number?
function SelectionState:setSet(index, id)
	if self.chartview_set_index == index and self.chartSetId == id then return end
	self.chartview_set_index = index
	self.chartSetId = id
	self.onChanged:send({type = "set", index = index, id = id})
end

---@param index number
---@param id number?
function SelectionState:setChart(index, id)
	if self.chartview_index == index and self.chartId == id then return end
	self.chartview_index = index
	self.chartId = id
	self.onChanged:send({type = "chart", index = index, id = id})
end

---@param index number
---@param id number?
function SelectionState:setScore(index, id)
	if self.scoreItemIndex == index and self.scoreId == id then return end
	self.scoreItemIndex = index
	self.scoreId = id
	self.onChanged:send({type = "score", index = index, id = id})
end

-- Backward compatibility aliases for setters if needed
SelectionState.setSetIndex = function(self, index) self:setSet(index, self.chartSetId) end
SelectionState.setChartIndex = function(self, index) self:setChart(index, self.chartId) end
SelectionState.setScoreIndex = function(self, index) self:setScore(index, self.scoreId) end

return SelectionState
