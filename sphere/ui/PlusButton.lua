local IconButton	= require("sphere.ui.IconButton")
local icons			= require("sphere.assets.icons")

local PlusButton = IconButton:new()

PlusButton.sender = "PlusButton"
	
PlusButton.image = love.graphics.newImage(icons.ic_add_white_48dp)

return PlusButton
