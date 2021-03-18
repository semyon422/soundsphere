local CoordinateManager	= require("aqua.graphics.CoordinateManager")
local Image				= require("aqua.graphics.Image")
local SpriteBatch		= require("aqua.graphics.SpriteBatch")
local map				= require("aqua.math").map
local Class				= require("aqua.util.Class")

local NoteSkinImageView = Class:new()

NoteSkinImageView.visualTimeRate = 1
NoteSkinImageView.targetVisualTimeRate = 1
NoteSkinImageView.timeRate = 1

NoteSkinImageView.load = function(self)
	self.allcs = CoordinateManager:getCS(0, 0, 0, 0, "all")

    local nsdCses = self.noteSkin.data.cses
	self.cses = {}
	if nsdCses then
		for i = 1, #nsdCses do
			self.cses[i] = CoordinateManager:getCS(
				tonumber(nsdCses[i][1]),
				tonumber(nsdCses[i][2]),
				tonumber(nsdCses[i][3]),
				tonumber(nsdCses[i][4]),
				nsdCses[i][5]
			)
		end
	end

	self.images = {}
	self:loadImages()

	self.containers = {}
	self:loadContainers()
end

NoteSkinImageView.receive = function(self, event)
end

NoteSkinImageView.unload = function(self)
end

local newImage = love.graphics.newImage
NoteSkinImageView.loadImage = function(self, imageData)
	self.images[imageData.name] = newImage(self.noteSkin.directoryPath .. "/" .. imageData.path)
end

NoteSkinImageView.loadImages = function(self)
	if not self.noteSkin.data.images then
		return
	end

	for _, imageData in pairs(self.noteSkin.data.images) do
		self:loadImage(imageData)
	end
end

local sortContainers = function(a, b)
	return a.layer < b.layer
end
NoteSkinImageView.loadContainers = function(self)
	self.containerList = {}

	if not self.noteSkin.data.images then
		return
	end

	for _, imageData in pairs(self.noteSkin.data.images) do
		local container = SpriteBatch:new(nil, self.images[imageData.name], 1000)
		container.layer = imageData.layer
		container.blendMode = imageData.blendMode
		container.blendAlphaMode = imageData.blendAlphaMode

		self.containers[imageData.name] = container
		table.insert(self.containerList, container)
	end
	table.sort(self.containerList, sortContainers)
end

NoteSkinImageView.joinContainer = function(self, container)
	for _, subcontainer in ipairs(self.containerList) do
		container:add(subcontainer)
	end
end

NoteSkinImageView.leaveContainer = function(self, container)
	for _, subcontainer in ipairs(self.containerList) do
		container:remove(subcontainer)
	end
end

NoteSkinImageView.update = function(self, dt)
	for _, container in ipairs(self.containerList) do
		container:update()
	end
end

NoteSkinImageView.getVisualTimeRate = function(self)
	return self.noteSkin:getVisualTimeRate()
end

NoteSkinImageView.getCS = function(self, note)
	return self.cses[self.noteSkin.notes[note.id]["Head"].cs]
end

NoteSkinImageView.checkNote = function(self, note)
	return self.noteSkin:checkNote(note)
end

NoteSkinImageView.getG = function(self, note, part, name, timeState)
	return self.noteSkin:getG(note, part, name, timeState)
end

NoteSkinImageView.getNoteLayer = function(self, note, part)
	return
		self.noteSkin.notes[note.id][part].layer
		+ map(
			note.startNoteData.timePoint.absoluteTime,
			note.startNoteData.timePoint.firstTimePoint.absoluteTime,
			note.startNoteData.timePoint.lastTimePoint.absoluteTime,
			0,
			1
		)
end

NoteSkinImageView.getNoteImage = function(self, note, part)
	return self.images[self.noteSkin.notes[note.id][part].image]
end

local clear = {255, 255, 255, 255}
NoteSkinImageView.getImageDrawable = function(self, note, part)
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

NoteSkinImageView.getImageContainer = function(self, note, part)
	return self.containers[self.noteSkin.notes[note.id][part].image]
end

return NoteSkinImageView
