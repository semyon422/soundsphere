local aquafonts = require("aqua.assets.fonts")
local CS = require("aqua.graphics.CS")
local Button = require("aqua.ui.Button")
local spherefonts = require("sphere.assets.fonts")
local ModifierManager = require("sphere.game.ModifierManager")

local ModifierDisplay = Button:new()

ModifierDisplay.sender = "ModifierDisplay"

ModifierDisplay.text = ""
ModifierDisplay.enableStencil = true
		
ModifierDisplay.x = 0
ModifierDisplay.y = 16 / 17
ModifierDisplay.w = 0.6
ModifierDisplay.h = 1 / 17
ModifierDisplay.rectangleColor = {255, 255, 255, 0}
ModifierDisplay.mode ="fill"
ModifierDisplay.limit = math.huge
ModifierDisplay.textAlign = {
	x = "left", y = "center"
}
ModifierDisplay.textColor = {255, 255, 255, 255}
ModifierDisplay.font = aquafonts.getFont(spherefonts.NotoSansRegular, 24)

ModifierDisplay.cs = CS:new({
	bx = 0,
	by = 0,
	rx = 0,
	ry = 0,
	binding = "all",
	baseOne = 768
})

ModifierDisplay.updateText = function(self)
	self:setText(ModifierManager.modifierSequence:tostring())
end

ModifierDisplay.interact = function(self)
	ModifierManager.modifierSequence:remove()
	self:updateText()
end

ModifierDisplay.reload = function(self)
	self.cs:reload()
	Button.reload(self)
	self:updateText()
end

return ModifierDisplay
