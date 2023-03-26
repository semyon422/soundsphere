local Class = require("Class")
local DynamicLayerData = require("ncdk.DynamicLayerData")
local Fraction = require("ncdk.Fraction")
local AudioManager = require("sphere.models.EditorModel.AudioManager")
local NoteChartResourceLoader = require("sphere.database.NoteChartResourceLoader")
local audio = require("audio")
local TimeManager = require("sphere.models.EditorModel.TimeManager")
local GraphicEngine = require("sphere.models.EditorModel.GraphicEngine")
local just = require("just")
local ConvertAbsoluteToInterval = require("sphere.models.EditorModel.ConvertAbsoluteToInterval")
local ConvertTests = require("sphere.models.EditorModel.ConvertTests")

local EditorModel = Class:new()

EditorModel.tools = {"Select", "ShortNote", "LongNote", "SoundNote"}

EditorModel.construct = function(self)
	self.timer = TimeManager:new()
	self.audioManager = AudioManager:new()
	self.timer.audioManager = self.audioManager
	self.audioManager.timer = self.timer
	self.graphicEngine = GraphicEngine:new()
	self.graphicEngine.editorModel = self
	self.grabbedNotes = {}
end

EditorModel.load = function(self)
	local noteChartModel = self.game.noteChartModel
	local nc = noteChartModel.noteChart

	self:fixSettings()

	local ld = nc:getLayerData(1)

	if ld.mode == "absolute" then
		ld = ConvertAbsoluteToInterval(ld)
	end

	ld = DynamicLayerData:new(ld)
	self.layerData = ld

	self.columns = nc.inputMode:getColumns()
	self.inputMap = nc.inputMode:getInputMap()

	self.soundData = nil
	self.soundDataOffset = 0

	local audioPath = noteChartModel.noteChartEntry.path:match("^(.+)/.-$") .. "/" .. nc.metaData.audioPath
	if love.filesystem.getInfo(audioPath, "file") then
		self.soundData = love.sound.newSoundData(audioPath)
	end

	self.timePoint = ld:newTimePoint()
	self.timePoint:setTime(ld:getDynamicTimePointAbsolute(192, 0))
	self.timePoint.absoluteTime = 0

	self.firstTime = ld.ranges.timePoint.first.absoluteTime
	self.lastTime = ld.ranges.timePoint.last.absoluteTime

	self.timer:reset()

	self.audioManager.volume = self.game.configModel.configs.settings.audio.volume
	self.audioManager:load()

	self:scrollSeconds(self.timer:getTime())
end

EditorModel.fixSettings = function(self)
	local editor = self.game.configModel.configs.settings.editor
	if editor.speed <= 0 then
		editor.speed = 1
	end
	editor.snap = math.min(math.max(editor.snap, 1), 16)
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
							volume = s[2],
							isStream = noteData.stream,
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

EditorModel.getDtpAbsolute = function(self, time, snapped)
	local ld = self.layerData
	local editor = self.game.configModel.configs.settings.editor

	local snap = editor.snap
	if ld.mode == "measure" then
		local dtp = ld:getDynamicTimePointAbsolute(192, time)
		local measureOffset = dtp.measureTime:floor()
		snap = ld:getSignature(measureOffset) * snap
	end

	return ld:getDynamicTimePointAbsolute(snapped and snap or 192, time)
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
	local editor = self.game.configModel.configs.settings.editor
	return math.floor(10 * math.log(editor.speed) / math.log(2) + 0.5)
end

EditorModel.setLogSpeed = function(self, logSpeed)
	local editor = self.game.configModel.configs.settings.editor
	editor.speed = 2 ^ (logSpeed / 10)
end

EditorModel.getMouseTime = function(self)
	local mx, my = love.graphics.inverseTransformPoint(love.mouse.getPosition())
	local noteSkin = self.game.noteSkinModel.noteSkin
	local editor = self.game.configModel.configs.settings.editor
	return (self.timePoint.absoluteTime - noteSkin:getInverseTimePosition(my) / editor.speed)
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

EditorModel.selectNote = function(self, note)
	self.graphicEngine:selectNote(note, love.keyboard.isDown("lctrl"))
end

EditorModel.grabNotes = function(self, part)
	local noteSkin = self.game.noteSkinModel.noteSkin

	self.grabbedNotes = {}

	local column = self:getColumnOver()
	local t = self:getMouseTime()
	for _, note in ipairs(self.graphicEngine.selectedNotes) do
		local _column = noteSkin:getInputColumn(note.inputType, note.inputIndex)
		if _column then
			table.insert(self.grabbedNotes, note)
			self:removeNote(note)

			note.grabbedPart = part

			note.grabbedDeltaColumn = column - _column

			if not self.lockSnap then
				if note.noteType == "ShortNote" then
					note.grabbedDeltaTime = t - note.startNoteData.timePoint.absoluteTime
					note.startNoteData.timePoint = note.startNoteData.timePoint:clone()
				elseif note.noteType == "LongNote" then
					if part == "head" then
						note.grabbedDeltaTime = t - note.startNoteData.timePoint.absoluteTime
						note.startNoteData.timePoint = note.startNoteData.timePoint:clone()
					elseif part == "tail" then
						note.grabbedDeltaTime = t - note.endNoteData.timePoint.absoluteTime
						note.endNoteData.timePoint = note.endNoteData.timePoint:clone()
					elseif part == "body" then
						note.grabbedDeltaTime = {
							t - note.startNoteData.timePoint.absoluteTime,
							t - note.endNoteData.timePoint.absoluteTime,
						}
						note.startNoteData.timePoint = note.startNoteData.timePoint:clone()
						note.endNoteData.timePoint = note.endNoteData.timePoint:clone()
					end
				end
			end
		end
	end
end

EditorModel.dropNotes = function(self)
	local ld = self.layerData
	local grabbedNotes = self.grabbedNotes
	self.grabbedNotes = {}

	if self.lockSnap then
		for _, note in ipairs(grabbedNotes) do
			self:_addNote(note)
		end
		return
	end

	local time = self:getMouseTime()
	for _, note in ipairs(grabbedNotes) do
		if note.noteType == "ShortNote" then
			local dtp = self:getDtpAbsolute(time - note.grabbedDeltaTime, true)
			note.startNoteData.timePoint = ld:checkTimePoint(dtp)
		elseif note.noteType == "LongNote" then
			if note.grabbedPart == "head" then
				local dtp = self:getDtpAbsolute(time - note.grabbedDeltaTime, true)
				note.startNoteData.timePoint = ld:checkTimePoint(dtp)
			elseif note.grabbedPart == "tail" then
				local dtp = self:getDtpAbsolute(time - note.grabbedDeltaTime, true)
				note.endNoteData.timePoint = ld:checkTimePoint(dtp)
			elseif note.grabbedPart == "body" then
				local dtp = self:getDtpAbsolute(time - note.grabbedDeltaTime[1], true)
				note.startNoteData.timePoint = ld:checkTimePoint(dtp)
				local dtp = self:getDtpAbsolute(time - note.grabbedDeltaTime[2], true)
				note.endNoteData.timePoint = ld:checkTimePoint(dtp)
			end
		end

		self:_addNote(note)
	end
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
	local editor = self.game.configModel.configs.settings.editor
	local ld = self.layerData
	if editor.tool == "ShortNote" then
		local dtp = self:getDtpAbsolute(absoluteTime, true)
		local noteData = ld:getNoteData(dtp, inputType, inputIndex)
		if noteData then
			noteData.noteType = "ShortNote"
		end
	elseif editor.tool == "LongNote" then
		local dtp = self:getDtpAbsolute(absoluteTime, true)
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

EditorModel.selectStart = function(self)
	self.graphicEngine:selectStart()
	local mx, my = love.graphics.inverseTransformPoint(love.mouse.getPosition())
	self.selectRect = {mx, my, mx, my}
	self.selectStartTime = self:getMouseTime()
	just.select(mx, my, mx, my)
end

EditorModel.selectEnd = function(self)
	self.graphicEngine:selectEnd()
	self.selectRect = nil
	just.select()
end

EditorModel.update = function(self)
	local editor = self.game.configModel.configs.settings.editor
	local noteSkin = self.game.noteSkinModel.noteSkin
	local ld = self.layerData

	for _, note in ipairs(self.grabbedNotes) do
		local time = self:getMouseTime()
		if not self.lockSnap then
			if note.noteType == "ShortNote" then
				self:getDtpAbsolute(time - note.grabbedDeltaTime):clone(note.startNoteData.timePoint)
			elseif note.noteType == "LongNote" then
				if note.grabbedPart == "head" then
					self:getDtpAbsolute(time - note.grabbedDeltaTime):clone(note.startNoteData.timePoint)
				elseif note.grabbedPart == "tail" then
					self:getDtpAbsolute(time - note.grabbedDeltaTime):clone(note.endNoteData.timePoint)
				elseif note.grabbedPart == "body" then
					self:getDtpAbsolute(time - note.grabbedDeltaTime[1]):clone(note.startNoteData.timePoint)
					self:getDtpAbsolute(time - note.grabbedDeltaTime[2]):clone(note.endNoteData.timePoint)
				end
			end
		end
		local column = self:getColumnOver()
		if column then
			column = column - note.grabbedDeltaColumn
			local inputType, inputIndex = noteSkin:getColumnInput(column, true)
			note.inputType = inputType
			note.inputIndex = inputIndex
		end
	end

	if self.selectRect then
		local mx, my = love.graphics.inverseTransformPoint(love.mouse.getPosition())
		self.selectRect[2] = noteSkin:getTimePosition((self.timer:getTime() - self.selectStartTime) * editor.speed)
		self.selectRect[3] = mx
		self.selectRect[4] = my
		just.select(self.selectRect[1], self.selectRect[2], mx, my)
	end

	local dtp = self:getDtpAbsolute(self.timer:getTime())
	if self.grabbedIntervalData then
		ld:moveInterval(self.grabbedIntervalData, dtp.absoluteTime)
	end
	self.audioManager:update()
	if self.timer.isPlaying then
		self:_scrollTimePoint(dtp)
	end

	self.graphicEngine:update()
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
	local editor = self.game.configModel.configs.settings.editor
	local snap = editor.snap
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
	local editor = self.game.configModel.configs.settings.editor
	local absoluteTime = self.timePoint.absoluteTime

	local ld = self.layerData
	if ld.mode == "interval" then
		local delta = 1 / editor.speed
		if ld.startTime ~= absoluteTime - delta then
			ld:setRange(absoluteTime - delta, absoluteTime + delta)
		end
		return
	end

	local dtp = self:getDtpAbsolute(absoluteTime)
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
	local dtp = self:getDtpAbsolute(absoluteTime)
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
	local editor = self.game.configModel.configs.settings.editor
	local dtp = self:getDtpAbsolute(absoluteTime)

	local snap = editor.snap
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
	-- 	targetSnapTime = intervalData:start() * snap
	-- elseif intervalData.prev and dtp.time > intervalData:start() and targetSnapTime < snap * intervalData:start() then
	-- 	targetSnapTime = intervalData:start() * snap
	-- elseif intervalData.prev and dtp.time == intervalData:start() and targetSnapTime < snap * intervalData:start() then
	-- 	intervalData = intervalData.prev
	-- 	targetSnapTime = (intervalData:_end() * snap):ceil() - 1
	-- end

	if intervalData.next and targetSnapTime == snap * intervalData:_end() then
		intervalData = intervalData.next
		targetSnapTime = intervalData:start() * snap
	elseif intervalData.next and targetSnapTime > snap * intervalData:_end() then
		intervalData = intervalData.next
		targetSnapTime = (intervalData:start() * snap):floor() + 1
	elseif intervalData.prev and targetSnapTime < snap * intervalData:start() then
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
	local editor = self.game.configModel.configs.settings.editor
	local dtp = self:getDtpAbsolute(self.timePoint.absoluteTime)

	local measureOffset = dtp.measureTime:floor()
	local signature = ld:getSignature(measureOffset)
	local sigSnap = signature * editor.snap

	local targetMeasureOffset
	if delta == -1 then
		targetMeasureOffset = dtp.measureTime:ceil() - 1
	else
		targetMeasureOffset = (dtp.measureTime + Fraction(1) / sigSnap):floor()
	end
	signature = ld:getSignature(targetMeasureOffset)
	sigSnap = signature * editor.snap

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
