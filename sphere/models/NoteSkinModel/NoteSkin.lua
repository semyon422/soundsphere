local Class = require("aqua.util.Class")
local InputMode	= require("ncdk.InputMode")
-- local NoteSkinManager = require("sphere.models.NoteSkinModel.NoteSkinManager")
local NoteSkinLoader = require("sphere.models.NoteSkinModel.NoteSkinLoader")

local NoteSkin = Class:new()

NoteSkin.construct = function(self)
	self.data = {}
	self.env = {}
	self.notes = {}
	self.playField = {}

	self.name = ""
	self.inputMode = InputMode:new()
	self.type = ""
	self.path = ""
	self.directoryPath = ""
end

NoteSkin.visualTimeRate = 1
NoteSkin.targetVisualTimeRate = 1
NoteSkin.timeRate = 1

NoteSkin.load = function(self)
	return NoteSkinLoader:load(self)
end

NoteSkin.setVisualTimeRate = function(self, visualTimeRate)
	if visualTimeRate * self.visualTimeRate < 0 then
		self.visualTimeRate = visualTimeRate
		self.updateTween = false
	else
		self.updateTween = true
		-- self.visualTimeRateTween = tween.new(0.25, self, {visualTimeRate = visualTimeRate}, "inOutQuad")
	end
	-- GameConfig.data.speed = visualTimeRate
end

NoteSkin.getVisualTimeRate = function(self)
	return self.visualTimeRate / math.abs(self.timeRate)
end

NoteSkin.checkNote = function(self, note)
	return self.notes[note.id]
end

NoteSkin.getG = function(self, note, part, name, timeState)
	local seq = self.notes[note.id][part].gc[name]

	return self.env[seq[1]](timeState, note.logicalState, seq[2])
end

NoteSkin.whereWillDraw = function(self, note, part, time)
	local drawInterval = self.notes[note.id][part].drawInterval

	if -time > drawInterval[2] then
		return 1
	elseif -time < drawInterval[1] then
		return -1
	else
		return 0
	end
end

return NoteSkin
