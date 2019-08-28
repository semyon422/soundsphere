local IconButton	= require("sphere.ui.IconButton")
local icons			= require("sphere.assets.icons")

local CrossButton = IconButton:new()

CrossButton.sender = "CrossButton"
	
CrossButton.image = love.graphics.newImage(icons.ic_clear_white_48dp)

return CrossButton
