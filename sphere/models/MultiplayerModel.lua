local class = require("class")
local delay = require("delay")
local icc_co = require("icc.co")

local MultiplayerClientRemote = require("sea.multi.remotes.MultiplayerClientRemote")
local MultiplayerClient = require("sea.multi.MultiplayerClient")

---@class sphere.MultiplayerModel
---@operator call: sphere.MultiplayerModel
local MultiplayerModel = class()

---@param cacheModel sphere.CacheModel
---@param rhythm_engine rizu.RhythmEngine
---@param configModel sphere.ConfigModel
---@param selectModel sphere.SelectModel
---@param onlineModel sphere.OnlineModel
---@param osudirectModel sphere.OsudirectModel
---@param replayBase sea.ReplayBase
function MultiplayerModel:new(cacheModel, rhythm_engine, configModel, selectModel, onlineModel, osudirectModel, replayBase)
	self.cacheModel = cacheModel
	self.rhythm_engine = rhythm_engine
	self.configModel = configModel
	self.selectModel = selectModel
	self.onlineModel = onlineModel
	self.osudirectModel = osudirectModel
	self.replayBase = replayBase

	self.sea_client = onlineModel.sea_client
	self.remote = self.sea_client.remote
	self.task_handler = self.sea_client.task_handler

	self.client = MultiplayerClient(self.remote, replayBase, self)
	self.client_remote = MultiplayerClientRemote(self.client)

	self.status = "disconnected"
end

function MultiplayerModel:load()
	self.stopRefresh = delay.every(0.5, self.refreshAsync, self)
end

function MultiplayerModel:unload()
	self.stopRefresh()
end

function MultiplayerModel:refreshAsync()
	self.status = self:getStatus()
	if not self.sea_client.connected then
		return
	end

	local user = self.onlineModel:getUser()
	self.client.user_id = user and user.id
	self.client:refreshAsync()

	-- disabled because not implemented yet
	-- local chartplay_computed = self.rhythm_engine:getChartplayComputed(true)
	-- self.remote.multiplayer:setChartplayComputed(chartplay_computed)
end

function MultiplayerModel:connect()
end

function MultiplayerModel:disconnect()
end

function MultiplayerModel:update()
end

function MultiplayerModel:getStatus()
	if self.sea_client.connected then
		return "connected"
	else
		return "disconnected"
	end
end

function MultiplayerModel:selectChart()
	local selectModel = self.selectModel

	local room = self.client:getMyRoom()
	if not room then
		return
	end

	local hash = room.chartmeta_key.hash
	local index = room.chartmeta_key.index

	print("find", hash, index)
	selectModel:findNotechart(hash, index)
	local items = selectModel.noteChartSetLibrary.items

	selectModel:setLock(false)

	self.downloadingBeatmap = nil
	local chartview = items[1]
	if chartview then
		self.chartview = chartview
		selectModel:setConfig(chartview)
		selectModel:pullNoteChartSet(true)
		self.remote.multiplayer:setChartFound(true)
		return
	end
	selectModel:setConfig({
		chartfile_set_id = 0,
		chartfile_id = 0,
		chartmeta_id = 0,
	})
	self.chartview = nil
	selectModel:pullNoteChartSet(true)
	self.remote.multiplayer:setChartFound(false)
end

MultiplayerModel.downloadNoteChart = icc_co.callwrap(function(self)
	local room = self.client:getMyRoom()
	if not room then return end

	local setId = room.notechart.osuSetId
	if self.downloadingBeatmap or not setId then
		return
	end

	self.downloadingBeatmap = {
		id = setId,
		status = "",
	}
	self.osudirectModel:downloadAsync(self.downloadingBeatmap)
	self.downloadingBeatmap.status = "done"
	self.remote.multiplayer:setChartFound(false)

	self.cacheModel:startUpdateAsync("downloads", 1)
	self:selectChart()
end)

return MultiplayerModel
