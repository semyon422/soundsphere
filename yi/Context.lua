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

---@param background yi.Background
---@param screens yi.Screens
---@param modals yi.View
---@param top yi.View
function Context:setLayers(background, screens, modals, top)
	self.top = top
	self.modals = modals
	self.screens = screens
	self.background = background
end

return Context
