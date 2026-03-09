local class = require("class")
local InputMode = require("ncdk.InputMode")
local Resources = require("ncdk.Resources")
local Notes = require("ncdk2.notes.Notes")

---@class ncdk2.Chart
---@operator call: ncdk2.Chart
---@field layers {[string]: ncdk2.Layer}
local Chart = class()

function Chart:new()
	self.layers = {}
	self.notes = Notes()
	self.inputMode = InputMode()
	self.resources = Resources()
end

---@return ncdk2.Visual[]
function Chart:getVisuals()
	local visuals = {}
	for _, layer in pairs(self.layers) do
		for _, visual in pairs(layer.visuals) do
			table.insert(visuals, visual)
		end
	end
	return visuals
end

---@param vp ncdk2.VisualPoint
---@return ncdk2.Visual?
function Chart:getVisualByPoint(vp)
	for _, layer in pairs(self.layers) do
		for _, visual in pairs(layer.visuals) do
			if visual.points_map[vp] then
				return visual
			end
		end
	end
end

function Chart:compute()
	for _, layer in pairs(self.layers) do
		layer:compute()
	end
	self.notes:compute()
	assert(self.notes:isValid())
end

return Chart
