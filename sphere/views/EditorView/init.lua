local ScreenView = require("sphere.views.ScreenView")
local thread = require("thread")
local just = require("just")
local gfx_util = require("gfx_util")

local Layout = require("sphere.views.EditorView.Layout")
local EditorViewConfig = require("sphere.views.EditorView.EditorViewConfig")
local EditorViewOverlay = require("sphere.views.EditorView.EditorViewOverlay")
local SnapGridView = require("sphere.views.EditorView.SnapGridView")
local SequenceView = require("sphere.views.SequenceView")
local Footer = require("sphere.views.EditorView.Footer")
local Foreground = require("sphere.views.EditorView.Foreground")
local WaveformView = require("sphere.views.EditorView.WaveformView")
local OnsetsView = require("sphere.views.EditorView.OnsetsView")
local OnsetsDistView = require("sphere.views.EditorView.OnsetsDistView")

local EditorView = ScreenView + {}

function EditorView:new()
	self.sequenceView = SequenceView()
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

	self.snapGridView = SnapGridView()
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

function EditorView:update(dt)
	love.graphics.replaceTransform(gfx_util.transform(self.transform))
	self.game.editorModel:update()
	self.sequenceView:update(dt)
end

function EditorView:receive(event)
	self.game.editorController:receive(event)
	self.sequenceView:receive(event)
end

function EditorView:draw()
	just.container("screen container", true)

	local kp = just.keypressed
	if kp("escape") then self:quit()
	end

	Layout:draw()
	EditorViewConfig(self)
	self.sequenceView:draw()
	self.snapGridView:draw()
	WaveformView(self)
	OnsetsView(self)
	OnsetsDistView(self)
	Footer(self)
	EditorViewOverlay(self)
	Foreground(self)

	just.container()
end

function EditorView:quit()
	self:changeScreen("selectView")
end

function EditorView:unload()
	self.game.editorController:unload()
	self.sequenceView:unload()
end

return EditorView
