local Class = require("aqua.util.Class")
local json = require("json")
local Observable = require("aqua.util.Observable")
local AuthManager = require("sphere.models.OnlineModel.AuthManager")
local OnlineScoreManager = require("sphere.models.OnlineModel.OnlineScoreManager")
local NoteChartSubmitter = require("sphere.models.OnlineModel.NoteChartSubmitter")
local ReplaySubmitter = require("sphere.models.OnlineModel.ReplaySubmitter")

local OnlineModel = Class:new()

OnlineModel.construct = function(self)
	self.observable = Observable:new()
	self.authManager = AuthManager:new()
	self.onlineScoreManager = OnlineScoreManager:new()
	self.noteChartSubmitter = NoteChartSubmitter:new()
	self.replaySubmitter = ReplaySubmitter:new()
end

OnlineModel.load = function(self)
	local replaySubmitter = self.replaySubmitter
	local onlineScoreManager = self.onlineScoreManager
	local noteChartSubmitter = self.noteChartSubmitter
	local authManager = self.authManager

	replaySubmitter.onlineModel = self
	noteChartSubmitter.onlineModel = self
	onlineScoreManager.onlineModel = self
	authManager.onlineModel = self

	authManager:load()
	onlineScoreManager:load()
	noteChartSubmitter:load()
	replaySubmitter:load()
end

OnlineModel.unload = function(self)
	self.replaySubmitter:unload()
	self.onlineScoreManager:unload()
	self.noteChartSubmitter:unload()
	self.authManager:unload()
end

OnlineModel.submit = function(self, scoreTable, noteChartDataEntry, replayHash, modifierModel)
	self.onlineScoreManager:submit(scoreTable, noteChartDataEntry, replayHash, modifierModel)
end

OnlineModel.submitNoteChart = function(self, noteChartEntry, url)
	self.noteChartSubmitter:submitNoteChart(noteChartEntry, url)
end

OnlineModel.createToken = function(self, ...)
	self.authManager:createToken(...)
end

OnlineModel.createSession = function(self, ...)
	self.authManager:createSession(...)
end

OnlineModel.checkSession = function(self, ...)
	self.authManager:checkSession(...)
end

OnlineModel.updateSession = function(self, ...)
	self.authManager:updateSession(...)
end

OnlineModel.setHost = function(self, host)
	self.replaySubmitter.host = host
	self.onlineScoreManager.host = host
	self.noteChartSubmitter.host = host
	self.authManager.host = host
end

OnlineModel.setSession = function(self, session)
	self.replaySubmitter.session = session
	self.onlineScoreManager.session = session
	self.noteChartSubmitter.session = session
	self.authManager.session = session
end

OnlineModel.setUserId = function(self, userId)
	self.replaySubmitter.userId = userId
	self.onlineScoreManager.userId = userId
	self.noteChartSubmitter.userId = userId
	self.authManager.userId = userId
end

OnlineModel.receive = function(self, event)
	local name = event.name
	if name == "ScoreSubmitResponse" or
		name == "NoteChartSubmitResponse" or
		name == "ReplaySubmitResponse" or
		name == "TokenResponse" or
		name == "SessionResponse" or
		name == "SessionCheckResponse" or
		name == "SessionUpdateResponse"
	then
		local status, response = pcall(json.decode, event.body)
		if status then
			self.observable:send({
				name = name,
				response = response
			})
		else
			print(event.body)
		end
	end
end

return OnlineModel
