local Class = require("aqua.util.Class")
local CS = require("aqua.graphics.CS")
local map = require("aqua.math").map
local sign = require("aqua.math").sign
local tween = require("tween")
local Image = require("aqua.graphics.Image")
local Rectangle = require("aqua.graphics.Rectangle")
local SpriteBatch = require("aqua.graphics.SpriteBatch")
local Container = require("aqua.graphics.Container")
local Config = require("sphere.game.Config")

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

NoteSkin.speed = 1
NoteSkin.targetSpeed = 1
NoteSkin.rate = 1
NoteSkin.allcs = CS:new({
	bx = 0,
	by = 0,
	rx = 0,
	ry = 0,
	binding = "all"
})

NoteSkin.construct = function(self)
	self.cses = {}
	for i = 1, #self.noteSkinData.cses do
		self.cses[i] = CS:new({
			bx = tonumber(self.noteSkinData.cses[i][1]),
			by = tonumber(self.noteSkinData.cses[i][2]),
			rx = tonumber(self.noteSkinData.cses[i][3]),
			ry = tonumber(self.noteSkinData.cses[i][4]),
			binding = self.noteSkinData.cses[i][5]
		})
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
	
	self.rectangleContainer = Container:new()
	table.insert(self.containerList, 1, self.rectangleContainer)
end

NoteSkin.update = function(self, dt)
	if self.speedTween and self.updateTween then
		self.speedTween:update(dt)
	end
	
	for _, container in ipairs(self.containerList) do
		container:update()
	end
end

NoteSkin.reloadCS = function(self, dt)
	self.allcs:reload()
	for i = 1, #self.cses do
		self.cses[i]:reload()
	end
end

NoteSkin.draw = function(self)
	for _, container in ipairs(self.containerList) do
		container:draw()
	end
end

NoteSkin.setSpeed = function(self, speed)
	if speed * self.speed < 0 then
		self.speed = speed
		self.updateTween = false
	else
		self.updateTween = true
		self.speedTween = tween.new(0.25, self, {speed = speed}, "inOutQuad")
	end
	Config.data.speed = speed
end

NoteSkin.getSpeed = function(self)
	return self.speed / self.rate
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
			note.startNoteData.timePoint:getAbsoluteTime(),
			note.startNoteData.timePoint.firstTimePoint:getAbsoluteTime(),
			note.startNoteData.timePoint.lastTimePoint:getAbsoluteTime(),
			0,
			1
		)
end

NoteSkin.getNoteImage = function(self, note, part)
	return self.images[self.data[note.id][part].image]
end

NoteSkin.getRectangleDrawable = function(self, note, part)
	return Rectangle:new({
		cs = self:getCS(note),
		mode = "fill",
		x = 0,
		y = 0,
		w = self:getLineNoteScaledWidth(note),
		h = self:getLineNoteScaledHeight(note),
		lineStyle = "rough",
		lineWidth = 1,
		layer = self:getNoteLayer(note, part),
		color = self.color.clear
	})
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

NoteSkin.getRectangleContainer = function(self, note, part)
	return self.rectangleContainer
end

--------------------------------
-- get*X get*Y
--------------------------------
NoteSkin.getShortNoteX = function(self, note)
	local data = self.data[note.id]["Head"]
	return
		data.x
		+ data.fx * self:getSpeed()
			* (note.startNoteData.currentVisualTime - note.engine.currentTime)
		+ data.ox * self:getNoteWidth(note, "Head")
end
NoteSkin.getLongNoteHeadX = function(self, note)
	local data = self.data[note.id]["Head"]
	return
		data.x
		+ data.fx * self:getSpeed()
			* ((note:getFakeVisualStartTime() or note.startNoteData.currentVisualTime) - note.engine.currentTime)
		+ data.ox * self:getNoteWidth(note, "Head")
end
NoteSkin.getLongNoteTailX = function(self, note)
	local dataHead = self.data[note.id]["Head"]
	local dataTail = self.data[note.id]["Tail"]
	return
		dataHead.x
		+ dataHead.fx * self:getSpeed()
			* (note.endNoteData.currentVisualTime - note.engine.currentTime)
		+ dataTail.ox * self:getNoteWidth(note, "Tail")
end
NoteSkin.getLongNoteBodyX = function(self, note)
	local dataHead = self.data[note.id]["Head"]
	local dataBody = self.data[note.id]["Body"]
	local speedSign = sign(self.speed)
	local dt
	if dataHead.fx * speedSign <= 0 then
		dt = note.endNoteData.currentVisualTime - note.engine.currentTime
	else
		dt = (note:getFakeVisualStartTime() or note.startNoteData.currentVisualTime) - note.engine.currentTime
	end
	
	return
		dataHead.x
		+ dataHead.fx * self:getSpeed() * dt
		+ dataBody.ox * self:getNoteWidth(note, "Head")
end
NoteSkin.getLineNoteX = function(self, note)
	local data = self.data[note.id]["Head"]
	local speedSign = sign(self.speed)
	local dt
	if data.fx * speedSign <= 0 then
		dt = note.endNoteData.currentVisualTime - note.engine.currentTime
	else
		dt = note.startNoteData.currentVisualTime - note.engine.currentTime
	end
	
	return
		data.x
		+ data.fx * self:getSpeed() * dt
end

NoteSkin.getShortNoteY = function(self, note)
	local data = self.data[note.id]["Head"]
	return
		data.y
		+ data.fy * self:getSpeed()
			* (note.startNoteData.currentVisualTime - note.engine.currentTime)
		+ data.oy * self:getNoteHeight(note, "Head")
end
NoteSkin.getLongNoteHeadY = function(self, note)
	local data = self.data[note.id]["Head"]
	return
		data.y
		+ data.fy * self:getSpeed()
			* ((note:getFakeVisualStartTime() or note.startNoteData.currentVisualTime) - note.engine.currentTime)
		+ data.oy * self:getNoteHeight(note, "Head")
end
NoteSkin.getLongNoteTailY = function(self, note)
	local dataHead = self.data[note.id]["Head"]
	local dataTail = self.data[note.id]["Tail"]
	return
		dataHead.y
		+ dataHead.fy * self:getSpeed()
			* (note.endNoteData.currentVisualTime - note.engine.currentTime)
		+ dataTail.oy * self:getNoteHeight(note, "Tail")
end
NoteSkin.getLongNoteBodyY = function(self, note)
	local dataHead = self.data[note.id]["Head"]
	local dataBody = self.data[note.id]["Body"]
	local speedSign = sign(self.speed)
	local dt
	if dataHead.fy * speedSign <= 0 then
		dt = note.endNoteData.currentVisualTime - note.engine.currentTime
	else
		dt = (note:getFakeVisualStartTime() or note.startNoteData.currentVisualTime) - note.engine.currentTime
	end
	
	return
		dataHead.y
		+ dataHead.fy * self:getSpeed() * dt
		+ dataBody.oy * self:getNoteHeight(note, "Head")
end
NoteSkin.getLineNoteY = function(self, note)
	local data = self.data[note.id]["Head"]
	local speedSign = sign(self.speed)
	local dt
	if data.fy * speedSign <= 0 then
		dt = note.endNoteData.currentVisualTime - note.engine.currentTime
	else
		dt = note.startNoteData.currentVisualTime - note.engine.currentTime
	end
	
	return
		data.y
		+ data.fy * self:getSpeed() * dt
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
-- getLineNoteScaledWidth getLineNoteScaledHeight
--------------------------------

NoteSkin.getLineNoteScaledWidth = function(self, note)
	local data = self.data[note.id]["Head"]
	local dt = note.startNoteData.currentVisualTime - note.endNoteData.currentVisualTime
	return math.max(math.abs(data.fx * self:getSpeed() * dt + data.w), self:getCS(note):x(1))
end

NoteSkin.getLineNoteScaledHeight = function(self, note)
	local data = self.data[note.id]["Head"]
	local dt = note.startNoteData.currentVisualTime - note.endNoteData.currentVisualTime
	return math.max(math.abs(data.fy * self:getSpeed() * dt + data.h), self:getCS(note):y(1))
end

--------------------------------
-- get*ScaleX get*ScaleY
--------------------------------
NoteSkin.getNoteScaleX = function(self, note, part)
	local data = self.data[note.id][part]
	if part == "Body" then
		local speedSign = sign(self.speed)
		return
			(
				math.max(
					self.data[note.id]["Head"].fx *
					(self:getLongNoteTailX(note) - self:getLongNoteHeadX(note)) *
					speedSign,
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
		local speedSign = sign(self.speed)
		return
			math.abs(
				math.max(
					self.data[note.id]["Head"].fy *
					(self:getLongNoteTailY(note) - self:getLongNoteHeadY(note)) *
					speedSign,
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
NoteSkin.whereWillShortNoteDraw = function(self, note)
	local shortNoteY = self:getShortNoteY(note)
	local shortNoteHeight = self:getNoteHeight(note, "Head")
	local shortNoteX = self:getShortNoteX(note)
	local shortNoteWidth = self:getNoteWidth(note, "Head")
	
	local cs = self:getCS(note)
	
	local x, y
	if (self.allcs:x(cs:X(shortNoteX + shortNoteWidth, true), true) > 0) and (self.allcs:x(cs:X(shortNoteX, true), true) < 1) then
		x = 0
	elseif self.allcs:x(cs:X(shortNoteX, true), true) >= 1 then
		x = 1
	elseif self.allcs:x(cs:X(shortNoteX + shortNoteWidth, true), true) <= 0 then
		x = -1
	end
	if (self.allcs:y(cs:Y(shortNoteY + shortNoteHeight, true), true) > 0) and (self.allcs:y(cs:Y(shortNoteY, true), true) < 1) then
		y = 0
	elseif self.allcs:y(cs:Y(shortNoteY, true), true) >= 1 then
		y = 1
	elseif self.allcs:y(cs:Y(shortNoteY + shortNoteHeight, true), true) <= 0 then
		y = -1
	end
	
	return x, y
end
NoteSkin.willShortNoteDraw = function(self, note)
	local x, y = self:whereWillShortNoteDraw(note)
	return x == 0 and y == 0
end
NoteSkin.willShortNoteDrawBeforeStart = function(self, note)
	local x, y = self:whereWillShortNoteDraw(note)
	local data = self.data[note.id]["Head"]
	local speedSign = sign(self.speed)
	return data.fx * x * speedSign < 0 or data.fy * y * speedSign < 0
end
NoteSkin.willShortNoteDrawAfterEnd = function(self, note)
	local x, y = self:whereWillShortNoteDraw(note)
	local data = self.data[note.id]["Head"]
	local speedSign = sign(self.speed)
	return data.fx * x * speedSign > 0 or data.fy * y * speedSign > 0
end

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
	local speedSign = sign(self.speed)
	return data.fx * x * speedSign < 0 or data.fy * y * speedSign < 0
end
NoteSkin.willLongNoteDrawAfterEnd = function(self, note)
	local x, y = self:whereWillLongNoteDraw(note)
	local data = self.data[note.id]["Head"]
	local speedSign = sign(self.speed)
	return data.fx * x * speedSign > 0 or data.fy * y * speedSign > 0
end


NoteSkin.whereWillLineNoteDraw = function(self, note)
	local notex = self:getLineNoteX(note)
	local notey = self:getLineNoteY(note)
	local width = self:getLineNoteScaledWidth(note)
	local height = self:getLineNoteScaledHeight(note)
	
	local cs = self:getCS(note)
	
	local x, y
	if
		(self.allcs:x(cs:X(notex + width, true), true) > 0) and (self.allcs:x(cs:X(notex, true), true) < 1)
	then
		x = 0
	elseif self.allcs:x(cs:X(notex, true), true) >= 1 then
		x = 1
	elseif self.allcs:x(cs:X(notex + width, true), true) <= 0 then
		x = -1
	end
	
	if
		(self.allcs:y(cs:Y(notey + height, true), true) > 0) and (self.allcs:y(cs:Y(notey, true), true) < 1)
	then
		y = 0
	elseif self.allcs:y(cs:Y(notey, true), true) >= 1 then
		y = 1
	elseif self.allcs:y(cs:Y(notey + height, true), true) <= 0 then
		y = -1
	end
	
	return x, y
end
NoteSkin.willLineNoteDraw = function(self, note)
	local x, y = self:whereWillLineNoteDraw(note)
	return x == 0 and y == 0
end
NoteSkin.willLineNoteDrawBeforeStart = function(self, note)
	local x, y = self:whereWillLineNoteDraw(note)
	local data = self.data[note.id]["Head"]
	local speedSign = sign(self.speed)
	return data.fx * x * speedSign < 0 or data.fy * y * speedSign < 0
end
NoteSkin.willLineNoteDrawAfterEnd = function(self, note)
	local x, y = self:whereWillLineNoteDraw(note)
	local data = self.data[note.id]["Head"]
	local speedSign = sign(self.speed)
	return data.fx * x * speedSign > 0 or data.fy * y * speedSign > 0
end

--------------------------------
-- get*Color
--------------------------------
NoteSkin.getShortNoteColor = function(self, note)
	local color = self.color
	if note.logicalNote.state == "clear" or note.logicalNote.state == "skipped" then
		return color.clear
	elseif note.logicalNote.state == "missed" then
		return color.missed
	elseif note.logicalNote.state == "passed" then
		return color.passed
	end
end

NoteSkin.getLongNoteColor = function(self, note)
	local logicalNote = note.logicalNote
	
	local color = self.color
	if note.fakeStartTime and note.fakeStartTime >= note.endNoteData.timePoint:getAbsoluteTime() then
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
end

return NoteSkin
