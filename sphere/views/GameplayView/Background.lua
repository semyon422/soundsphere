local BackgroundView = require("sphere.views.BackgroundView")
local GaussianBlurView = require("sphere.views.GaussianBlurView")

local gfx_util = require("gfx_util")

local transform = {{1 / 2, -16 / 9 / 2}, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}

return function(self)
	GaussianBlurView:draw(self.game.configModel.configs.settings.graphics.blur.gameplay)
	love.graphics.replaceTransform(gfx_util.transform(transform))

	local dim = self.game.configModel.configs.settings.graphics.dim.gameplay
	BackgroundView.game = self.game
	BackgroundView:draw(1920, 1080, dim, 0)
	GaussianBlurView:draw(self.game.configModel.configs.settings.graphics.blur.gameplay)
end
