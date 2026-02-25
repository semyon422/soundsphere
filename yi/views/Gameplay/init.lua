local Screen = require("yi.views.Screen")
local SequenceView = require("sphere.views.SequenceView")

---@class yi.GameplayView : yi.Screen
---@overload fun(): yi.GameplayView
local GameplayView = Screen + {}

function GameplayView:new()
	Screen.new(self)
	self:setWidth("100%")
	self:setHeight("100%")
	self.seq_view = SequenceView()

	self.id = "gameplay"
	self.handles_keyboard_input = true
end

function GameplayView:load()
	local game = self:getGame()
	self.game_interactor = game.gameInteractor
	self.gameplay_interactor = game.gameplayInteractor
end

function GameplayView:loadComplete()
	local config = self:getConfig()
	local bg = self:getContext().background
	bg:setDim(config.settings.graphics.dim.gameplay)
end

function GameplayView:enter()
	local game = self:getGame()
	self.game_interactor:loadGameplaySelectedChart()
	self.seq_view.game = game ---@diagnostic disable-line
	self.seq_view.subscreen = "gameplay" ---@diagnostic disable-line
	self.seq_view:setSequenceConfig(game.noteSkinModel.noteSkin.playField)
	self.seq_view:load()
	love.mouse.setVisible(false)
end

function GameplayView:exit()
	self.gameplay_interactor:unloadGameplay()
	self.seq_view:unload()
	self:kill()
end

function GameplayView:quit()
	if self.gameplay_interactor:hasResult() then
		self.parent:set("result")
	else
		self.parent:set("select")
	end
end

---@param dt number
function GameplayView:update(dt)
	self.seq_view:update(dt)
end

function GameplayView:draw()
	self.seq_view:draw()
end

---@param e ui.KeyDownEvent
function GameplayView:onKeyDown(e)
	if e.key == "escape" then
		self:quit()
	end
end

---@param event table
function GameplayView:receive(event)
	self.gameplay_interactor:receive(event)
	self.seq_view:receive(event)
end

return GameplayView
