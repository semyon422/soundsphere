local aquafonts = require("aqua.assets.fonts")
local CoordinateManager = require("aqua.graphics.CoordinateManager")
local Theme = require("aqua.ui.Theme")
local spherefonts = require("sphere.assets.fonts")
local ModifierManager = require("sphere.game.ModifierManager")

local ModifierDisplay = Theme.Button:new()

ModifierDisplay.sender = "ModifierDisplay"

ModifierDisplay.text = ""
ModifierDisplay.enableStencil = true

ModifierDisplay.rectangleColor = {255, 255, 255, 0}
ModifierDisplay.mode ="fill"
ModifierDisplay.limit = math.huge
ModifierDisplay.textAlign = {
	x = "left", y = "center"
}
ModifierDisplay.textColor = {255, 255, 255, 255}
ModifierDisplay.font = aquafonts.getFont(spherefonts.NotoSansRegular, 24)

ModifierDisplay.cs = CoordinateManager:getCS(0, 0, 0, 0, "all")

ModifierDisplay.updateText = function(self)
	self:setText(ModifierManager.sequence:tostring())
end

ModifierDisplay.interact = function(self)
	ModifierManager.sequence:remove()
	self:updateText()
end

ModifierDisplay.reload = function(self)
	Theme.Button.reload(self)
	self:updateText()
end

return ModifierDisplay
