local Class = require("Class")
local Fraction = require("ncdk.Fraction")
local AudioManager = require("sphere.models.EditorModel.AudioManager")
local TimeManager = require("sphere.models.EditorModel.TimeManager")
local GraphicEngine = require("sphere.models.EditorModel.GraphicEngine")
local just = require("just")
local Changes = require("Changes")
local NoteChartLoader = require("sphere.models.EditorModel.NoteChartLoader")
local MainAudio = require("sphere.models.EditorModel.MainAudio")
local NcbtContext = require("sphere.models.EditorModel.NcbtContext")
local IntervalManager = require("sphere.models.EditorModel.IntervalManager")
local GraphsGenerator = require("sphere.models.EditorModel.GraphsGenerator")

local EditorModel = Class:new()

EditorModel.tools = {"Select", "ShortNote", "LongNote", "SoundNote"}
EditorModel.states = {"info", "audio", "timings", "notes"}

EditorModel.construct = function(self)
	self.noteChartLoader = NoteChartLoader:new()
	self.mainAudio = MainAudio:new()
	self.ncbtContext = NcbtContext:new()
	self.intervalManager = IntervalManager:new()
	self.graphsGenerator = GraphsGenerator:new()
	self.timer = TimeManager:new()
	self.audioManager = AudioManager:new()
	self.timer.audioManager = self.audioManager
	self.audioManager.timer = self.timer
	self.graphicEngine = GraphicEngine:new()
	self.graphicEngine.editorModel = self
	self.grabbedNotes = {}
	self.state = self.states[1]
end

EditorModel.load = function(self)
	local noteChartModel = self.game.noteChartModel
	local nc = noteChartModel.noteChart
	local editor = self.game.configModel.configs.settings.editor

	self.layerData = self.noteChartLoader:load(nc)
	local ld = self.layerData

	self.intervalManager.layerData = ld

	self.changes = Changes:new()
	ld:syncChanges(self.changes:get())

	self:fixSettings()

	self.graphsGenerator:load()

	self.resourcesLoaded = false

	self.columns = nc.inputMode:getColumns()
	self.inputMap = nc.inputMode:getInputMap()

	local audioPath = noteChartModel.noteChartEntry.path:match("^(.+)/.-$") .. "/" .. nc.metaData.audioPath
	self.mainAudio:load(audioPath)
	self.mainAudio:findOffset(nc)

	self.timePoint = ld:newTimePoint()
	ld:getDynamicTimePointAbsolute(192, 0):clone(self.timePoint)

	self.firstTime = ld.ranges.timePoint.first.absoluteTime
	self.lastTime = ld.ranges.timePoint.last.absoluteTime

	self.timer:reset()
	self.timer:setPosition(editor.time)

	self.audioManager.volume = self.game.configModel.configs.settings.audio.volume
	self.audioManager:load()

	self:scrollSeconds(self.timer:getTime())
end

EditorModel.detectTempoOffset = function(self)
	if self.mainAudio.soundData then
		self.ncbtContext:detect(self.mainAudio.soundData)
	end
end

EditorModel.applyTempoOffset = function(self)
	self.ncbtContext:apply(self.layerData)
end

EditorModel.fixSettings = function(self)
	local editor = self.game.configModel.configs.settings.editor
	if editor.speed <= 0 then
		editor.speed = 1
	end
	editor.snap = math.min(math.max(editor.snap, 1), 16)
end

EditorModel.undo = function(self)
	for i in self.changes:undo() do
		self.layerData:syncChanges(i - 1)
		print("undo i", i - 1)
	end
	self.graphicEngine:reset()
	print("undo", self.changes)
end

EditorModel.redo = function(self)
	for i in self.changes:redo() do
		self.layerData:syncChanges(i)
		print("redo i", i)
	end
	self.graphicEngine:reset()
	print("redo", self.changes)
end

EditorModel.loadResources = function(self)
	local noteChart = self.game.noteChartModel.noteChart

	self.audioManager:loadResources(noteChart)
	self.firstTime = self.audioManager.firstTime
	self.lastTime = self.audioManager.lastTime

	self.graphsGenerator:genDensityGraph(noteChart, self.firstTime, self.lastTime)
	self.graphsGenerator:genIntervalDatasGraph(self.layerData, self.firstTime, self.lastTime)

	self.audioManager:update(true)

	self.resourcesLoaded = true
end

EditorModel.getDtpAbsolute = function(self, time, snapped)
	local ld = self.layerData
	local editor = self.game.configModel.configs.settings.editor
	return ld:getDynamicTimePointAbsolute(snapped and editor.snap or 192, time)
end

EditorModel.unload = function(self) end

EditorModel.save = function(self)
	self.noteChartLoader:save()
end

EditorModel.play = function(self)
	if self.intervalManager:isGrabbed() then
		return
	end
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

EditorModel.selectNote = function(self, note)
	self.graphicEngine:selectNote(note, love.keyboard.isDown("lctrl"))
end

EditorModel.copyNotes = function(self, cut)
	if cut then
		self:startChange()
	end
	local noteSkin = self.game.noteSkinModel.noteSkin

	self.copiedNotes = {}
	local copyTimePoint

	for _, note in ipairs(self.graphicEngine.selectedNotes) do
		local _column = noteSkin:getInputColumn(note.inputType, note.inputIndex)
		if _column then
			if not copyTimePoint or note.startNoteData.timePoint < copyTimePoint then
				copyTimePoint = note.startNoteData.timePoint
			end
			table.insert(self.copiedNotes, note)
			if cut then
				self:_removeNote(note)
			end
		end
	end

	for _, note in ipairs(self.copiedNotes) do
		note.deltaStartTime = note.startNoteData.timePoint:sub(copyTimePoint)
		if note.endNoteData then
			note.deltaEndTime = note.endNoteData.timePoint:sub(copyTimePoint)
		end
	end
	if cut then
		self:nextChange()
	end
end

EditorModel.deleteNotes = function(self)
	self:startChange()
	local c = 0
	local noteSkin = self.game.noteSkinModel.noteSkin
	for _, note in ipairs(self.graphicEngine.selectedNotes) do
		local _column = noteSkin:getInputColumn(note.inputType, note.inputIndex)
		if _column then
			self:_removeNote(note)
			c = c + 1
		end
	end
	self:nextChange()
	return c
end

EditorModel.pasteNotes = function(self)
	local ld = self.layerData
	local copiedNotes = self.copiedNotes
	if not copiedNotes then
		return
	end

	self:startChange()
	local timePoint = self.timePoint
	for _, note in ipairs(copiedNotes) do
		note.startNoteData = note.startNoteData:clone()
		note.startNoteData.timePoint = ld:getTimePoint(timePoint:add(note.deltaStartTime))
		if note.endNoteData then
			note.endNoteData = note.endNoteData:clone()
			note.endNoteData.timePoint = ld:getTimePoint(timePoint:add(note.deltaEndTime))

			note.endNoteData.startNoteData = note.startNoteData
			note.startNoteData.endNoteData = note.endNoteData
		end

		self:_addNote(note)
	end
	self:nextChange()
end

EditorModel.grabNotes = function(self, part)
	local noteSkin = self.game.noteSkinModel.noteSkin
	local editor = self.game.configModel.configs.settings.editor

	self.grabbedNotes = {}

	self:startChange()
	local column = self:getColumnOver()
	local t = self:getMouseTime()
	for _, note in ipairs(self.graphicEngine.selectedNotes) do
		local _column = noteSkin:getInputColumn(note.inputType, note.inputIndex)
		if _column then
			table.insert(self.grabbedNotes, note)
			self:_removeNote(note)

			note.grabbedPart = part
			note.grabbedDeltaColumn = column - _column

			note.startNoteData = note.startNoteData:clone()
			if note.endNoteData then
				note.endNoteData = note.endNoteData:clone()
				note.startNoteData.endNoteData = note.endNoteData
				note.endNoteData.startNoteData = note.startNoteData
			end

			if not editor.lockSnap then
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
	local editor = self.game.configModel.configs.settings.editor
	local ld = self.layerData
	local grabbedNotes = self.grabbedNotes
	self.grabbedNotes = {}

	if editor.lockSnap then
		for _, note in ipairs(grabbedNotes) do
			self:_addNote(note)
		end
		self:nextChange()
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
				if note.startNoteData.timePoint == note.endNoteData.timePoint then
					local tp = ld:getTimePoint(self:getNextSnapIntervalTime(note.startNoteData.timePoint, -1))
					note.startNoteData.timePoint = tp
				end
			elseif note.grabbedPart == "tail" then
				local dtp = self:getDtpAbsolute(time - note.grabbedDeltaTime, true)
				note.endNoteData.timePoint = ld:checkTimePoint(dtp)
				if note.startNoteData.timePoint == note.endNoteData.timePoint then
					local tp = ld:getTimePoint(self:getNextSnapIntervalTime(note.startNoteData.timePoint, 1))
					note.endNoteData.timePoint = tp
				end
			elseif note.grabbedPart == "body" then
				local dtp = self:getDtpAbsolute(time - note.grabbedDeltaTime[1], true)
				note.startNoteData.timePoint = ld:checkTimePoint(dtp)
				local dtp = self:getDtpAbsolute(time - note.grabbedDeltaTime[2], true)
				note.endNoteData.timePoint = ld:checkTimePoint(dtp)
			end
		end

		self:_addNote(note)
	end
	self:nextChange()
end

EditorModel._removeNote = function(self, note)
	local ld = self.layerData
	ld:removeNoteData(note.startNoteData, note.inputType, note.inputIndex)
	if note.endNoteData then
		ld:removeNoteData(note.endNoteData, note.inputType, note.inputIndex)
	end
	self:increaseChange()
end

EditorModel.removeNote = function(self, note)
	self:startChange()
	self:_removeNote(note)
	self:nextChange()
end

EditorModel._addNote = function(self, note)
	local ld = self.layerData
	ld:addNoteData(note.startNoteData, note.inputType, note.inputIndex)
	if note.endNoteData then
		ld:addNoteData(note.endNoteData, note.inputType, note.inputIndex)
	end
	self:increaseChange()
end

EditorModel.addNote = function(self, absoluteTime, inputType, inputIndex)
	self:startChange()
	local editor = self.game.configModel.configs.settings.editor
	local ld = self.layerData
	self.graphicEngine:selectNote()
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

		local tp = ld:getTimePoint(self:getNextSnapIntervalTime(startNoteData.timePoint, 1))
		local endNoteData = ld:getNoteData(tp, inputType, inputIndex)
		if not endNoteData then
			return
		end
		endNoteData.noteType = "LongNoteEnd"

		endNoteData.startNoteData = startNoteData
		startNoteData.endNoteData = endNoteData

		local note = self.graphicEngine:newNote(startNoteData, self, inputType, inputIndex)
		self:selectNote(note)
		self:grabNotes("tail")
	end
	self:increaseChange()
	self:nextChange()
end

EditorModel.startChange = function(self)
	self.changes:reset()
	self.layerData:resetRedos()
end

EditorModel.increaseChange = function(self)
	local i = self.changes:add()
	self.layerData:syncChanges(i)
	print("add i", i)
end

EditorModel.nextChange = function(self)
	self.changes:next()
	print("next", self.changes)
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
		if not editor.lockSnap then
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
	if self.intervalManager.grabbedIntervalData then
		self.intervalManager:moveGrabbed(dtp.absoluteTime)
	end
	self.audioManager:update()

	dtp:clone(self.timePoint)
	if self.timer.isPlaying then
		self:updateRange()
	end

	self.graphicEngine:update()

	editor.time = self.timer:getTime()
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
	local delta = 1 / editor.speed
	if ld.startTime ~= absoluteTime - delta then
		ld:setRange(absoluteTime - delta, absoluteTime + delta)
	end
end

EditorModel._scrollTimePoint = function(self, timePoint)
	if not timePoint then
		return
	end

	timePoint:clone(self.timePoint)

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
	local timePoint = self:getDtpAbsolute(absoluteTime)
	self:scrollTimePoint(timePoint)
end

EditorModel.scrollSecondsDelta = function(self, delta)
	self:scrollSeconds(self.timePoint.absoluteTime + delta)
end

EditorModel.scrollSnaps = function(self, delta)
	if self.intervalManager:isGrabbed() then
		return
	end
	local ld = self.layerData
	self:scrollTimePoint(ld:getDynamicTimePoint(self:getNextSnapIntervalTime(self.timePoint, delta)))
end

EditorModel.getNextSnapIntervalTime = function(self, timePoint, delta)
	local editor = self.game.configModel.configs.settings.editor

	local snap = editor.snap
	local snapTime = timePoint.time * snap

	local targetSnapTime
	if delta == -1 then
		targetSnapTime = snapTime:ceil() - 1
	else
		targetSnapTime = snapTime:floor() + 1
	end

	local intervalData = timePoint.intervalData
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

return EditorModel
