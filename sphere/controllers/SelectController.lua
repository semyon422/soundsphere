local class = require("class")
local thread = require("thread")
local path_util = require("path_util")
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

	local chartview = self.selectModel.chartview
	if chartview then
		self.state.inputMode:set(chartview.inputmode)
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
	local chartview = self.selectModel.chartview
	if not chartview then
		return
	end
	local realDirectory = love.filesystem.getRealDirectory(chartview.location_prefix)

	-- local path = chart.path:match("^(.+)/.-$")
	-- local realPath = self.mountModel:getRealPath(path)
	love.system.openURL(path_util.join(realDirectory, chartview.dir))
end

function SelectController:openWebNotechart()
	local chartview = self.selectModel.chartview
	if not chartview then
		return
	end

	local hash, index = chartview.hash, chartview.index
	self.onlineModel.onlineNotechartManager:openWebNotechart(hash, index)
end

---@param force boolean?
function SelectController:updateCache(force)
	local chartview = self.selectModel.chartview
	if not chartview then
		return
	end
	self.cacheModel:startUpdate({chartview.dir, chartview.location_id, "mounted_charts/" .. chartview.location_id})
end

---@param location_id string
function SelectController:updateCacheLocation(location_id)
	local cacheModel = self.cacheModel
	local state = cacheModel.shared.state
	if state == 0 or state == 3 then
		cacheModel:startUpdate({nil, location_id, "mounted_charts/" .. location_id})
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

	local chartview = selectModel.chartview
	if not chartview then
		return
	end

	local nce = NoteChartExporter()
	local noteChart = selectModel:loadNoteChart()
	ModifierModel:apply(self.playContext.modifiers, noteChart)

	nce.noteChart = noteChart
	nce.chartmeta = chartview

	local path = chartview.path
	path = path:find("^.+/.$") and path:match("^(.+)/.$") or path
	local fileName = path:match("^.+/(.-)$"):match("^(.+)%..-$")

	assert(love.filesystem.write(("userdata/export/%s.osu"):format(fileName), nce:export()))
end

return SelectController
