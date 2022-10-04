local Class = require("Class")
local WebApi = require("sphere.models.OnlineModel.WebApi")
local AuthManager = require("sphere.models.OnlineModel.AuthManager")
local OnlineScoreManager = require("sphere.models.OnlineModel.OnlineScoreManager")
local OnlineNotechartManager = require("sphere.models.OnlineModel.OnlineNotechartManager")

local OnlineModel = Class:new()

OnlineModel.construct = function(self)
	self.webApi = WebApi:new()
	self.authManager = AuthManager:new()
	self.onlineScoreManager = OnlineScoreManager:new()
	self.onlineNotechartManager = OnlineNotechartManager:new()
end

OnlineModel.load = function(self)
	local webApi = self.webApi
	local onlineScoreManager = self.onlineScoreManager
	local onlineNotechartManager = self.onlineNotechartManager
	local authManager = self.authManager

	authManager.onlineModel = self
	onlineScoreManager.onlineModel = self
	onlineNotechartManager.onlineModel = self

	local configs = self.game.configModel.configs
	webApi.token = configs.online.token
	webApi.host = configs.urls.host
	webApi:load()

	authManager.config = configs.online
	onlineNotechartManager.urls = configs.urls

	onlineNotechartManager.webApi = webApi
	onlineScoreManager.webApi = webApi
	authManager.webApi = webApi
end

return OnlineModel
