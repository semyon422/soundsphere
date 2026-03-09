local IUserInterface = require("sphere.IUserInterface")

---@class sphere.FallbackUserInterface : sphere.IUserInterface
---@overload fun(game: sphere.GameController, mount_path: string, err_msg: string): sphere.FallbackUserInterface
local FallbackUserInterface = IUserInterface + {}

---@param game sphere.GameController
---@param _ string
---@param err_msg string?
function FallbackUserInterface:new(game, _, err_msg)
	self.game = game
	assert(self.game, "Your game is broken")
	assert(self.game.uiModel, "No UI model inside GameController")
	self.available_uis = self.game.uiModel.items
	self.err_msg = err_msg or "No error"
	self.just_pressed = false
end

function FallbackUserInterface:load()
	self.font_small = love.graphics.newFont(16)
	self.font_large = love.graphics.newFont(24)
end

---@param ui_name string
function FallbackUserInterface:selectUI(ui_name)
	self.game.uiModel:setUserInterface(ui_name)
	self.game.uiModel:loadSelected()
end

function FallbackUserInterface:draw()
	local ww, wh = love.graphics.getDimensions()
	local padding = 5
	local button_padding = 5
	local button_gap = 10
	local gap = 10

	love.graphics.clear(0, 0.2, 0.8)
	love.graphics.setFont(self.font_large)
	love.graphics.printf("Can't load the game or the UI. Contact devs and tell them to fix their spaghetti.", padding, padding, ww - padding * 2)

	love.graphics.setFont(self.font_small)
	love.graphics.printf(self.err_msg, padding, self.font_large:getHeight() + gap, ww - padding * 2)

	love.graphics.setFont(self.font_large)
	love.graphics.translate(padding, wh - self.font_large:getHeight() - padding - button_padding * 2)

	for _, v in ipairs(self.available_uis) do
		local text = ("Load UI: %s"):format(v.display_name)
		local text_width = self.font_large:getWidth(text)
		local w = text_width + button_padding * 2
		local h = self.font_large:getHeight() + button_padding * 2

		local iw, ih = love.graphics.inverseTransformPoint(love.mouse.getPosition())

		if iw > 0 and iw < w and ih > 0 and ih < h then
			love.graphics.setColor(0, 0.4, 0.6)

			if self.just_pressed then
				self:selectUI(v.name)
			end
		else
			love.graphics.setColor(0, 0.1, 0.4)
		end

		love.graphics.rectangle("fill", 0, 0, w, h)
		love.graphics.setColor(1, 1, 1)
		love.graphics.print(text, button_padding, button_padding)
		love.graphics.translate(w + button_gap, 0)
	end

	self.just_pressed = false
end

---@param event table
function FallbackUserInterface:receive(event)
	if event.name == "mousepressed" then
		self.just_pressed = true
	end
end

return FallbackUserInterface
