CloudburstEngine.NoteSkin = createClass(soul.SoulObject)
local NoteSkin = CloudburstEngine.NoteSkin

NoteSkin.colour = {
	clear = {255, 255, 255, 255},
	missed = {127, 127, 127, 255},
	passed = {255, 255, 255, 0}
}

NoteSkin.load = function(self)
	self.allcs = soul.CS:new(nil, 0, 0, 0, 0, "all")
	
	self.cs = soul.CS:new(
		nil,
		tonumber(self.noteSkinData.cs[1]),
		tonumber(self.noteSkinData.cs[2]),
		tonumber(self.noteSkinData.cs[3]),
		tonumber(self.noteSkinData.cs[4]),
		self.noteSkinData.cs[5]
	)
	
	self.data = {}
	
	self.images = {}
	self:loadImages()
end

NoteSkin.loadImages = function(self)
	for inputType in pairs(self.noteSkinData.inputMode) do
		local inputTypeData = self.noteSkinData[inputType]
		for noteType, list in pairs(inputTypeData.image) do
			for _, imagePath in ipairs(list) do
				if not self.images[imagePath] then
					self.images[imagePath] = love.graphics.newImage(self.directoryPath .. "/" .. imagePath)
				end
			end
		end
	end
end

NoteSkin.speed = 1

NoteSkin.getCS = function(self, note)
	return self.cs
end

NoteSkin.checkNote = function(self, note)
	local inputPointer = note.startNoteData.inputType .. note.startNoteData.inputIndex
	if self.data[inputPointer] then
		return true
	end
	
	local status, err = pcall(function()
		self.data[inputPointer] = {}
		local inputData = self.data[inputPointer]
		
		local data = self.noteSkinData[note.startNoteData.inputType]
		local inputIndex = note.startNoteData.inputIndex
		local temp
		temp = data.x[inputIndex] or error("x")
		inputData.x = temp
		temp = data.y[inputIndex] or error("y")
		inputData.y = temp
		temp = data.w[inputIndex] or error("w")
		inputData.w = temp
		temp = data.h[inputIndex] or error("h")
		inputData.h = temp
		temp = data.fx[inputIndex] or error("fx")
		inputData.fx = temp
		temp = data.fy[inputIndex] or error("fy")
		inputData.fy = temp
		temp = data.ox[inputIndex] or error("ox")
		inputData.ox = temp
		temp = data.oy[inputIndex] or error("oy")
		inputData.oy = temp
		temp = data.lnox[inputIndex] or error("lnox")
		inputData.lnox = temp
		temp = data.lnoy[inputIndex] or error("lnoy")
		inputData.lnoy = temp
		temp = data.lnw[inputIndex] or error("lnw")
		inputData.lnw = temp
		temp = data.lnh[inputIndex] or error("lnh")
		inputData.lnh = temp
		temp = data.layer[inputIndex] or error("layer")
		inputData.layer = temp
		for noteType, list in pairs(data.image) do
			temp = list[inputIndex] or error("image list")
			temp = self.images[list[inputIndex]] or error("image")
		end
		inputData.image = data.image
	end)
	
	if not status then
		self.data[inputPointer] = nil
	end
	
	return status
end

--------------------------------
-- get*Layer
--------------------------------
NoteSkin.getShortNoteLayer = function(self, note)
	local layer = self.data[note.inputPointer].layer
	return
		layer
		+ map(
			note.startNoteData.timePoint:getAbsoluteTime(),
			note.startNoteData.timePoint.firstTimePoint:getAbsoluteTime(),
			note.startNoteData.timePoint.lastTimePoint:getAbsoluteTime(),
			0.5,
			1
		)
end
NoteSkin.getLongNoteHeadLayer = function(self, note)
	return self:getShortNoteLayer(note)
end
NoteSkin.getLongNoteTailLayer = function(self, note)
	return self:getShortNoteLayer(note)
end
NoteSkin.getLongNoteBodyLayer = function(self, note)
	local layer = self.data[note.inputPointer].layer
	return
		layer
		+ map(
			note.startNoteData.timePoint:getAbsoluteTime(),
			note.startNoteData.timePoint.firstTimePoint:getAbsoluteTime(),
			note.startNoteData.timePoint.lastTimePoint:getAbsoluteTime(),
			0,
			0.5
		)
end

--------------------------------
-- get*Drawable
--------------------------------
NoteSkin.getNoteDrawable = function(self, note, suffix)
	return self.images[self.data[note.inputPointer].image[note.noteType .. (suffix or "")][note.startNoteData.inputIndex]]
end

--------------------------------
-- get*X get*Y
--------------------------------
NoteSkin.getShortNoteX = function(self, note)
	local x = self.data[note.inputPointer].x
	local ox = self.data[note.inputPointer].ox
	local fx = self.data[note.inputPointer].fx
	local dt = note.startNoteData.currentVisualTime - note.engine.currentTime
	return
		x
		+ fx * self.speed * dt
		+ ox * self:getNoteWidth(note, suffix)
end
NoteSkin.getLongNoteHeadX = function(self, note, suffix)
	local x = self.data[note.inputPointer].x
	local ox = self.data[note.inputPointer].ox
	local fx = self.data[note.inputPointer].fx
	local dt = (note:getFakeVisualStartTime() or note.startNoteData.currentVisualTime) - note.engine.currentTime
	return
		x
		+ fx * self.speed * dt
		+ ox * self:getNoteWidth(note, suffix)
end
NoteSkin.getLongNoteTailX = function(self, note, suffix)
	local x = self.data[note.inputPointer].x
	local ox = self.data[note.inputPointer].ox
	local fx = self.data[note.inputPointer].fx
	local dt = note.endNoteData.currentVisualTime - note.engine.currentTime
	return
		x
		+ fx * self.speed * dt
		+ ox * self:getNoteWidth(note, suffix)
end
NoteSkin.getLongNoteBodyX = function(self, note, suffix)
	local x = self.data[note.inputPointer].x
	local lnox = self.data[note.inputPointer].lnox
	local fx = self.data[note.inputPointer].fx
	local dt
	if fx <= 0 then
		dt = note.endNoteData.currentVisualTime - note.engine.currentTime
	else
		dt = (note:getFakeVisualStartTime() or note.startNoteData.currentVisualTime) - note.engine.currentTime
	end
	
	return
		x
		+ fx * self.speed * dt
		+ lnox * self:getNoteWidth(note, "Tail")
end
NoteSkin.getLineNoteX = function(self, note)
	local x = self.data[note.inputPointer].x
	local fx = self.data[note.inputPointer].fx
	local dt
	if fx <= 0 then
		dt = note.endNoteData.currentVisualTime - note.engine.currentTime
	else
		dt = note.startNoteData.currentVisualTime - note.engine.currentTime
	end
	
	return
		x
		+ fx * self.speed * dt
end

NoteSkin.getShortNoteY = function(self, note, suffix)
	local y = self.data[note.inputPointer].y
	local oy = self.data[note.inputPointer].oy
	local fy = self.data[note.inputPointer].fy
	local dt = note.startNoteData.currentVisualTime - note.engine.currentTime
	return
		y
		+ fy * self.speed * dt
		+ oy * self:getNoteHeight(note, suffix)
end
NoteSkin.getLongNoteHeadY = function(self, note, suffix)
	local y = self.data[note.inputPointer].y
	local oy = self.data[note.inputPointer].oy
	local fy = self.data[note.inputPointer].fy
	local dt = (note:getFakeVisualStartTime() or note.startNoteData.currentVisualTime) - note.engine.currentTime
	return
		y
		+ fy * self.speed * dt
		+ oy * self:getNoteHeight(note, suffix)
end
NoteSkin.getLongNoteTailY = function(self, note, suffix)
	local y = self.data[note.inputPointer].y
	local oy = self.data[note.inputPointer].oy
	local fy = self.data[note.inputPointer].fy
	local dt = note.endNoteData.currentVisualTime - note.engine.currentTime
	return
		y
		+ fy * self.speed * dt
		+ oy * self:getNoteHeight(note, suffix)
end
NoteSkin.getLongNoteBodyY = function(self, note, suffix)
	local y = self.data[note.inputPointer].y
	local lnoy = self.data[note.inputPointer].lnoy
	local fy = self.data[note.inputPointer].fy
	local dt
	if fy <= 0 then
		dt = note.endNoteData.currentVisualTime - note.engine.currentTime
	else
		dt = (note:getFakeVisualStartTime() or note.startNoteData.currentVisualTime) - note.engine.currentTime
	end
	
	return
		y
		+ fy * self.speed * dt
		+ lnoy * self:getNoteHeight(note, "Tail")
end
NoteSkin.getLineNoteY = function(self, note)
	local y = self.data[note.inputPointer].y
	local fy = self.data[note.inputPointer].fy
	local dt
	if fy <= 0 then
		dt = note.endNoteData.currentVisualTime - note.engine.currentTime
	else
		dt = note.startNoteData.currentVisualTime - note.engine.currentTime
	end
	
	return
		y
		+ fy * self.speed * dt
end

--------------------------------
-- get*Width get*Height
--------------------------------
NoteSkin.getNoteWidth = function(self, note)
	return self.data[note.inputPointer].w
end

NoteSkin.getNoteHeight = function(self, note)
	return self.data[note.inputPointer].h
end

--------------------------------
-- getLineNoteScaledWidth getLineNoteScaledHeight
--------------------------------

NoteSkin.getLineNoteScaledWidth = function(self, note)
	local x = self.data[note.inputPointer].x
	local lnw = self.data[note.inputPointer].lnw
	local fx = self.data[note.inputPointer].fx
	local dt = note.startNoteData.currentVisualTime - note.endNoteData.currentVisualTime
	
	return math.max(math.abs(fx * self.speed * dt + lnw), self:getCS():x(1))
end

NoteSkin.getLineNoteScaledHeight = function(self, note)
	local y = self.data[note.inputPointer].y
	local lnh = self.data[note.inputPointer].lnh
	local fy = self.data[note.inputPointer].fy
	local dt = note.startNoteData.currentVisualTime - note.endNoteData.currentVisualTime
	
	return math.max(math.abs(fy * self.speed * dt + lnh), self:getCS():y(1))
end

--------------------------------
-- get*ScaleX get*ScaleY
--------------------------------
NoteSkin.getNoteScaleX = function(self, note, suffix)
	if suffix == "Body" then
		local fx = self.data[note.inputPointer].fx
		local deltax = math.max(-fx * (self:getLongNoteHeadX(note, suffix) - self:getLongNoteTailX(note, suffix)), 0)
		return
			(
				deltax
				+ self.data[note.inputPointer].lnw
			) / self:getCS(note):x(self:getNoteDrawable(note, suffix):getWidth())
	end
	
	return self:getNoteWidth(note, suffix) / self:getCS(note):x(self:getNoteDrawable(note, suffix):getWidth())
end

NoteSkin.getNoteScaleY = function(self, note, suffix)
	if suffix == "Body" then
		local fy = self.data[note.inputPointer].fy
		local deltay = math.max(-fy * (self:getLongNoteHeadY(note, suffix) - self:getLongNoteTailY(note, suffix)), 0)
		return
			math.abs(
				deltay
				+ self.data[note.inputPointer].lnh
			) / self:getCS(note):y(self:getNoteDrawable(note, suffix):getHeight())
	end
	
	return self:getNoteHeight(note, suffix) / self:getCS(note):y(self:getNoteDrawable(note, suffix):getHeight())
end

--------------------------------
-- will*Draw
--------------------------------
NoteSkin.whereWillShortNoteDraw = function(self, note)
	local shortNoteY = self:getShortNoteY(note)
	local shortNoteHeight = self:getNoteHeight(note)
	local shortNoteX = self:getShortNoteX(note)
	local shortNoteWidth = self:getNoteWidth(note)
	
	local x, y
	if (self.allcs:x(self.cs:X(shortNoteX + shortNoteWidth, true), true) > 0) and (self.allcs:x(self.cs:X(shortNoteX, true), true) < 1) then
		x = 0
	elseif self.allcs:x(self.cs:X(shortNoteX, true), true) >= 1 then
		x = 1
	elseif self.allcs:x(self.cs:X(shortNoteX + shortNoteWidth, true), true) <= 0 then
		x = -1
	end
	if (self.allcs:y(self.cs:Y(shortNoteY + shortNoteHeight, true), true) > 0) and (self.allcs:y(self.cs:Y(shortNoteY, true), true) < 1) then
		y = 0
	elseif self.allcs:y(self.cs:Y(shortNoteY, true), true) >= 1 then
		y = 1
	elseif self.allcs:y(self.cs:Y(shortNoteY + shortNoteHeight, true), true) <= 0 then
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
	local fx = self.data[note.inputPointer].fx
	local fy = self.data[note.inputPointer].fy
	
	return fx * x < 0 or fy * y < 0
end
NoteSkin.willShortNoteDrawAfterEnd = function(self, note)
	local x, y = self:whereWillShortNoteDraw(note)
	local fx = self.data[note.inputPointer].fx
	local fy = self.data[note.inputPointer].fy
	
	return fx * x > 0 or fy * y > 0
end

NoteSkin.whereWillLongNoteDraw = function(self, note)
	local longNoteHeadX = self:getLongNoteHeadX(note, "Head")
	local longNoteHeadY = self:getLongNoteHeadY(note, "Head")
	local longNoteTailX = self:getLongNoteTailX(note, "Tail")
	local longNoteTailY = self:getLongNoteTailY(note, "Tail")
	local longNoteHeadWidth = self:getNoteWidth(note, "Head")
	local longNoteHeadHeight = self:getNoteHeight(note, "Head")
	local longNoteTailWidth = self:getNoteWidth(note, "Tail")
	local longNoteTailHeight = self:getNoteHeight(note, "Tail")
	
	local x, y
	if
		(self.allcs:x(self.cs:X(longNoteHeadX + longNoteHeadWidth, true), true) > 0) and (self.allcs:x(self.cs:X(longNoteHeadX, true), true) < 1) or
		(self.allcs:x(self.cs:X(longNoteTailX + longNoteTailWidth, true), true) > 0) and (self.allcs:x(self.cs:X(longNoteTailX, true), true) < 1) or
		self.allcs:x(self.cs:X(longNoteTailX + longNoteTailWidth, true), true) * self.allcs:x(self.cs:X(longNoteHeadX, true), true) < 0
	then
		x = 0
	elseif self.allcs:x(self.cs:X(longNoteTailX, true), true) >= 1 then
		x = 1
	elseif self.allcs:x(self.cs:X(longNoteHeadX + longNoteHeadWidth, true), true) <= 0 then
		x = -1
	end
	
	if
		(self.allcs:y(self.cs:Y(longNoteHeadY + longNoteHeadHeight, true), true) > 0) and (self.allcs:y(self.cs:Y(longNoteHeadY, true), true) < 1) or
		(self.allcs:y(self.cs:Y(longNoteTailY + longNoteTailHeight, true), true) > 0) and (self.allcs:y(self.cs:Y(longNoteTailY, true), true) < 1) or
		self.allcs:y(self.cs:Y(longNoteTailY + longNoteTailHeight, true), true) * self.allcs:y(self.cs:Y(longNoteHeadY, true), true) < 0
	then
		y = 0
	elseif self.allcs:y(self.cs:Y(longNoteTailY, true), true) >= 1 then
		y = 1
	elseif self.allcs:y(self.cs:Y(longNoteHeadY + longNoteHeadHeight, true), true) <= 0 then
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
	local fx = self.data[note.inputPointer].fx
	local fy = self.data[note.inputPointer].fy
	
	return fx * x < 0 or fy * y < 0
end
NoteSkin.willLongNoteDrawAfterEnd = function(self, note)
	local x, y = self:whereWillLongNoteDraw(note)
	local fx = self.data[note.inputPointer].fx
	local fy = self.data[note.inputPointer].fy
	
	return fx * x > 0 or fy * y > 0
end


NoteSkin.whereWillLineNoteDraw = function(self, note)
	local notex = self:getLineNoteX(note)
	local notey = self:getLineNoteY(note)
	local width = self:getLineNoteScaledWidth(note)
	local height = self:getLineNoteScaledHeight(note)
	
	local x, y
	if
		(self.allcs:x(self.cs:X(notex + width, true), true) > 0) and (self.allcs:x(self.cs:X(notex, true), true) < 1)
	then
		x = 0
	elseif self.allcs:x(self.cs:X(notex, true), true) >= 1 then
		x = 1
	elseif self.allcs:x(self.cs:X(notex + width, true), true) <= 0 then
		x = -1
	end
	
	if
		(self.allcs:y(self.cs:Y(notey + height, true), true) > 0) and (self.allcs:y(self.cs:Y(notey, true), true) < 1)
	then
		y = 0
	elseif self.allcs:y(self.cs:Y(notey, true), true) >= 1 then
		y = 1
	elseif self.allcs:y(self.cs:Y(notey + height, true), true) <= 0 then
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
	local fx = self.data[note.inputPointer].fx
	local fy = self.data[note.inputPointer].fy
	
	return fx * x < 0 or fy * y < 0
end
NoteSkin.willLineNoteDrawAfterEnd = function(self, note)
	local x, y = self:whereWillLineNoteDraw(note)
	local fx = self.data[note.inputPointer].fx
	local fy = self.data[note.inputPointer].fy
	
	return fx * x > 0 or fy * y > 0
end

--------------------------------
-- get*Colour
--------------------------------
NoteSkin.getShortNoteColour = function(self, note)
	if note.logicalNote.state == "clear" or note.logicalNote.state == "skipped" then
		return self.colour.clear
	elseif note.logicalNote.state == "missed" then
		return self.colour.missed
	elseif note.logicalNote.state == "passed" then
		return self.colour.passed
	end
end

NoteSkin.getLongNoteColour = function(self, note)
	local logicalNote = note.logicalNote
	
	if logicalNote.fakeStartTime and logicalNote.fakeStartTime >= note.endNoteData.timePoint:getAbsoluteTime() then
		return {255, 255, 255, 0}
	elseif logicalNote.state == "clear" then
		return {255, 255, 255, 255}
	elseif logicalNote.state == "startMissed" then
		return {127, 127, 127, 255}
	elseif logicalNote.state == "startMissedPressed" then
		return {191, 191, 191, 255}
	elseif logicalNote.state == "startPassedPressed" then
		return {255, 255, 255, 255}
	elseif logicalNote.state == "endPassed" then
		return {255, 255, 255, 0}
	elseif logicalNote.state == "endMissed" then
		return {127, 127, 127, 255}
	elseif logicalNote.state == "endMissedPassed" then
		return {127, 127, 127, 255}
	end
end
