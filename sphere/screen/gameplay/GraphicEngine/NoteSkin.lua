local CoordinateManager	= require("aqua.graphics.CoordinateManager")
local Container			= require("aqua.graphics.Container")
local Image				= require("aqua.graphics.Image")
local SpriteBatch		= require("aqua.graphics.SpriteBatch")
local map				= require("aqua.math").map
local sign				= require("aqua.math").sign
local Class				= require("aqua.util.Class")
local Config			= require("sphere.config.Config")
local tween				= require("tween")

local NoteSkin = Class:new()

NoteSkin.color = {
	transparent = {255, 255, 255, 0},
	clear = {255, 255, 255, 255},
	missed = {127, 127, 127, 255},
	passed = {255, 255, 255, 0},
	startMissed = {127, 127, 127, 255},
	startMissedPressed = {191, 191, 191, 255},
	startPassedPressed = {255, 255, 255, 255},
	endPassed = {255, 255, 255, 0},
	endMissed = {127, 127, 127, 255},
	endMissedPassed = {127, 127, 127, 255}
}

NoteSkin.visualTimeRate = 1
NoteSkin.targetVisualTimeRate = 1
NoteSkin.timeRate = 1

NoteSkin.load = function(self)
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
	
	self.functions = {}
	self:loadFunctions()
	
	self.containers = {}
	self:loadContainers()
end

local newImage = love.graphics.newImage
NoteSkin.loadImage = function(self, imageData)
	self.images[imageData.name] = newImage(self.metaData.directoryPath .. "/" .. imageData.path)
end

NoteSkin.loadImages = function(self)
	if not self.noteSkinData.images then
		return
	end
	
	for _, imageData in pairs(self.noteSkinData.images) do
		self:loadImage(imageData)
	end
end

local env = {
	math = math
}

local safeload = function(chunk)
	if chunk:byte(1) == 27 then
		error("bytecode is not allowed")
	end
	local f, message = loadstring(chunk)
	if not f then
		error(message)
	end
	setfenv(f, env)
	return f
end

NoteSkin.loadFunctions = function(self)
	if not self.noteSkinData.functions then
		return
	end
	
	local functions = self.functions
	for _, fn in pairs(self.noteSkinData.functions) do
		functions[fn.name] = safeload(fn.chunk)()
	end
end

local sortContainers = function(a, b)
	return a.layer < b.layer
end
NoteSkin.loadContainers = function(self)
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

NoteSkin.joinContainer = function(self, container)
	for _, container in ipairs(self.containerList) do
		self.container:add(container)
	end
end

NoteSkin.leaveContainer = function(self, container)
	for _, container in ipairs(self.containerList) do
		self.container:remove(container)
	end
end

NoteSkin.update = function(self, dt)
	if self.visualTimeRateTween and self.updateTween then
		self.visualTimeRateTween:update(dt)
	end
	
	for _, container in ipairs(self.containerList) do
		container:update()
	end
end

NoteSkin.setVisualTimeRate = function(self, visualTimeRate)
	if visualTimeRate * self.visualTimeRate < 0 then
		self.visualTimeRate = visualTimeRate
		self.updateTween = false
	else
		self.updateTween = true
		self.visualTimeRateTween = tween.new(0.25, self, {visualTimeRate = visualTimeRate}, "inOutQuad")
	end
	Config.data.speed = visualTimeRate
end

NoteSkin.getVisualTimeRate = function(self)
	if self.timeRate ~= 0 then
		return self.visualTimeRate / self.timeRate
	end
	return self.visualTimeRate
end

-- NoteSkin.getVisualTimeRateSign = function(self)
-- 	return sign(self.visualTimeRate)
-- end

NoteSkin.getCS = function(self, note)
	return self.cses[self.data[note.id]["Head"].cs]
end

NoteSkin.checkNote = function(self, note)
	return self.data[note.id]
end

NoteSkin.getG = function(self, note, part, name, timeState)
	local seq = self.data[note.id][part].gc[name]

	return self.functions[seq[1]](timeState, seq[2])
end

NoteSkin.whereWillDraw = function(self, time)
	local a, b = -1, 1
	
	if time > b then
		return -1
	elseif time < a then
		return 1
	else
		return 0
	end
end

NoteSkin.getNoteLayer = function(self, note, part)
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

NoteSkin.getNoteImage = function(self, note, part)
	return self.images[self.data[note.id][part].image]
end

NoteSkin.getImageDrawable = function(self, note, part)
	return Image:new({
		cs = self:getCS(note),
		x = 0,
		y = 0,
		sx = 0,
		sy = 0,
		image = self:getNoteImage(note, part),
		layer = self:getNoteLayer(note, part),
		color = self.color.clear
	})
end

NoteSkin.getImageContainer = function(self, note, part)
	return self.containers[self.data[note.id][part].image]
end

return NoteSkin
