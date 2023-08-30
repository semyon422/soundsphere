local class = require("class")
local thread = require("thread")
local InputMode = require("ncdk.InputMode")
local SPH = require("sph.SPH")
local NoteChartExporter = require("osu.NoteChartExporter")

---@class sphere.SelectController
---@operator call: sphere.SelectController
local SelectController = class()

function SelectController:load()
	local noteChartModel = self.noteChartModel
	local selectModel = self.selectModel
	local previewModel = self.previewModel

	self.configModel:write()
	self.modifierModel:setConfig(self.configModel.configs.modifier)

	self.selectModel:setLock(false)

	noteChartModel:load()
	selectModel:load()
	previewModel:load()

	self:applyModifierMeta()
end

function SelectController:applyModifierMeta()
	local state = {}
	state.timeRate = 1
	state.inputMode = InputMode()

	local item = self.selectModel.noteChartItem
	if item then
		state.inputMode:set(item.inputMode)
	end

	self.modifierModel:applyMeta(state)
	self.previewModel:setPitch(state.timeRate)
end

function SelectController:beginUnload()
	self.selectModel:setLock(true)
end

function SelectController:unload()
	self.noteSkinModel:load()
	self.configModel:write()
end

function SelectController:update()
	self.previewModel:update()

	self.windowModel:setVsyncOnSelect(true)

	local selectModel = self.selectModel
	if selectModel:isChanged() then
		self.backgroundModel:setBackgroundPath(selectModel:getBackgroundPath())
		self.previewModel:setAudioPathPreview(selectModel:getAudioPathPreview())
		self:applyModifierMeta()
	end

	local osudirectModel = self.osudirectModel
	if osudirectModel:isChanged() then
		local backgroundUrl = osudirectModel:getBackgroundUrl()
		local previewUrl = osudirectModel:getPreviewUrl()
		self.backgroundModel:loadBackgroundDebounce(backgroundUrl)
		self.previewModel:loadPreviewDebounce(previewUrl)
	end

	if self.modifierModel:isChanged() then
		self.multiplayerModel:pushModifiers()
		self:applyModifierMeta()
	end

	if #self.configModel.configs.online.token == 0 then
		return
	end

	local time = love.timer.getTime()
	if not self.startTime or time - self.startTime > 600 then
		self:updateSession()
		self.startTime = time
	end
end

SelectController.updateSession = thread.coro(function(self)
	self.onlineModel.authManager:updateSessionAsync()
	self.configModel:write()
end)

function SelectController:openDirectory()
	local noteChartItem = self.selectModel.noteChartItem
	if not noteChartItem then
		return
	end
	local path = noteChartItem.path:match("^(.+)/.-$")

	local realDirectory = love.filesystem.getRealDirectory(path)
	if not realDirectory then
		return
	end

	local realPath
	if self.mountModel:isMountPath(realDirectory) then
		realPath = self.mountModel:getRealPath(path)
	else
		realPath = realDirectory .. "/" .. path
	end
	love.system.openURL(realPath)
end

function SelectController:openWebNotechart()
	local noteChartItem = self.selectModel.noteChartItem
	if not noteChartItem then
		return
	end

	local hash, index = noteChartItem.hash, noteChartItem.index
	self.onlineModel.onlineNotechartManager:openWebNotechart(hash, index)
end

---@param force boolean?
function SelectController:updateCache(force)
	local noteChartItem = self.selectModel.noteChartItem
	if not noteChartItem then
		return
	end
	local path = noteChartItem.path:match("^(.+)/.-$")
	self.cacheModel:startUpdate(path, force)
end

---@param path string
---@param force boolean?
function SelectController:updateCacheCollection(path, force)
	local cacheModel = self.cacheModel
	local state = cacheModel.shared.state
	if state == 0 or state == 3 then
		cacheModel:startUpdate(path, force)
	else
		cacheModel:stopUpdate()
	end
end

---@param event table
function SelectController:receive(event)
	if event.name == "filedropped" then
		self:filedropped(event[1])
	end
end

local exts = {
	mp3 = true,
	ogg = true,
}

---@param file love.File
function SelectController:filedropped(file)
	local path = file:getFilename():gsub("\\", "/")

	local _name, ext = path:match("^(.+)%.(.-)$")
	if not exts[ext] then
		return
	end

	local audioName = _name:match("^.+/(.-)$")
	local chartSetPath = "userdata/charts/editor/" .. os.time() .. " " .. audioName

	love.filesystem.createDirectory(chartSetPath)
	assert(love.filesystem.write(chartSetPath .. "/" .. audioName .. "." .. ext, file:read()))
	assert(love.filesystem.write(chartSetPath .. "/" .. audioName .. ".sph", SPH:getDefault({
		audio = audioName .. "." .. ext
	})))

	self.cacheModel:startUpdate(chartSetPath, true)
end

function SelectController:exportToOsu()
	local nce = NoteChartExporter()

	local noteChartModel = self.noteChartModel
	noteChartModel:load()
	noteChartModel:loadNoteChart()

	self.modifierModel:apply(noteChartModel.noteChart)

	nce.noteChart = noteChartModel.noteChart
	nce.noteChartEntry = noteChartModel.noteChartEntry
	nce.noteChartDataEntry = noteChartModel.noteChartDataEntry

	if not noteChartModel.noteChartEntry then
		return
	end

	local path = noteChartModel.noteChartEntry.path
	path = path:find("^.+/.$") and path:match("^(.+)/.$") or path
	local fileName = path:match("^.+/(.-)$"):match("^(.+)%..-$")

	assert(love.filesystem.write(("userdata/export/%s.osu"):format(fileName), nce:export()))
end

return SelectController
