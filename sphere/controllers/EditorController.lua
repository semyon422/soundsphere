local Class = require("Class")
local NoteChartExporter = require("sph.NoteChartExporter")
local NoteChartResourceLoader = require("sphere.database.NoteChartResourceLoader")
local FileFinder = require("sphere.filesystem.FileFinder")

local EditorController = Class:new()

EditorController.load = function(self)
	local noteChartModel = self.game.noteChartModel
	noteChartModel:load()
	noteChartModel:loadNoteChart()

	local noteSkin = self.game.noteSkinModel:getNoteSkin(noteChartModel.noteChart.inputMode)
	noteSkin:loadData()

	self.game.editorModel:load()
	self.game.previewModel:stop()

	FileFinder:reset()
	FileFinder:addPath(noteChartModel.noteChartEntry.path:match("^(.+)/.-$"))
	FileFinder:addPath("userdata/hitsounds")
	FileFinder:addPath("userdata/hitsounds/midi")

	NoteChartResourceLoader.game = self.game
	NoteChartResourceLoader:load(noteChartModel.noteChartEntry.path, noteChartModel.noteChart, function()
		self.game.editorModel:loadResources()
	end)

	local graphics = self.game.configModel.configs.settings.graphics
	local flags = graphics.mode.flags
	if graphics.vsyncOnSelect then
		self.game.baseVsync = flags.vsync ~= 0 and flags.vsync or 1
		flags.vsync = 0
	end
end

EditorController.unload = function(self)
	self.game.editorModel:unload()

	local graphics = self.game.configModel.configs.settings.graphics
	local flags = graphics.mode.flags
	if graphics.vsyncOnSelect and flags.vsync == 0 then
		flags.vsync = self.game.baseVsync
	end
end

EditorController.save = function(self)
	local noteChartModel = self.game.noteChartModel

	self.game.editorModel:save()

	local exp = NoteChartExporter:new()
	exp.noteChart = noteChartModel.noteChart

	love.filesystem.write(noteChartModel.noteChartEntry.path, exp:export())
end

EditorController.receive = function(self, event)
	self.game.editorModel:receive(event)
end

return EditorController
