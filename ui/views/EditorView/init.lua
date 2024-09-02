local ScreenView = require("ui.views.ScreenView")
local thread = require("thread")
local just = require("just")
local gfx_util = require("gfx_util")

local Layout = require("ui.views.EditorView.Layout")
local EditorViewConfig = require("ui.views.EditorView.EditorViewConfig")
local EditorViewOverlay = require("ui.views.EditorView.EditorViewOverlay")
local SnapGridView = require("ui.views.EditorView.SnapGridView")
local SequenceView = require("sphere.views.SequenceView")
local Footer = require("ui.views.EditorView.Footer")
local Foreground = require("ui.views.EditorView.Foreground")
local WaveformView = require("ui.views.EditorView.WaveformView")
local OnsetsView = require("ui.views.EditorView.OnsetsView")
local OnsetsDistView = require("ui.views.EditorView.OnsetsDistView")

---@class ui.EditorView: ui.ScreenView
---@operator call: ui.EditorView
local EditorView = ScreenView + {}

---@param game sphere.GameController
function EditorView:new(game)
	self.game = game
	self.sequenceView = SequenceView()
end

local loading = false
function EditorView:load()
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
end
EditorView.load = thread.coro(EditorView.load)

---@param dt number
function EditorView:update(dt)
	love.graphics.replaceTransform(gfx_util.transform(self.transform))
	self.game.editorModel:update()
	self.sequenceView:update(dt)
end

---@param event table
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
