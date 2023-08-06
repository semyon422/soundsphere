local BackgroundView = require("sphere.views.BackgroundView")
local GaussianBlurView = require("sphere.views.GaussianBlurView")

return function(self)
	GaussianBlurView:draw(self.game.configModel.configs.settings.graphics.blur.gameplay)
	love.graphics.origin()
	local w, h = love.graphics.getDimensions()

	local dim = self.game.configModel.configs.settings.graphics.dim.gameplay
	BackgroundView.game = self.game
	BackgroundView:draw(w, h, dim, 0)
	GaussianBlurView:draw(self.game.configModel.configs.settings.graphics.blur.gameplay)
end
