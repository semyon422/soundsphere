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
	self.timer.audioManager = self.audioManager
	self.audioManager.timer = self.timer
	self.graphicEngine = GraphicEngine:new()
	self.graphicEngine.editorModel = self
	self.editorChanges.graphicEngine = self.graphicEngine
	self.noteManager.editorChanges = self.editorChanges
	self.noteManager.graphicEngine = self.graphicEngine
	self.state = self.states[1]
end

EditorModel.load = function(self)
	local noteChartModel = self.game.noteChartModel
	local nc = noteChartModel.noteChart
	local editor = self.game.configModel.configs.settings.editor

	self.layerData = self.noteChartLoader:load(nc)
	local ld = self.layerData

	self.intervalManager.layerData = ld
	self.editorChanges.layerData = ld
	self.noteManager.layerData = ld
	self.noteManager.game = self.game

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
	self:getDtpAbsolute(0):clone(self.timePoint)

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
	self.editorChanges:undo()
end

EditorModel.redo = function(self)
	self.editorChanges:redo()
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

EditorModel.getDtpAbsolute = function(self, time)
	local ld = self.layerData
	local editor = self.game.configModel.configs.settings.editor
	return ld:getDynamicTimePointAbsolute(editor.snap, time)
end

EditorModel.unload = function(self)
	self.audioManager:unload()
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
	local editor = self.game.configModel.configs.settings.editor
	local noteSkin = self.game.noteSkinModel.noteSkin

	local time = self.timer:getTime()
	editor.time = time

	self.noteManager:update()

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

	dtp:clone(self.timePoint)
	if self.timer.isPlaying then
		self:updateRange()
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
