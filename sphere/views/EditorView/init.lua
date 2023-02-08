local ScreenView = require("sphere.views.ScreenView")
local thread = require("thread")
local just = require("just")
local gfx_util = require("gfx_util")

local Layout = require("sphere.views.EditorView.Layout")
local EditorViewConfig = require("sphere.views.EditorView.EditorViewConfig")
local SnapGridView = require("sphere.views.EditorView.SnapGridView")
local SequenceView = require("sphere.views.SequenceView")
local Footer = require("sphere.views.EditorView.Footer")
local WaveformView = require("sphere.views.EditorView.WaveformView")

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

	local noteSkin = self.game.noteSkinModel.noteSkin
	local playfield = noteSkin.playField

	self.snapGridView = SnapGridView:new()
	self.snapGridView.game = self.game
	self.snapGridView.transform = playfield:newNoteskinTransform()
	self.transform = playfield:newNoteskinTransform()

	local sequenceView = self.sequenceView

	sequenceView.game = self.game
	sequenceView.subscreen = "editor"
	sequenceView:setSequenceConfig(playfield)
	sequenceView:load()

	loading = false
end)

EditorView.update = function(self, dt)
	love.graphics.replaceTransform(gfx_util.transform(self.transform))
	self.game.editorModel:update()
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
	self.sequenceView:draw()
	self.snapGridView:draw()
	WaveformView(self)
	Footer(self)
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
