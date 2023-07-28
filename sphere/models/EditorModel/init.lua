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
local EditorChanges = require("sphere.models.EditorModel.EditorChanges")
local NoteManager = require("sphere.models.EditorModel.NoteManager")
local Scroller = require("sphere.models.EditorModel.Scroller")
local Metronome = require("sphere.models.EditorModel.Metronome")

local EditorModel = Class:new()

EditorModel.tools = {"Select", "ShortNote", "LongNote", "SoundNote"}
EditorModel.states = {"info", "audio", "timings", "notes"}

EditorModel.construct = function(self)
	self.noteChartLoader = NoteChartLoader:new()
	self.mainAudio = MainAudio:new()
	self.ncbtContext = NcbtContext:new()
	self.intervalManager = IntervalManager:new()
	self.graphsGenerator = GraphsGenerator:new()
	self.editorChanges = EditorChanges:new()
	self.timer = TimeManager:new()
	self.audioManager = AudioManager:new()
	self.noteManager = NoteManager:new()
	self.graphicEngine = GraphicEngine:new()
	self.scroller = Scroller:new()
	self.metronome = Metronome:new()

	for _, v in pairs(self) do
		v.editorModel = self
	end
	self.state = self.states[1]
end

EditorModel.load = function(self)
	self.loaded = true

	local editor = self:getSettings()
	local audioSettings = self:getAudioSettings()

	self.layerData = self.noteChartLoader:load()
	local ld = self.layerData

	self.changes = Changes:new()
	ld:syncChanges(self.changes:get())

	self.graphsGenerator:load()

	self.resourcesLoaded = false

	self.timePoint = ld:newTimePoint()
	self:getDtpAbsolute(0):clone(self.timePoint)

	self.timer:pause()
	self.timer:setTime(editor.time)
	self.timer.adjustRate = audioSettings.adjustRate

	local volume = self.configModel.configs.settings.audio.volume
	self.audioManager.volume = volume
	self.audioManager:load()

	self.mainAudio.volume = volume
	self.mainAudio:load()

	self.metronome.volume = volume
	self.metronome:load()

	self.scroller:scrollSeconds(self.timer:getTime())
end

EditorModel.detectTempoOffset = function(self)
	if self.mainAudio.soundData then
		self.ncbtContext:detect(self.mainAudio.soundData)
	end
end

EditorModel.applyTempoOffset = function(self)
	self.ncbtContext:apply(self.layerData)
end

EditorModel.getSettings = function(self)
	local editor = self.configModel.configs.settings.editor
	if editor.speed <= 0 then
		editor.speed = 1
	end
	editor.snap = math.min(math.max(editor.snap, 1), 16)
	return editor
end

EditorModel.getAudioSettings = function(self)
	return self.configModel.configs.settings.audio
end

EditorModel.undo = function(self)
	self.editorChanges:undo()
end

EditorModel.redo = function(self)
	self.editorChanges:redo()
end

EditorModel.setTime = function(self, time)
	self.timer:setTime(time)
	self.audioManager:update(true)
	self.mainAudio:update(true)
end

EditorModel.loadResources = function(self)
	if not self.loaded then
		return
	end

	local noteChart = self.noteChart

	self.mainAudio:loadResources(noteChart)
	self.audioManager:loadResources(noteChart)

	self.audioManager:update(true)
	self.mainAudio:update(true)

	self:genGraphs()

	self.resourcesLoaded = true
end

EditorModel.getFirstLastTime = function(self)
	local audioManager = self.audioManager
	local mainAudio = self.mainAudio
	local ld = self.layerData

	local firstTime = math.min(
		audioManager.firstTime,
		mainAudio.offset,
		ld.ranges.timePoint.first.absoluteTime
	)
	local lastTime = math.max(
		audioManager.lastTime,
		mainAudio.offset + mainAudio.duration,
		ld.ranges.timePoint.last.absoluteTime
	)
	return firstTime, lastTime
end

EditorModel.genGraphs = function(self)
	local a, b = self:getFirstLastTime()
	self.graphsGenerator:genDensityGraph(self.noteChart, a, b)
	self.graphsGenerator:genIntervalDatasGraph(self.layerData, a, b)
end

EditorModel.getDtpAbsolute = function(self, time)
	local ld = self.layerData
	local editor = self:getSettings()
	return ld:getDynamicTimePointAbsolute(editor.snap, time)
end

EditorModel.unload = function(self)
	self.loaded = false
	self.audioManager:unload()
	self.mainAudio:unload()
	self.metronome:unload()
end

EditorModel.save = function(self)
	self.noteChartLoader:save()
end

EditorModel.play = function(self)
	if self.intervalManager:isGrabbed() then
		return
	end
	self.timer:play()
	self.audioManager:play()
	self.mainAudio:play()
end

EditorModel.pause = function(self)
	self.timer:pause()
	self.audioManager:pause()
	self.mainAudio:pause()
end

EditorModel.getLogSpeed = function(self)
	local editor = self:getSettings()
	return math.floor(10 * math.log(editor.speed) / math.log(2) + 0.5)
end

EditorModel.setLogSpeed = function(self, logSpeed)
	local editor = self:getSettings()
	editor.speed = 2 ^ (logSpeed / 10)
end

EditorModel.getMouseTime = function(self, dy)
	dy = dy or 0
	local mx, my = love.graphics.inverseTransformPoint(love.mouse.getPosition())
	local noteSkin = self.noteSkin
	local editor = self:getSettings()
	return (self.timePoint.absoluteTime - noteSkin:getInverseTimePosition(my + dy) / editor.speed)
end

EditorModel.selectNote = function(self, note)
	self.graphicEngine:selectNote(note, love.keyboard.isDown("lctrl"))
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
	local editor = self:getSettings()
	local noteSkin = self.noteSkin

	local time = self.timer:getTime()
	editor.time = time

	self.noteManager:update()
	self.metronome:update()

	if self.selectRect then
		local mx, my = love.graphics.inverseTransformPoint(love.mouse.getPosition())
		self.selectRect[2] = noteSkin:getTimePosition((time - self.selectStartTime) * editor.speed)
		self.selectRect[3] = mx
		self.selectRect[4] = my
		just.select(self.selectRect[1], self.selectRect[2], mx, my)
	end

	local dtp = self:getDtpAbsolute(time)
	if self.intervalManager.grabbedIntervalData then
		self.intervalManager:moveGrabbed(time)
	end
	self.audioManager:update()
	self.mainAudio:update()

	dtp:clone(self.timePoint)
	if self.timer.isPlaying then
		self.scroller:updateRange()
	end

	self.graphicEngine:update()
end

EditorModel.receive = function(self, event)
	if event.name == "framestarted" then
		local timer = self.timer
		timer.eventTime = event.time
	end
end

EditorModel.getSnap = function(self, j)
	local editor = self:getSettings()
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

EditorModel.getTotalBeats = function(self)
	local ld = self.layerData
	local range = ld.ranges.interval

	local a, b = range.first.timePoint, range.last.timePoint
	local beats = b:sub(a)
	local avgBeatDuration = (b.absoluteTime - a.absoluteTime) / beats

	return beats, avgBeatDuration
end

return EditorModel
