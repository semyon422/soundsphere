local Class = require("aqua.util.Class")
local json = require("json")
local Observable = require("aqua.util.Observable")
local OnlineClient = require("sphere.models.OnlineModel.OnlineClient")
local OnlineScoreManager = require("sphere.models.OnlineModel.OnlineScoreManager")
local NoteChartSubmitter = require("sphere.models.OnlineModel.NoteChartSubmitter")
local ReplaySubmitter = require("sphere.models.OnlineModel.ReplaySubmitter")

local OnlineModel = Class:new()

OnlineModel.construct = function(self)
	self.observable = Observable:new()
	self.onlineClient = OnlineClient:new()
	self.onlineScoreManager = OnlineScoreManager:new()
	self.noteChartSubmitter = NoteChartSubmitter:new()
	self.replaySubmitter = ReplaySubmitter:new()
end

OnlineModel.load = function(self)
	local replaySubmitter = self.replaySubmitter
	local onlineScoreManager = self.onlineScoreManager
	local noteChartSubmitter = self.noteChartSubmitter
	local onlineClient = self.onlineClient

	replaySubmitter.onlineModel = self
	noteChartSubmitter.onlineModel = self
	onlineScoreManager.onlineModel = self

	onlineClient:load()
	onlineScoreManager:load()
	noteChartSubmitter:load()
	replaySubmitter:load()
end

OnlineModel.unload = function(self)
	self.replaySubmitter:unload()
	self.onlineScoreManager:unload()
	self.noteChartSubmitter:unload()
	self.onlineClient:unload()
end

OnlineModel.submit = function(self, scoreTable, noteChartDataEntry, replayHash, modifierModel)
	self.onlineScoreManager:submit(scoreTable, noteChartDataEntry, replayHash, modifierModel)
end

OnlineModel.submitNoteChart = function(self, noteChartEntry)
	self.noteChartSubmitter:submitNoteChart(noteChartEntry)
end

OnlineModel.submitReplay = function(self, replayHash)
	self.replaySubmitter:submitReplay(replayHash)
end

OnlineModel.setHost = function(self, host)
	self.replaySubmitter.host = host
	self.onlineScoreManager.host = host
	self.noteChartSubmitter.host = host
end

OnlineModel.setSessionId = function(self, sessionId)
	self.replaySubmitter.sessionId = sessionId
	self.onlineScoreManager.sessionId = sessionId
	self.noteChartSubmitter.sessionId = sessionId
end

OnlineModel.setUserId = function(self, userId)
	self.replaySubmitter.userId = userId
	self.onlineScoreManager.userId = userId
	self.noteChartSubmitter.userId = userId
end

OnlineModel.receive = function(self, event)
	-- self.observable:send(event)

	if event.name == "ScoreSubmitResponse" then
		local status, response = pcall(json.decode, event.body)
		if status then
			self.observable:send({
				name = "ScoreSubmitResponse",
				response = response
			})
		else
			print(event.body)
		end
	elseif event.name == "NoteChartSubmitResponse" then
		local status, response = pcall(json.decode, event.body)
		if status then
			self.observable:send({
				name = "NoteChartSubmitResponse",
				response = response
			})
		else
			print(event.body)
		end
	end
end

return OnlineModel
