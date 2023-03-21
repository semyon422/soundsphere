
local BackgroundView = require("sphere.views.BackgroundView")

local Layout = require("sphere.views.EditorView.Layout")

local function Background(self)
	local w, h = Layout:move("base")

	local dim = self.game.configModel.configs.settings.graphics.dim.select
	BackgroundView.game = self.game
	BackgroundView:draw(w, h, 0.8, 0.01)
end

return function(self)
	Background(self)
end
