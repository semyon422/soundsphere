local Class = require("Class")
local DynamicLayerData = require("ncdk.DynamicLayerData")
local Fraction = require("ncdk.Fraction")
local AudioManager = require("sphere.models.EditorModel.AudioManager")
local NoteChartResourceLoader = require("sphere.database.NoteChartResourceLoader")
local audio = require("audio")
local TimeManager = require("sphere.models.EditorModel.TimeManager")
local GraphicEngine = require("sphere.models.EditorModel.GraphicEngine")

local EditorModel = Class:new()

EditorModel.tools = {"Select", "ShortNote", "LongNote", "SoundNote"}
EditorModel.tool = "ShortNote"

EditorModel.construct = function(self)
	self.timer = TimeManager:new()
	self.audioManager = AudioManager:new()
	self.timer.audioManager = self.audioManager
	self.audioManager.timer = self.timer
	self.graphicEngine = GraphicEngine:new()
	self.graphicEngine.editorModel = self
end

EditorModel.load = function(self)
	local noteChartModel = self.game.noteChartModel
	local nc = noteChartModel.noteChart

	local ld = nc:getLayerData(1)
	ld = DynamicLayerData:new(ld)
	self.layerData = ld

	self.columns = nc.inputMode:getColumns()
	self.inputMap = nc.inputMode:getInputMap()

	local audioPath = noteChartModel.noteChartEntry.path:match("^(.+)/.-$") .. "/" .. nc.metaData.audioPath
	if love.filesystem.getInfo(audioPath, "file") then
		self.soundData = love.sound.newSoundData(audioPath)
		self.soundDataOffset = 0
	end

	self.timePoint = ld:newTimePoint()
	self.timePoint:setTime(ld:getDynamicTimePointAbsolute(192, 0))
	self.timePoint.absoluteTime = 0

	self.snap = 1
	self.speed = 1

	self.firstTime = ld.ranges.timePoint.first.absoluteTime
	self.lastTime = ld.ranges.timePoint.last.absoluteTime

	self.timer:reset()
	self.audioManager:load()

	self:scrollSeconds(self.timer:getTime())
end

EditorModel.loadResources = function(self)
	local nc = self.game.noteChartModel.noteChart

	self.sources = {}

	for noteDatas in nc:getInputIterator() do
		for _, noteData in ipairs(noteDatas) do
			local offset = noteData.timePoint.absoluteTime
			if noteData.stream then
				self.soundDataOffset = offset
			end
			if noteData.sounds then
				for _, s in ipairs(noteData.sounds) do
					local path = NoteChartResourceLoader.aliases[s[1]]
					local soundData = NoteChartResourceLoader.resources[path]
					if soundData then
						local _audio = audio:newAudio(soundData)
						local duration = _audio:getLength()
						self.audioManager:insert({
							offset = noteData.timePoint.absoluteTime,
							duration = duration,
							soundData = soundData,
							audio = _audio,
							name = s[1],
						})
						table.insert(self.sources, _audio)
						self.lastTime = math.max(self.lastTime, offset + duration)
					end
				end
			end
		end
	end

	print("loaded")
end

EditorModel.unload = function(self)
	for _, _audio in ipairs(self.sources) do
		_audio:release()
	end
end

EditorModel.save = function(self)
	local nc = self.game.noteChartModel.noteChart
	self.layerData:save(nc:getLayerData(1))
end

EditorModel.play = function(self)
	self.timer:play()
	self.audioManager:play()
end

EditorModel.pause = function(self)
	self.timer:pause()
	self.audioManager:pause()
end

EditorModel.getLogSpeed = function(self)
	return math.floor(10 * math.log(self.speed) / math.log(2) + 0.5)
end

EditorModel.setLogSpeed = function(self, logSpeed)
	self.speed = 2 ^ (logSpeed / 10)
end

EditorModel.getMouseTime = function(self)
	local mx, my = love.graphics.inverseTransformPoint(love.mouse.getPosition())
	local noteSkin = self.game.noteSkinModel.noteSkin
	return (self.timePoint.absoluteTime - noteSkin:getInverseTimePosition(my) / self.speed)
end

EditorModel.getColumnOver = function(self)
	local mx, my = love.graphics.inverseTransformPoint(love.mouse.getPosition())
	local noteSkin = self.game.noteSkinModel.noteSkin
	return noteSkin:getInverseColumnPosition(mx)
end

EditorModel.grabIntervalData = function(self)
	local dtp = self:getDynamicTimePoint()
	local intervalData = dtp._intervalData
	if not intervalData then
		return
	end
	self.grabbedIntervalData = intervalData
end

EditorModel.dropIntervalData = function(self)
	self.grabbedIntervalData = nil
end

EditorModel.grabNote = function(self, note, part)
	self.grabbedNote = note
	self.grabbedNotePart = part
	self:removeNote(note)

	local t = self:getMouseTime()
	if note.noteType == "ShortNote" then
		self.grabbedDeltaTime = t - note.startNoteData.timePoint.absoluteTime
		note.startNoteData.timePoint = note.startNoteData.timePoint:clone()
	elseif note.noteType == "LongNote" then
		if self.grabbedNotePart == "head" then
			self.grabbedDeltaTime = t - note.startNoteData.timePoint.absoluteTime
			note.startNoteData.timePoint = note.startNoteData.timePoint:clone()
		elseif self.grabbedNotePart == "tail" then
			self.grabbedDeltaTime = t - note.endNoteData.timePoint.absoluteTime
			note.endNoteData.timePoint = note.endNoteData.timePoint:clone()
		elseif self.grabbedNotePart == "body" then
			self.grabbedDeltaTime = {
				t - note.startNoteData.timePoint.absoluteTime,
				t - note.endNoteData.timePoint.absoluteTime,
			}
			note.startNoteData.timePoint = note.startNoteData.timePoint:clone()
			note.endNoteData.timePoint = note.endNoteData.timePoint:clone()
		end
	end
end

EditorModel.dropNote = function(self)
	local ld = self.layerData
	local note = self.grabbedNote

	local time = self:getMouseTime()
	if note.noteType == "ShortNote" then
		local dtp = ld:getDynamicTimePointAbsolute(self.snap, time - self.grabbedDeltaTime)
		note.startNoteData.timePoint = ld:checkTimePoint(dtp)
	elseif note.noteType == "LongNote" then
		if self.grabbedNotePart == "head" then
			local dtp = ld:getDynamicTimePointAbsolute(self.snap, time - self.grabbedDeltaTime)
			note.startNoteData.timePoint = ld:checkTimePoint(dtp)
		elseif self.grabbedNotePart == "tail" then
			local dtp = ld:getDynamicTimePointAbsolute(self.snap, time - self.grabbedDeltaTime)
			note.endNoteData.timePoint = ld:checkTimePoint(dtp)
		elseif self.grabbedNotePart == "body" then
			local dtp = ld:getDynamicTimePointAbsolute(self.snap, time - self.grabbedDeltaTime[1])
			note.startNoteData.timePoint = ld:checkTimePoint(dtp)
			local dtp = ld:getDynamicTimePointAbsolute(self.snap, time - self.grabbedDeltaTime[2])
			note.endNoteData.timePoint = ld:checkTimePoint(dtp)
		end
	end

	self:_addNote(note)
	self.grabbedNote = nil
	self.grabbedNotePart = nil
	self.grabbedTime = nil
end

EditorModel.removeNote = function(self, note)
	local ld = self.layerData
	ld:removeNoteData(note.startNoteData, note.inputType, note.inputIndex)
	if note.endNoteData then
		ld:removeNoteData(note.endNoteData, note.inputType, note.inputIndex)
	end
end

EditorModel._addNote = function(self, note)
	local ld = self.layerData
	ld:addNoteData(note.startNoteData, note.inputType, note.inputIndex)
	if note.endNoteData then
		ld:addNoteData(note.endNoteData, note.inputType, note.inputIndex)
	end
end

EditorModel.addNote = function(self, absoluteTime, inputType, inputIndex)
	local ld = self.layerData
	if self.tool == "ShortNote" then
		local dtp = ld:getDynamicTimePointAbsolute(self.snap, absoluteTime)
		local noteData = ld:getNoteData(dtp, inputType, inputIndex)
		if noteData then
			noteData.noteType = "ShortNote"
		end
	elseif self.tool == "LongNote" then
		local dtp = ld:getDynamicTimePointAbsolute(self.snap, absoluteTime)
		local startNoteData = ld:getNoteData(dtp, inputType, inputIndex)
		if not startNoteData then
			return
		end
		startNoteData.noteType = "LongNoteStart"

		local tp = ld:getTimePoint(self:getNextSnapIntervalTime(startNoteData.timePoint.absoluteTime, 1))
		local endNoteData = ld:getNoteData(tp, inputType, inputIndex)
		if not endNoteData then
			return
		end
		endNoteData.noteType = "LongNoteEnd"

		endNoteData.startNoteData = startNoteData
		startNoteData.endNoteData = endNoteData
	end
end

EditorModel.update = function(self)
	local ld = self.layerData

	local grabbedNote = self.grabbedNote
	if grabbedNote then
		local time = self:getMouseTime()
		if grabbedNote.noteType == "ShortNote" then
			ld:getDynamicTimePointAbsolute(192, time - self.grabbedDeltaTime):clone(grabbedNote.startNoteData.timePoint)
		elseif grabbedNote.noteType == "LongNote" then
			if self.grabbedNotePart == "head" then
				ld:getDynamicTimePointAbsolute(192, time - self.grabbedDeltaTime):clone(grabbedNote.startNoteData.timePoint)
			elseif self.grabbedNotePart == "tail" then
				ld:getDynamicTimePointAbsolute(192, time - self.grabbedDeltaTime):clone(grabbedNote.endNoteData.timePoint)
			elseif self.grabbedNotePart == "body" then
				ld:getDynamicTimePointAbsolute(192, time - self.grabbedDeltaTime[1]):clone(grabbedNote.startNoteData.timePoint)
				ld:getDynamicTimePointAbsolute(192, time - self.grabbedDeltaTime[2]):clone(grabbedNote.endNoteData.timePoint)
			end
		end
		local column = self:getColumnOver()
		if column then
			local inputType, inputIndex = unpack(self.inputMap[column])
			grabbedNote.inputType = inputType
			grabbedNote.inputIndex = inputIndex
		end
	end
	self.graphicEngine:update()

	local dtp = ld:getDynamicTimePointAbsolute(192, self.timer:getTime())
	if self.grabbedIntervalData then
		ld:moveInterval(self.grabbedIntervalData, dtp.absoluteTime)
	end
	self.audioManager:update()
	if self.timer.isPlaying then
		self:_scrollTimePoint(dtp)
	end
end

EditorModel.receive = function(self, event)
	if event.name == "framestarted" then
		local timer = self.timer
		timer.eventTime = event.time
		timer.eventDelta = event.dt
		timer:update()
	end
end

EditorModel.getSnap = function(self, j)
	local snap = self.snap
	if type(j) == "table" then
		j, snap = 16 * j, 16
	end
	local k
	for i = 1, 16 do
		if snap % i == 0 and j % (snap / i) == 0 then
			k = i
			break
		end
	end
	return k
end

EditorModel.updateRange = function(self)
	local absoluteTime = self.timePoint.absoluteTime

	local ld = self.layerData
	if ld.mode == "interval" then
		local delta = 1 / self.speed
		if ld.startTime ~= absoluteTime - delta then
			ld:setRange(absoluteTime - delta, absoluteTime + delta)
		end
		return
	end

	local dtp = ld:getDynamicTimePointAbsolute(192, absoluteTime)
	local measureOffset = dtp.measureTime:floor()

	local delta = 2
	if ld.startTime:tonumber() ~= measureOffset - delta then
		ld:setRange(Fraction(measureOffset - delta), Fraction(measureOffset + delta))
	end
end

EditorModel.getDynamicTimePoint = function(self)
	local ld = self.layerData
	return ld:getDynamicTimePointAbsolute(192, self.timePoint.absoluteTime, self.timePoint.visualSide)
end

EditorModel._scrollTimePoint = function(self, timePoint)
	if not timePoint then
		return
	end

	local t = self.timePoint
	t.absoluteTime = timePoint.absoluteTime
	t.visualTime = timePoint.visualTime
	t.beatTime = timePoint.beatTime
	t.visualSection = timePoint.visualSection
	t:setTime(timePoint:getTime())

	self:updateRange()
end

EditorModel.scrollTimePoint = function(self, timePoint)
	if not timePoint then
		return
	end

	self:_scrollTimePoint(timePoint)

	local timer = self.timer
	timer:setPosition(timePoint.absoluteTime)

	local audioManager = self.audioManager
	audioManager:update(true)
	timer:adjustTime(true)
end

EditorModel.scrollSeconds = function(self, absoluteTime)
	local ld = self.layerData
	local dtp = ld:getDynamicTimePointAbsolute(192, absoluteTime)
	self:scrollTimePoint(dtp)
end

EditorModel.scrollSecondsDelta = function(self, delta)
	self:scrollSeconds(self.timePoint.absoluteTime + delta)
end

EditorModel.scrollSnaps = function(self, delta)
	local ld = self.layerData
	if ld.mode == "interval" then
		self:scrollTimePoint(ld:getDynamicTimePoint(self:scrollSnapsInterval(delta)))
	elseif ld.mode == "measure" then
		self:scrollTimePoint(ld:getDynamicTimePoint(self:scrollSnapsMeasure(delta)))
	end
end

EditorModel.getNextSnapIntervalTime = function(self, absoluteTime, delta)
	local ld = self.layerData
	local dtp = ld:getDynamicTimePointAbsolute(192, absoluteTime)

	local snap = self.snap
	local snapTime = dtp.time * snap

	local targetSnapTime
	if delta == -1 then
		targetSnapTime = snapTime:ceil() - 1
	else
		targetSnapTime = snapTime:floor() + 1
	end

	local intervalData = dtp.intervalData
	-- if intervalData.next and targetSnapTime >= snap * intervalData:_end() then
	-- 	intervalData = intervalData.next
	-- 	targetSnapTime = intervalData.start * snap
	-- elseif intervalData.prev and dtp.time > intervalData.start and targetSnapTime < snap * intervalData.start then
	-- 	targetSnapTime = intervalData.start * snap
	-- elseif intervalData.prev and dtp.time == intervalData.start and targetSnapTime < snap * intervalData.start then
	-- 	intervalData = intervalData.prev
	-- 	targetSnapTime = (intervalData:_end() * snap):ceil() - 1
	-- end

	if intervalData.next and targetSnapTime == snap * intervalData:_end() then
		intervalData = intervalData.next
		targetSnapTime = intervalData.start * snap
	elseif intervalData.next and targetSnapTime > snap * intervalData:_end() then
		intervalData = intervalData.next
		targetSnapTime = (intervalData.start * snap):floor() + 1
	elseif intervalData.prev and targetSnapTime < snap * intervalData.start then
		intervalData = intervalData.prev
		targetSnapTime = (intervalData:_end() * snap):ceil() - 1
	end

	return intervalData, Fraction(targetSnapTime, snap)
end

EditorModel.scrollSnapsInterval = function(self, delta)
	return self:getNextSnapIntervalTime(self.timePoint.absoluteTime, delta)
end

EditorModel.scrollSnapsMeasure = function(self, delta)
	local ld = self.layerData
	local dtp = ld:getDynamicTimePointAbsolute(192, self.timePoint.absoluteTime)

	local measureOffset = dtp.measureTime:floor()
	local signature = ld:getSignature(measureOffset)
	local sigSnap = signature * self.snap

	local targetMeasureOffset
	if delta == -1 then
		targetMeasureOffset = dtp.measureTime:ceil() - 1
	else
		targetMeasureOffset = (dtp.measureTime + Fraction(1) / sigSnap):floor()
	end
	signature = ld:getSignature(targetMeasureOffset)
	sigSnap = signature * self.snap

	if measureOffset ~= targetMeasureOffset then
		if delta == -1 then
			return Fraction(sigSnap:ceil() - 1) / sigSnap + targetMeasureOffset
		end
		return Fraction(targetMeasureOffset)
	end

	local snapTime = (dtp.measureTime - measureOffset) * sigSnap

	local targetSnapTime
	if delta == -1 then
		targetSnapTime = snapTime:ceil() - 1
	else
		targetSnapTime = snapTime:floor() + 1
	end

	return Fraction(targetSnapTime) / sigSnap + measureOffset
end

return EditorModel
