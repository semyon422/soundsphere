soul.ui = {}
local ui = soul.ui

ui.accessableGroups = {
	["*"] = true
}

require("soul.ui.UIObject")
require("soul.ui.Button")
require("soul.ui.TextButton")
require("soul.ui.RectangleButton")
require("soul.ui.DrawableButton")

soul.ui.RectangleTextButton = createClass(soul.ui.RectangleButton, soul.ui.TextButton)
soul.ui.DrawableTextButton = createClass(soul.ui.DrawableButton, soul.ui.TextButton)