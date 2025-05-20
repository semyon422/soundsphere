local class = require("class")
local remote = require("remote")

---@class sphere.MultiplayerController
---@operator call: sphere.MultiplayerController
local MultiplayerController = class()

---@param multiplayerModel sphere.MultiplayerModel
---@param configModel sphere.ConfigModel
---@param selectModel sphere.SelectModel
---@param replayBase sea.ReplayBase
function MultiplayerController:new(
	multiplayerModel,
	configModel,
	selectModel,
	replayBase
)
	self.multiplayerModel = multiplayerModel
	self.configModel = configModel
	self.selectModel = selectModel
	self.replayBase = replayBase
end

function MultiplayerController:load()
	local mpModel = self.multiplayerModel
	mpModel:load()
end

function MultiplayerController:beginUnload()
	self.selectModel:setLock(true)
end

function MultiplayerController:unload()
	self.multiplayerModel:unload()
end

function MultiplayerController:update()
	self.multiplayerModel:update()
end

return MultiplayerController
