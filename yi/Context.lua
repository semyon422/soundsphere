local class = require("class")

---@class yi.Context
---@operator call: yi.Context
local Context = class()

---@param game sphere.GameController
---@param inputs ui.Inputs
function Context:new(game, inputs)
	self.game = assert(game)
	self.inputs = assert(inputs)
end

---@param top yi.View
---@param modals yi.View
---@param screens yi.View
---@param background yi.Background
function Context:setLayers(top, modals, screens, background)
	self.top = top
	self.modals = modals
	self.screens = screens
	self.background = background
end

return Context
