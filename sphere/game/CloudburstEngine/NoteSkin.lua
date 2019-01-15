local Class = require("aqua.util.Class")
local CS = require("aqua.graphics.CS")
local map = require("aqua.math").map

local NoteSkin = Class:new()

NoteSkin.color = {
	clear = {255, 255, 255, 255},
	missed = {127, 127, 127, 255},
	passed = {255, 255, 255, 0}
}

NoteSkin.speed = 1
NoteSkin.allcs = CS:new({
	bx = 0,
	by = 0,
	rx = 0,
	ry = 0,
	binding = "all"
})

NoteSkin.construct = function(self)
	self.cs = CS:new({
		bx = tonumber(self.noteSkinData.cs[1]),
		by = tonumber(self.noteSkinData.cs[2]),
		rx = tonumber(self.noteSkinData.cs[3]),
		ry = tonumber(self.noteSkinData.cs[4]),
		binding = self.noteSkinData.cs[5]
	})
	
	self.data = self.noteSkinData.notes
	
	self.images = {}
	self:loadImages()
end

NoteSkin.loadImage = function(self, localPath)
	self.images[localPath]
		 = self.images[localPath]
		or love.graphics.newImage(self.directoryPath .. "/" .. localPath)
end

NoteSkin.loadImages = function(self)
	local path
	for noteId, data in pairs(self.data) do
		for _, subdata in pairs(data) do
			if subdata.image then
				self:loadImage(subdata.image)
			end
		end
	end
end

NoteSkin.getCS = function(self, note)
	return self.cs
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

NoteSkin.getNoteDrawable = function(self, note, part)
	return self.images[self.data[note.id][part].image]
end

--------------------------------
-- get*X get*Y
--------------------------------
NoteSkin.getShortNoteX = function(self, note)
	local data = self.data[note.id]["Head"]
	return
		data.x
		+ data.fx * self.speed
			* (note.startNoteData.currentVisualTime - note.engine.currentTime)
		+ data.ox * self:getNoteWidth(note, "Head")
end
NoteSkin.getLongNoteHeadX = function(self, note)
	local data = self.data[note.id]["Head"]
	return
		data.x
		+ data.fx * self.speed
			* ((note:getFakeVisualStartTime() or note.startNoteData.currentVisualTime) - note.engine.currentTime)
		+ data.ox * self:getNoteWidth(note, "Head")
end
NoteSkin.getLongNoteTailX = function(self, note)
	local dataHead = self.data[note.id]["Head"]
	local dataTail = self.data[note.id]["Tail"]
	return
		dataHead.x
		+ dataHead.fx * self.speed
			* (note.endNoteData.currentVisualTime - note.engine.currentTime)
		+ dataTail.ox * self:getNoteWidth(note, "Tail")
end
NoteSkin.getLongNoteBodyX = function(self, note)
	local dataHead = self.data[note.id]["Head"]
	local dataBody = self.data[note.id]["Body"]
	local dt
	if dataHead.fx <= 0 then
		dt = note.endNoteData.currentVisualTime - note.engine.currentTime
	else
		dt = (note:getFakeVisualStartTime() or note.startNoteData.currentVisualTime) - note.engine.currentTime
	end
	
	return
		dataHead.x
		+ dataHead.fx * self.speed * dt
		+ dataBody.ox * self:getNoteWidth(note, "Head")
end
NoteSkin.getLineNoteX = function(self, note)
	local data = self.data[note.id]["Head"]
	local dt
	if data.fx <= 0 then
		dt = note.endNoteData.currentVisualTime - note.engine.currentTime
	else
		dt = note.startNoteData.currentVisualTime - note.engine.currentTime
	end
	
	return
		data.x
		+ data.fx * self.speed * dt
end

NoteSkin.getShortNoteY = function(self, note)
	local data = self.data[note.id]["Head"]
	return
		data.y
		+ data.fy * self.speed
			* (note.startNoteData.currentVisualTime - note.engine.currentTime)
		+ data.oy * self:getNoteHeight(note, "Head")
end
NoteSkin.getLongNoteHeadY = function(self, note)
	local data = self.data[note.id]["Head"]
	return
		data.y
		+ data.fy * self.speed
			* ((note:getFakeVisualStartTime() or note.startNoteData.currentVisualTime) - note.engine.currentTime)
		+ data.oy * self:getNoteHeight(note, "Head")
end
NoteSkin.getLongNoteTailY = function(self, note)
	local dataHead = self.data[note.id]["Head"]
	local dataTail = self.data[note.id]["Tail"]
	return
		dataHead.y
		+ dataHead.fy * self.speed
			* (note.endNoteData.currentVisualTime - note.engine.currentTime)
		+ dataTail.oy * self:getNoteHeight(note, "Tail")
end
NoteSkin.getLongNoteBodyY = function(self, note)
	local dataHead = self.data[note.id]["Head"]
	local dataBody = self.data[note.id]["Body"]
	local dt
	if dataHead.fy <= 0 then
		dt = note.endNoteData.currentVisualTime - note.engine.currentTime
	else
		dt = (note:getFakeVisualStartTime() or note.startNoteData.currentVisualTime) - note.engine.currentTime
	end
	
	return
		dataHead.y
		+ dataHead.fy * self.speed * dt
		+ dataBody.oy * self:getNoteHeight(note, "Head")
end
NoteSkin.getLineNoteY = function(self, note)
	local data = self.data[note.id]["Head"]
	local dt
	if data.fy <= 0 then
		dt = note.endNoteData.currentVisualTime - note.engine.currentTime
	else
		dt = note.startNoteData.currentVisualTime - note.engine.currentTime
	end
	
	return
		data.y
		+ data.fy * self.speed * dt
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
	return math.max(math.abs(data.fx * self.speed * dt + data.w), self:getCS():x(1))
end

NoteSkin.getLineNoteScaledHeight = function(self, note)
	local data = self.data[note.id]["Head"]
	local dt = note.startNoteData.currentVisualTime - note.endNoteData.currentVisualTime
	return math.max(math.abs(data.fy * self.speed * dt + data.h), self:getCS():y(1))
end

--------------------------------
-- get*ScaleX get*ScaleY
--------------------------------
NoteSkin.getNoteScaleX = function(self, note, part)
	local data = self.data[note.id][part]
	if part == "Body" then
		return
			(
				math.max(
					self.data[note.id]["Head"].fx * (self:getLongNoteTailX(note) - self:getLongNoteHeadX(note)),
					0
				)
				+ data.w
			) / self:getCS(note):x(self:getNoteDrawable(note, part):getWidth())
	end
	
	return self:getNoteWidth(note, part) / self:getCS(note):x(self:getNoteDrawable(note, part):getWidth())
end

NoteSkin.getNoteScaleY = function(self, note, part)
	local data = self.data[note.id][part]
	if part == "Body" then
		return
			math.abs(
				math.max(
					self.data[note.id]["Head"].fy * (self:getLongNoteTailY(note) - self:getLongNoteHeadY(note)),
					0
				)
				+ data.h
			) / self:getCS(note):y(self:getNoteDrawable(note, part):getHeight())
	end
	
	return self:getNoteHeight(note, part) / self:getCS(note):y(self:getNoteDrawable(note, part):getHeight())
end

--------------------------------
-- will*Draw
--------------------------------
NoteSkin.whereWillShortNoteDraw = function(self, note)
	local shortNoteY = self:getShortNoteY(note)
	local shortNoteHeight = self:getNoteHeight(note, "Head")
	local shortNoteX = self:getShortNoteX(note)
	local shortNoteWidth = self:getNoteWidth(note, "Head")
	
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
	local data = self.data[note.id]["Head"]
	return data.fx * x < 0 or data.fy * y < 0
end
NoteSkin.willShortNoteDrawAfterEnd = function(self, note)
	local x, y = self:whereWillShortNoteDraw(note)
	local data = self.data[note.id]["Head"]
	return data.fx * x > 0 or data.fy * y > 0
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
	local data = self.data[note.id]["Head"]
	return data.fx * x < 0 or data.fy * y < 0
end
NoteSkin.willLongNoteDrawAfterEnd = function(self, note)
	local x, y = self:whereWillLongNoteDraw(note)
	local data = self.data[note.id]["Head"]
	return data.fx * x > 0 or data.fy * y > 0
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
	local data = self.data[note.id]["Head"]
	return data.fx * x < 0 or data.fy * y < 0
end
NoteSkin.willLineNoteDrawAfterEnd = function(self, note)
	local x, y = self:whereWillLineNoteDraw(note)
	local data = self.data[note.id]["Head"]
	return data.fx * x > 0 or data.fy * y > 0
end

--------------------------------
-- get*Color
--------------------------------
NoteSkin.getShortNoteColor = function(self, note)
	if note.logicalNote.state == "clear" or note.logicalNote.state == "skipped" then
		return self.color.clear
	elseif note.logicalNote.state == "missed" then
		return self.color.missed
	elseif note.logicalNote.state == "passed" then
		return self.color.passed
	end
end

NoteSkin.getLongNoteColor = function(self, note)
	local logicalNote = note.logicalNote
	
	if note.fakeStartTime and note.fakeStartTime >= note.endNoteData.timePoint:getAbsoluteTime() then
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

return NoteSkin
