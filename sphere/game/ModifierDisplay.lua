local aquafonts = require("aqua.assets.fonts")
local CS = require("aqua.graphics.CS")
local Rectangle = require("aqua.graphics.Rectangle")
local Stencil = require("aqua.graphics.Stencil")
local utf8 = require("aqua.utf8")
local Class = require("aqua.util.Class")
local Observable = require("aqua.util.Observable")
local Button = require("aqua.ui.Button")
local sign = require("aqua.math").sign
local belong = require("aqua.math").belong

local spherefonts = require("sphere.assets.fonts")
local Cache = require("sphere.game.NoteChartManager.Cache")
local BackgroundManager = require("sphere.ui.BackgroundManager")
local NotificationLine = require("sphere.ui.NotificationLine")

local CustomList = require("sphere.game.CustomList")

local ScreenManager = require("sphere.screen.ScreenManager")
local ModifierManager = require("sphere.game.ModifierManager")
local ModifierSequence = require("sphere.game.ModifierSequence")
local modifiers = require("sphere.game.modifiers")

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

return ModifierDisplay
