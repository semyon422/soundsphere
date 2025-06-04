local class = require("class")
local thread = require("thread")
local path_util = require("path_util")
local fs_util = require("fs_util")
local Sph = require("sph.Sph")
local ChartEncoder = require("osu.ChartEncoder")
local ModifierModel = require("sphere.models.ModifierModel")
local ModifiersMetaState = require("sea.compute.ModifiersMetaState")
local InputMode = require("ncdk.InputMode")
local Path = require("Path")

---@class sphere.SelectController
---@operator call: sphere.SelectController
local SelectController = class()

---@param selectModel sphere.SelectModel
---@param modifierSelectModel sphere.ModifierSelectModel
---@param noteSkinModel sphere.NoteSkinModel
---@param configModel sphere.ConfigModel
---@param multiplayerModel sphere.MultiplayerModel
---@param onlineModel sphere.OnlineModel
---@param cacheModel sphere.CacheModel
---@param osudirectModel sphere.OsudirectModel
---@param windowModel sphere.WindowModel
---@param replayBase sea.ReplayBase
---@param backgroundModel sphere.BackgroundModel
---@param previewModel sphere.PreviewModel
---@param chartPreviewModel sphere.ChartPreviewModel
function SelectController:new(
	selectModel,
	modifierSelectModel,
	noteSkinModel,
	configModel,
	multiplayerModel,
	onlineModel,
	cacheModel,
	osudirectModel,
	windowModel,
	replayBase,
	backgroundModel,
	previewModel,
	chartPreviewModel
)
	self.selectModel = selectModel
	self.modifierSelectModel = modifierSelectModel
	self.noteSkinModel = noteSkinModel
	self.configModel = configModel
	self.multiplayerModel = multiplayerModel
	self.onlineModel = onlineModel
	self.cacheModel = cacheModel
	self.osudirectModel = osudirectModel
	self.windowModel = windowModel
	self.replayBase = replayBase
	self.backgroundModel = backgroundModel
	self.previewModel = previewModel
	self.chartPreviewModel = chartPreviewModel
	self.state = ModifiersMetaState()
end

function SelectController:load()
	local selectModel = self.selectModel

	self.configModel:write()
	self.replayBase:importReplayBase(self.configModel.configs.play)
	self.modifierSelectModel:updateAdded()

	self.selectModel:setLock(false)

	selectModel:load()
	self.previewModel:load()

	self:applyModifierMeta()
end

function SelectController:applyModifierMeta()
	self.state.inputMode = InputMode()
	self.state.custom = false

	local replayBase = self.replayBase

	local chartview = self.selectModel.chartview
	if not chartview then
		replayBase.columns_order = nil
		return
	end

	self.previewModel:setRate(replayBase.rate)
	self.state.inputMode:set(chartview.inputmode)
	self.state:resetOrder()

	ModifierModel:applyMeta(replayBase.modifiers, self.state)

	if replayBase.columns_order and #replayBase.columns_order ~= self.state.inputMode:getColumns() then
		replayBase.columns_order = nil
	end
end

function SelectController:beginUnload()
	self.selectModel:setLock(true)
end

function SelectController:unload()
	self.replayBase:exportReplayBase(self.configModel.configs.play)
	self.configModel:write()
end

function SelectController:update()
	self.previewModel:update()

	self.windowModel:setVsyncOnSelect(true)

	local selectModel = self.selectModel
	if selectModel:isChanged() then
		self.backgroundModel:setBackgroundPath(selectModel:getBackgroundPath())
		self.previewModel:setAudioPathPreview(selectModel:getAudioPathPreview())
		self.previewModel:onLoad(function()
			self.chartPreviewModel:setChartview(selectModel.chartview)
		end)
		self:applyModifierMeta()
	end

	local osudirectModel = self.osudirectModel
	if osudirectModel:isChanged() then
		local backgroundUrl = osudirectModel:getBackgroundUrl()
		local previewUrl = osudirectModel:getPreviewUrl()
		self.backgroundModel:setBackgroundPath(backgroundUrl)
		self.previewModel:setAudioPathPreview(previewUrl)
	end

	if self.modifierSelectModel:isChanged() then
		self.multiplayerModel.client:updateReplayBase()
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
	local location = self.cacheModel.locationsRepo:selectLocationById(chartview.location_id)
	if not location then
		return
	end

	local dir_path = Path(location.path) .. Path(chartview.dir)

	if not dir_path.absolute then
		local source = love.filesystem.getSource()
		if source:find("^.+%.love$") then
			source = love.filesystem.getSourceBaseDirectory()
		end
		dir_path = Path(source) .. dir_path
	end

	love.system.openURL(tostring(dir_path))
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
	self.cacheModel:startUpdate(chartview.dir, chartview.location_id)
end

---@param location_id string
function SelectController:updateCacheLocation(location_id)
	local cacheModel = self.cacheModel
	local state = cacheModel.shared.state
	if state == 0 or state == 3 then
		cacheModel:startUpdate(nil, location_id)
	else
		cacheModel:stopTask()
	end
end

---@param event table
function SelectController:receive(event)
	if event.name == "filedropped" then
		self:filedropped(event[1])
	elseif event.name == "directorydropped" then
		self:directorydropped(event[1])
	end
end

---@param path string
function SelectController:directorydropped(path)
	self.cacheModel.locationManager:updateLocationPath(path)
end

local filedropped_handlers = {}

function filedropped_handlers.new_chart(self, path, data)
	local _name, ext = path:match("^(.+)%.(.-)$")
	local audioName = _name:match("^.+/(.-)$")
	local location_path = path_util.join("editor", os.time() .. " " .. audioName)
	local chartSetPath = path_util.join("userdata/charts", location_path)

	love.filesystem.createDirectory(chartSetPath)
	assert(love.filesystem.write(chartSetPath .. "/" .. audioName .. "." .. ext, data))
	assert(love.filesystem.write(chartSetPath .. "/" .. audioName .. ".sph", Sph:getDefault({
		audio = audioName .. "." .. ext
	})))

	self.cacheModel:startUpdate(location_path, 1)
end

function filedropped_handlers.add_zip(self, path, data)
	local location_path = path_util.join("dropped", path:match("^.+/(.-)%.osz$"))
	local extractPath = path_util.join("userdata/charts", location_path)

	print(("Extracting to: %s"):format(extractPath))
	print(path, extractPath)
	local extracted = fs_util.extractAsync(path, extractPath, false)
	if not extracted then
		print("Failed to extract")
		return
	end
	print("Extracted")

	self.cacheModel:startUpdate(location_path, 1)
end
filedropped_handlers.add_zip = thread.coro(filedropped_handlers.add_zip)

local exts = {
	mp3 = filedropped_handlers.new_chart,
	ogg = filedropped_handlers.new_chart,
	osz = filedropped_handlers.add_zip,
}

---@param file love.File
function SelectController:filedropped(file)
	local path = file:getFilename():gsub("\\", "/")

	local ext = path:match("^.+%.(.-)$")
	local handler = exts[ext]
	if not handler then
		return
	end

	file:open("r")
	local data = file:read()
	handler(self, path, data)
end

function SelectController:exportToOsu()
	local selectModel = self.selectModel

	local chartview = selectModel.chartview
	if not chartview then
		return
	end

	local encoder = ChartEncoder()

	local chart, chartmeta = selectModel:loadChartAbsolute()
	ModifierModel:apply(self.replayBase.modifiers, chart)

	local data = encoder:encode({{
		chart = chart,
		chartmeta = chartmeta,
	}})

	local path = chartview.path
	path = path:find("^.+/.$") and path:match("^(.+)/.$") or path
	local fileName = path:match("^.+/(.-)$"):match("^(.+)%..-$")

	assert(love.filesystem.write(("userdata/export/%s.osu"):format(fileName), data))
end

return SelectController
