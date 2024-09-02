
local BackgroundView = require("sphere.views.BackgroundView")

local Layout = require("ui.views.EditorView.Layout")

---@param self table
local function Background(self)
	local w, h = Layout:move("base")

	local dim = self.game.configModel.configs.settings.graphics.dim.select
	BackgroundView.ui = self.ui
	BackgroundView:draw(w, h, 0.8, 0.01)
end

return function(self)
	Background(self)
end
