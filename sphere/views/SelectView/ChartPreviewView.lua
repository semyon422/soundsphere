local class = require("class")
local SequenceView = require("sphere.views.SequenceView")

---@class sphere.ChartPreviewView
---@operator call: sphere.ChartPreviewView
local ChartPreviewView = class()

---@param game sphere.GameController
function ChartPreviewView:new(game)
	self.game = game
	self.sequenceView = SequenceView()
	self.sequenceView:setSequenceConfig({})
end

function ChartPreviewView:load()
	local noteSkin = self.game.noteSkinModel.noteSkin
	if not noteSkin then
		return
	end

	local playfield = noteSkin.playField

	self.transform = playfield:newNoteskinTransform()

	local sequenceView = self.sequenceView

	sequenceView.game = self.game
	sequenceView.subscreen = "preview"
	sequenceView:setSequenceConfig(playfield)
	sequenceView:load()
end

---@param dt number
function ChartPreviewView:update(dt)
	self.sequenceView:update(dt)
end

---@param event table
function ChartPreviewView:receive(event)
	self.sequenceView:receive(event)
end

function ChartPreviewView:draw()
	self.sequenceView:draw()
end

function ChartPreviewView:unload()
	self.sequenceView:unload()
end

return ChartPreviewView
