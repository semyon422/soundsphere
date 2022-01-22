local Class = require("aqua.util.Class")
local WebApi = require("sphere.models.OnlineModel.WebApi")
local AuthManager = require("sphere.models.OnlineModel.AuthManager")
local OnlineScoreManager = require("sphere.models.OnlineModel.OnlineScoreManager")
local NoteChartSubmitter = require("sphere.models.OnlineModel.NoteChartSubmitter")
local ReplaySubmitter = require("sphere.models.OnlineModel.ReplaySubmitter")

local OnlineModel = Class:new()

OnlineModel.construct = function(self)
	self.webApi = WebApi:new()
	self.authManager = AuthManager:new()
	self.onlineScoreManager = OnlineScoreManager:new()
	self.noteChartSubmitter = NoteChartSubmitter:new()
	self.replaySubmitter = ReplaySubmitter:new()
end

OnlineModel.load = function(self)
	local webApi = self.webApi
	local replaySubmitter = self.replaySubmitter
	local onlineScoreManager = self.onlineScoreManager
	local noteChartSubmitter = self.noteChartSubmitter
	local authManager = self.authManager

	authManager.onlineModel = self
	onlineScoreManager.onlineModel = self
	replaySubmitter.onlineModel = self
	noteChartSubmitter.onlineModel = self

	onlineScoreManager.replaySubmitter = replaySubmitter
	onlineScoreManager.noteChartSubmitter = noteChartSubmitter

	local config = self.configModel.configs.online
	webApi.config = config
	webApi:load()

	replaySubmitter.config = config
	noteChartSubmitter.config = config
	onlineScoreManager.config = config
	authManager.config = config

	replaySubmitter.webApi = webApi
	noteChartSubmitter.webApi = webApi
	onlineScoreManager.webApi = webApi
	authManager.webApi = webApi
end

OnlineModel.unload = function(self) end

return OnlineModel
