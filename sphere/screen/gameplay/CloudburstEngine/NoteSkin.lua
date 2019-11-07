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

NoteSkin.construct = function(self)
	self.allcs = CoordinateManager:getCS(0, 0, 0, 0, "all")
	
	self.cses = {}
	for i = 1, #self.noteSkinData.cses do
		self.cses[i] = CoordinateManager:getCS(
			tonumber(self.noteSkinData.cses[i][1]),
			tonumber(self.noteSkinData.cses[i][2]),
			tonumber(self.noteSkinData.cses[i][3]),
			tonumber(self.noteSkinData.cses[i][4]),
			self.noteSkinData.cses[i][5]
		)
	end
	
	self.data = self.noteSkinData.notes or {}
	
	self.images = {}
	self:loadImages()
	
	self.containers = {}
	self:loadContainers()
end

local newImage = love.graphics.newImage
NoteSkin.loadImage = function(self, imageData)
	self.images[imageData.name] = newImage(self.directoryPath .. "/" .. imageData.path)
end

NoteSkin.loadImages = function(self)
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
NoteSkin.loadContainers = function(self)
	self.containerList = {}
	
	if not self.noteSkinData.images then
		return
	end
	
	for _, imageData in pairs(self.noteSkinData.images) do
		local container = SpriteBatch:new(nil, self.images[imageData.name], 1000)
		container.layer = imageData.layer
		self.containers[imageData.name] = container
		table.insert(self.containerList, container)
	end
	table.sort(self.containerList, sortContainers)
end

NoteSkin.update = function(self, dt)
	if self.visualTimeRateTween and self.updateTween then
		self.visualTimeRateTween:update(dt)
	end
	
	for _, container in ipairs(self.containerList) do
		container:update()
	end
end

NoteSkin.draw = function(self)
	for _, container in ipairs(self.containerList) do
		container:draw()
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
	return self.visualTimeRate / self.timeRate
end

NoteSkin.getCS = function(self, note)
	return self.cses[self.data[note.id]["Head"].cs]
end

NoteSkin.checkNote = function(self, note)
	if self.data[note.id] then
		return true
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
		sx = self:getNoteScaleX(note, part),
		sy = self:getNoteScaleY(note, part),
		image = self:getNoteImage(note, part),
		layer = self:getNoteLayer(note, part),
		color = self.color.clear
	})
end

NoteSkin.getImageContainer = function(self, note, part)
	return self.containers[self.data[note.id][part].image]
end

--------------------------------
-- get*X get*Y
--------------------------------
NoteSkin.getLongNoteHeadX = function(self, note)
	local data = self.data[note.id]["Head"]
	return
		data.x
		+ data.fx * self:getVisualTimeRate()
			* ((note:getFakeVisualStartTime() or note.startNoteData.timePoint.currentVisualTime) - note.engine.currentTime)
		+ data.ox * self:getNoteWidth(note, "Head")
end
NoteSkin.getLongNoteTailX = function(self, note)
	local dataHead = self.data[note.id]["Head"]
	local dataTail = self.data[note.id]["Tail"]
	return
		dataHead.x
		+ dataHead.fx * self:getVisualTimeRate()
			* (note.endNoteData.timePoint.currentVisualTime - note.engine.currentTime)
		+ dataTail.ox * self:getNoteWidth(note, "Tail")
end
NoteSkin.getLongNoteBodyX = function(self, note)
	local dataHead = self.data[note.id]["Head"]
	local dataBody = self.data[note.id]["Body"]
	local visualTimeRateSign = sign(self.visualTimeRate)
	local dt
	if dataHead.fx * visualTimeRateSign <= 0 then
		dt = note.endNoteData.timePoint.currentVisualTime - note.engine.currentTime
	else
		dt = (note:getFakeVisualStartTime() or note.startNoteData.timePoint.currentVisualTime) - note.engine.currentTime
	end
	
	return
		dataHead.x
		+ dataHead.fx * self:getVisualTimeRate() * dt
		+ dataBody.ox * self:getNoteWidth(note, "Head")
end

NoteSkin.getLongNoteHeadY = function(self, note)
	local data = self.data[note.id]["Head"]
	return
		data.y
		+ data.fy * self:getVisualTimeRate()
			* ((note:getFakeVisualStartTime() or note.startNoteData.timePoint.currentVisualTime) - note.engine.currentTime)
		+ data.oy * self:getNoteHeight(note, "Head")
end
NoteSkin.getLongNoteTailY = function(self, note)
	local dataHead = self.data[note.id]["Head"]
	local dataTail = self.data[note.id]["Tail"]
	return
		dataHead.y
		+ dataHead.fy * self:getVisualTimeRate()
			* (note.endNoteData.timePoint.currentVisualTime - note.engine.currentTime)
		+ dataTail.oy * self:getNoteHeight(note, "Tail")
end
NoteSkin.getLongNoteBodyY = function(self, note)
	local dataHead = self.data[note.id]["Head"]
	local dataBody = self.data[note.id]["Body"]
	local visualTimeRateSign = sign(self.visualTimeRate)
	local dt
	if dataHead.fy * visualTimeRateSign <= 0 then
		dt = note.endNoteData.timePoint.currentVisualTime - note.engine.currentTime
	else
		dt = (note:getFakeVisualStartTime() or note.startNoteData.timePoint.currentVisualTime) - note.engine.currentTime
	end
	
	return
		dataHead.y
		+ dataHead.fy * self:getVisualTimeRate() * dt
		+ dataBody.oy * self:getNoteHeight(note, "Head")
end

--------------------------------
-- get*Width get*Height
--------------------------------
NoteSkin.getNoteWidth = function(self, note, part)
	return self.data[note.id][part].w
end

NoteSkin.getNoteHeight = function(self, note, part)
	return self.data[note.id][part].h
end

--------------------------------
-- get*ScaleX get*ScaleY
--------------------------------
NoteSkin.getNoteScaleX = function(self, note, part)
	local data = self.data[note.id][part]
	if part == "Body" then
		local visualTimeRateSign = sign(self.visualTimeRate)
		return
			(
				math.max(
					self.data[note.id]["Head"].fx *
					(self:getLongNoteTailX(note) - self:getLongNoteHeadX(note)) *
					visualTimeRateSign,
					0
				)
				+ data.w
			) / self:getCS(note):x(self:getNoteImage(note, part):getWidth())
	end
	
	return self:getNoteWidth(note, part) / self:getCS(note):x(self:getNoteImage(note, part):getWidth())
end

NoteSkin.getNoteScaleY = function(self, note, part)
	local data = self.data[note.id][part]
	if part == "Body" then
		local visualTimeRateSign = sign(self.visualTimeRate)
		return
			math.abs(
				math.max(
					self.data[note.id]["Head"].fy *
					(self:getLongNoteTailY(note) - self:getLongNoteHeadY(note)) *
					visualTimeRateSign,
					0
				)
				+ data.h
			) / self:getCS(note):y(self:getNoteImage(note, part):getHeight())
	end
	
	return self:getNoteHeight(note, part) / self:getCS(note):y(self:getNoteImage(note, part):getHeight())
end

--------------------------------
-- will*Draw
--------------------------------
NoteSkin.whereWillLongNoteDraw = function(self, note)
	local longNoteHeadX = self:getLongNoteHeadX(note)
	local longNoteHeadY = self:getLongNoteHeadY(note)
	local longNoteTailX = self:getLongNoteTailX(note)
	local longNoteTailY = self:getLongNoteTailY(note)
	local longNoteHeadWidth = self:getNoteWidth(note, "Head")
	local longNoteHeadHeight = self:getNoteHeight(note, "Head")
	local longNoteTailWidth = self:getNoteWidth(note, "Tail")
	local longNoteTailHeight = self:getNoteHeight(note, "Tail")
	
	local cs = self:getCS(note)
	
	local x, y
	if
		(self.allcs:x(cs:X(longNoteHeadX + longNoteHeadWidth, true), true) > 0) and (self.allcs:x(cs:X(longNoteHeadX, true), true) < 1) or
		(self.allcs:x(cs:X(longNoteTailX + longNoteTailWidth, true), true) > 0) and (self.allcs:x(cs:X(longNoteTailX, true), true) < 1) or
		self.allcs:x(cs:X(longNoteTailX + longNoteTailWidth, true), true) * self.allcs:x(cs:X(longNoteHeadX, true), true) < 0
	then
		x = 0
	elseif self.allcs:x(cs:X(longNoteTailX, true), true) >= 1 then
		x = 1
	elseif self.allcs:x(cs:X(longNoteHeadX + longNoteHeadWidth, true), true) <= 0 then
		x = -1
	end
	
	if
		(self.allcs:y(cs:Y(longNoteHeadY + longNoteHeadHeight, true), true) > 0) and (self.allcs:y(cs:Y(longNoteHeadY, true), true) < 1) or
		(self.allcs:y(cs:Y(longNoteTailY + longNoteTailHeight, true), true) > 0) and (self.allcs:y(cs:Y(longNoteTailY, true), true) < 1) or
		self.allcs:y(cs:Y(longNoteTailY + longNoteTailHeight, true), true) * self.allcs:y(cs:Y(longNoteHeadY, true), true) < 0
	then
		y = 0
	elseif self.allcs:y(cs:Y(longNoteTailY, true), true) >= 1 then
		y = 1
	elseif self.allcs:y(cs:Y(longNoteHeadY + longNoteHeadHeight, true), true) <= 0 then
		y = -1
	end
	
	return x, y
end
NoteSkin.willLongNoteDraw = function(self, note)
	local x, y = self:whereWillLongNoteDraw(note)
	return x == 0 and y == 0
end
NoteSkin.willLongNoteDrawBeforeStart = function(self, note)
	local x, y = self:whereWillLongNoteDraw(note)
	local data = self.data[note.id]["Head"]
	local visualTimeRateSign = sign(self.visualTimeRate)
	return data.fx * x * visualTimeRateSign < 0 or data.fy * y * visualTimeRateSign < 0
end
NoteSkin.willLongNoteDrawAfterEnd = function(self, note)
	local x, y = self:whereWillLongNoteDraw(note)
	local data = self.data[note.id]["Head"]
	local visualTimeRateSign = sign(self.visualTimeRate)
	return data.fx * x * visualTimeRateSign > 0 or data.fy * y * visualTimeRateSign > 0
end

--------------------------------
-- get*Color
--------------------------------

NoteSkin.getLongNoteColor = function(self, note)
	local logicalNote = note.logicalNote
	
	local color = self.color
	if note.fakeStartTime and note.fakeStartTime >= note.endNoteData.timePoint.absoluteTime then
		return color.transparent
	elseif logicalNote.state == "clear" then
		return color.clear
	elseif logicalNote.state == "startMissed" then
		return color.startMissed
	elseif logicalNote.state == "startMissedPressed" then
		return color.startMissedPressed
	elseif logicalNote.state == "startPassedPressed" then
		return color.startPassedPressed
	elseif logicalNote.state == "endPassed" then
		return color.endPassed
	elseif logicalNote.state == "endMissed" then
		return color.endMissed
	elseif logicalNote.state == "endMissedPassed" then
		return color.endMissedPassed
	end

	return color.clear
end

return NoteSkin
