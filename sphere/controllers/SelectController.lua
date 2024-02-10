local class = require("class")
local thread = require("thread")
local Sph = require("sph.Sph")
local NoteChartExporter = require("osu.NoteChartExporter")
local ModifierModel = require("sphere.models.ModifierModel")
local InputMode = require("ncdk.InputMode")

---@class sphere.SelectController
---@operator call: sphere.SelectController
local SelectController = class()

function SelectController:new()
	self.state = {
		inputMode = InputMode(),
	}
end

function SelectController:load()
	local selectModel = self.selectModel
	local previewModel = self.previewModel

	self.configModel:write()
	self.playContext:load(self.configModel.configs.play)
	self.modifierSelectModel:updateAdded()

	self.selectModel:setLock(false)

	selectModel:load()
	previewModel:load()

	self:applyModifierMeta()
end

function SelectController:applyModifierMeta()
	self.state.inputMode = InputMode()

	local playContext = self.playContext

	local item = self.selectModel.noteChartItem
	if item then
		self.state.inputMode:set(item.inputmode)
	end

	ModifierModel:applyMeta(playContext.modifiers, self.state)
	self.previewModel:setPitch(playContext.rate)
end

function SelectController:beginUnload()
	self.selectModel:setLock(true)
end

function SelectController:unload()
	self.playContext:save(self.configModel.configs.play)
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

	if self.modifierSelectModel:isChanged() then
		self.multiplayerModel:pushModifiers()
		self:applyModifierMeta()
	end

	if #self.configModel.configs.online.token == 0 then
		return
	end

	-- local time = love.timer.getTime()
	-- if not self.startTime or time - self.startTime > 600 then
	-- 	self:updateSession()
	-- 	self.startTime = time
	-- end
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
	local realDirectory = love.filesystem.getRealDirectory(noteChartItem.path)

	-- local path = noteChartItem.path:match("^(.+)/.-$")
	-- local realPath = self.mountModel:getRealPath(path)
	love.system.openURL(realDirectory .. "/" .. noteChartItem.location_path:match("^(.+)/.-$"))
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
	local chart = self.selectModel.noteChartItem
	if not chart then
		return
	end
	local path = chart.path:match("^(.+)/.-$")
	self.cacheModel:startUpdate({path, chart.location_id, "mounted_charts/" .. chart.location_id})
end

---@param path string?
---@param location_id string
function SelectController:updateCacheCollection(path, location_id)
	local cacheModel = self.cacheModel
	local state = cacheModel.shared.state
	if state == 0 or state == 3 then
		cacheModel:startUpdate({path, location_id, "mounted_charts/" .. location_id})
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
	assert(love.filesystem.write(chartSetPath .. "/" .. audioName .. ".sph", Sph:getDefault({
		audio = audioName .. "." .. ext
	})))

	self.cacheModel:startUpdate(chartSetPath, true)
end

function SelectController:exportToOsu()
	local selectModel = self.selectModel

	local chartItem = selectModel.noteChartItem
	if not chartItem then
		return
	end

	local nce = NoteChartExporter()
	local noteChart = selectModel:loadNoteChart()
	ModifierModel:apply(self.playContext.modifiers, noteChart)

	nce.noteChart = noteChart
	nce.chartmeta = chartItem

	local path = chartItem.path
	path = path:find("^.+/.$") and path:match("^(.+)/.$") or path
	local fileName = path:match("^.+/(.-)$"):match("^(.+)%..-$")

	assert(love.filesystem.write(("userdata/export/%s.osu"):format(fileName), nce:export()))
end

return SelectController
