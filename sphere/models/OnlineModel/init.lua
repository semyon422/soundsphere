local Class = require("aqua.util.Class")
local Observable = require("aqua.util.Observable")
local OnlineClient = require("sphere.models.OnlineModel.OnlineClient")
local OnlineScoreManager = require("sphere.models.OnlineModel.OnlineScoreManager")

local OnlineModel = Class:new()

OnlineModel.construct = function(self)
	self.observable = Observable:new()
	self.onlineClient = OnlineClient:new()
	self.onlineScoreManager = OnlineScoreManager:new()
end

OnlineModel.load = function(self)
    local onlineScoreManager = self.onlineScoreManager
    local onlineClient = self.onlineClient

    onlineScoreManager.onlineClient = onlineClient

    onlineClient:load()
    onlineScoreManager:load()
end

OnlineModel.unload = function(self)
    self.onlineScoreManager:unload()
    self.onlineClient:unload()
end

OnlineModel.submit = function(self, score)
    self.onlineScoreManager:submit(score)
end

OnlineModel.receive = function(self, event)
	self.observable:send(event)
end

return OnlineModel
