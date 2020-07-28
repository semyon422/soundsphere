local CoordinateManager	= require("aqua.graphics.CoordinateManager")
local Image				= require("aqua.graphics.Image")
local SpriteBatch		= require("aqua.graphics.SpriteBatch")
local map				= require("aqua.math").map
local Class				= require("aqua.util.Class")
local GameConfig		= require("sphere.config.GameConfig")
local tween				= require("tween")

local NoteSkinView = Class:new()

NoteSkinView.visualTimeRate = 1
NoteSkinView.targetVisualTimeRate = 1
NoteSkinView.timeRate = 1

NoteSkinView.load = function(self)
	self.allcs = CoordinateManager:getCS(0, 0, 0, 0, "all")

	local nsdCses = self.noteSkinData.cses
	self.cses = {}
	for i = 1, #nsdCses do
		self.cses[i] = CoordinateManager:getCS(
			tonumber(nsdCses[i][1]),
			tonumber(nsdCses[i][2]),
			tonumber(nsdCses[i][3]),
			tonumber(nsdCses[i][4]),
			nsdCses[i][5]
		)
	end

	self.data = self.noteSkinData.notes or {}

	self.images = {}
	self:loadImages()

	self.containers = {}
	self:loadContainers()
end

NoteSkinView.receive = function(self, event)
end

NoteSkinView.update = function(self, dt)
end

NoteSkinView.unload = function(self)
end

local newImage = love.graphics.newImage
NoteSkinView.loadImage = function(self, imageData)
	self.images[imageData.name] = newImage(self.metaData.directoryPath .. "/" .. imageData.path)
end

NoteSkinView.loadImages = function(self)
	if not self.noteSkinData.images then
		return
	end

	for _, imageData in pairs(self.noteSkinData.images) do
		self:loadImage(imageData)
	end
end

local sortContainers = function(a, b)
	return a.layer < b.layer
end
NoteSkinView.loadContainers = function(self)
	self.containerList = {}

	if not self.noteSkinData.images then
		return
	end

	for _, imageData in pairs(self.noteSkinData.images) do
		local container = SpriteBatch:new(nil, self.images[imageData.name], 1000)
		container.layer = imageData.layer
		container.blendMode = imageData.blendMode
		container.blendAlphaMode = imageData.blendAlphaMode

		self.containers[imageData.name] = container
		table.insert(self.containerList, container)
	end
	table.sort(self.containerList, sortContainers)
end

NoteSkinView.joinContainer = function(self, container)
	for _, subcontainer in ipairs(self.containerList) do
		container:add(subcontainer)
	end
end

NoteSkinView.leaveContainer = function(self, container)
	for _, subcontainer in ipairs(self.containerList) do
		container:remove(subcontainer)
	end
end

NoteSkinView.update = function(self, dt)
	if self.visualTimeRateTween and self.updateTween then
		self.visualTimeRateTween:update(dt)
	end

	for _, container in ipairs(self.containerList) do
		container:update()
	end
end

NoteSkinView.setVisualTimeRate = function(self, visualTimeRate)
	if visualTimeRate * self.visualTimeRate < 0 then
		self.visualTimeRate = visualTimeRate
		self.updateTween = false
	else
		self.updateTween = true
		self.visualTimeRateTween = tween.new(0.25, self, {visualTimeRate = visualTimeRate}, "inOutQuad")
	end
	GameConfig.data.speed = visualTimeRate
end

NoteSkinView.getVisualTimeRate = function(self)
	return self.visualTimeRate / math.abs(self.timeRate)
end

NoteSkinView.getCS = function(self, note)
	return self.cses[self.data[note.id]["Head"].cs]
end

NoteSkinView.checkNote = function(self, note)
	return self.data[note.id]
end

NoteSkinView.getG = function(self, note, part, name, timeState)
	local seq = self.data[note.id][part].gc[name]

	return self.env[seq[1]](timeState, note.logicalState, seq[2])
end

NoteSkinView.getNoteLayer = function(self, note, part)
	return
		self.data[note.id][part].layer
		+ map(
			note.startNoteData.timePoint.absoluteTime,
			note.startNoteData.timePoint.firstTimePoint.absoluteTime,
			note.startNoteData.timePoint.lastTimePoint.absoluteTime,
			0,
			1
		)
end

NoteSkinView.getNoteImage = function(self, note, part)
	return self.images[self.data[note.id][part].image]
end

local clear = {255, 255, 255, 255}
NoteSkinView.getImageDrawable = function(self, note, part)
	return Image:new({
		cs = self:getCS(note),
		x = 0,
		y = 0,
		sx = 0,
		sy = 0,
		image = self:getNoteImage(note, part),
		layer = self:getNoteLayer(note, part),
		color = clear
	})
end

NoteSkinView.getImageContainer = function(self, note, part)
	return self.containers[self.data[note.id][part].image]
end

return NoteSkinView
