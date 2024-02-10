local class = require("class")
local path_util = require("path_util")
local NoteChartExporter = require("sph.NoteChartExporter")
local OsuNoteChartExporter = require("osu.NoteChartExporter")

---@class sphere.EditorController
---@operator call: sphere.EditorController
local EditorController = class()

function EditorController:load()
	local selectModel = self.selectModel
	local editorModel = self.editorModel
	local fileFinder = self.fileFinder

	local noteChart = selectModel:loadNoteChart()
	local chartview = selectModel.chartview

	local noteSkin = self.noteSkinModel:loadNoteSkin(tostring(noteChart.inputMode))
	noteSkin:loadData()
	noteSkin.editor = true

	editorModel.noteSkin = noteSkin
	editorModel.noteChart = noteChart
	editorModel:load()

	self.previewModel:stop()

	fileFinder:reset()
	fileFinder:addPath(chartview.location_dir)
	fileFinder:addPath(noteSkin.directoryPath)
	fileFinder:addPath("userdata/hitsounds")
	fileFinder:addPath("userdata/hitsounds/midi")

	self.resourceModel:load(chartview.name, noteChart, function()
		editorModel:loadResources()
	end)

	self.windowModel:setVsyncOnSelect(false)
end

function EditorController:unload()
	self.editorModel:unload()

	self.windowModel:setVsyncOnSelect(true)
end

function EditorController:save()
	local selectModel = self.selectModel
	local editorModel = self.editorModel

	self.editorModel:save()
	self.editorModel:genGraphs()

	local exp = NoteChartExporter()
	exp.noteChart = editorModel.noteChart

	local path = selectModel.chartview.path:gsub(".sph$", "") .. ".sph"

	love.filesystem.write(path, exp:export())

	self.cacheModel:startUpdate(selectModel.chartview.path:match("^(.+)/.-$"))
end

function EditorController:saveToOsu()
	local selectModel = self.selectModel
	local editorModel = self.editorModel

	self.editorModel:save()

	local chartview = selectModel.chartview
	local exp = OsuNoteChartExporter()
	exp.noteChart = editorModel.noteChart
	exp.chartmeta = chartview

	local path = chartview.path
	path = path:gsub(".osu$", ""):gsub(".sph$", "") .. ".sph.osu"

	love.filesystem.write(path, exp:export())
end

---@param event table
function EditorController:receive(event)
	self.editorModel:receive(event)
	if event.name == "filedropped" then
		self:filedropped(event[1])
	end
end

local exts = {
	mp3 = true,
	ogg = true,
}

---@param file love.File
function EditorController:filedropped(file)
	local path = file:getFilename():gsub("\\", "/")

	local _name, ext = path:match("^(.+)%.(.-)$")
	if not exts[ext] then
		return
	end

	local audioName = _name:match("^.+/(.-)$")
	local chartSetPath = "userdata/charts/editor/" .. os.time() .. " " .. audioName

	love.filesystem.write(chartSetPath .. "/" .. audioName .. "." .. ext, file:read())
end

return EditorController
