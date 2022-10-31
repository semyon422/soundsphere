local ScreenView = require("sphere.views.ScreenView")
local thread = require("thread")
local just = require("just")
-- local Background = require("sphere.views.GameplayView.Background")
-- local Foreground = require("sphere.views.GameplayView.Foreground")
-- local PauseSubscreen = require("sphere.views.GameplayView.PauseSubscreen")
local SequenceView = require("sphere.views.SequenceView")

local Layout = require("sphere.views.EditorView.Layout")
local EditorViewConfig = require("sphere.views.EditorView.EditorViewConfig")
local SnapGridView = require("sphere.views.EditorView.SnapGridView")

local EditorView = ScreenView:new()

EditorView.construct = function(self)
	self.sequenceView = SequenceView:new()
end

local loading
EditorView.load = thread.coro(function(self)
	if loading then
		return
	end
	loading = true

	self.game.editorController:load()

	local noteSkin = self.game.rhythmModel.graphicEngine.noteSkin
	self.viewConfig = noteSkin.playField

	self.snapGridView = SnapGridView:new()
	self.snapGridView.game = self.game
	self.snapGridView.transform = noteSkin.playField:newNoteskinTransform()

	local sequenceView = self.sequenceView

	sequenceView.game = self.game
	sequenceView.screenView = self
	sequenceView:setSequenceConfig(self.viewConfig)
	sequenceView:load()

	loading = false
end)

EditorView.update = function(self, dt)
	self.game.editorController:update()
	self.sequenceView:update(dt)
end

EditorView.receive = function(self, event)
	self.game.editorController:receive(event)
	self.sequenceView:receive(event)
end

EditorView.draw = function(self)
	just.container("screen container", true)

	local kp = just.keypressed
	if kp("escape") then self:quit()
	end

	Layout:draw()
	EditorViewConfig(self)
	self.snapGridView:draw()
	self.sequenceView:draw()
	just.container()
end

EditorView.quit = function(self)
	self:changeScreen("selectView")
end

EditorView.unload = function(self)
	self.game.editorController:unload()
	self.sequenceView:unload()
end

return EditorView
