local class = require("class")
local WebApi = require("sphere.models.OnlineModel.WebApi")
local AuthManager = require("sphere.models.OnlineModel.AuthManager")
local OnlineScoreManager = require("sphere.models.OnlineModel.OnlineScoreManager")
local OnlineNotechartManager = require("sphere.models.OnlineModel.OnlineNotechartManager")

---@class sphere.OnlineModel
---@operator call: sphere.OnlineModel
local OnlineModel = class()

function OnlineModel:new()
	self.webApi = WebApi()
	self.authManager = AuthManager()
	self.onlineScoreManager = OnlineScoreManager()
	self.onlineNotechartManager = OnlineNotechartManager()
end

function OnlineModel:load()
	local webApi = self.webApi
	local onlineScoreManager = self.onlineScoreManager
	local onlineNotechartManager = self.onlineNotechartManager
	local authManager = self.authManager

	authManager.onlineModel = self
	onlineScoreManager.onlineModel = self
	onlineNotechartManager.onlineModel = self

	local configs = self.configModel.configs
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
