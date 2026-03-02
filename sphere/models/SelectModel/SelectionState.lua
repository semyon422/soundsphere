local class = require("class")
local Observable = require("aqua.Observable")

---@class sphere.SelectionState
---@operator call: sphere.SelectionState
local SelectionState = class()

function SelectionState:new()
	self.chartview_set_index = 1
	self.chartview_index = 1
	self.scoreItemIndex = 1
	self.onChanged = Observable()
end

---@param index number
function SelectionState:setSetIndex(index)
	if self.chartview_set_index == index then return end
	self.chartview_set_index = index
	self.onChanged:send({chartview_set_index = index})
end

---@param index number
function SelectionState:setChartIndex(index)
	if self.chartview_index == index then return end
	self.chartview_index = index
	self.onChanged:send({chartview_index = index})
end

---@param index number
function SelectionState:setScoreIndex(index)
	if self.scoreItemIndex == index then return end
	self.scoreItemIndex = index
	self.onChanged:send({scoreItemIndex = index})
end

return SelectionState
