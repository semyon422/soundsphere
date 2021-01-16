local Class = require("aqua.util.Class")

local OnlineController = Class:new()

OnlineController.construct = function(self)
	self.startTime = os.time()
end

OnlineController.load = function(self)
	local config = self.configModel:getConfig("settings")
	self.config = config

	local token = config.online.token
	if #token == 0 then
		print("creating new token")
		local email = config.online.email
		local password = config.online.password
		self.onlineModel:createToken(email, password)
		return
	end
	print("check session")
	self.onlineModel:checkSession()
end

OnlineController.receive = function(self, event)
	local config = self.config

	if event.name == "ScoreSubmitResponse" then
		print(event.response.message)
		print("Server received the score")
		local noteChartUploadUrl = event.response.notechart
		local replayUploadUrl = event.response.replay
		if noteChartUploadUrl then
			print("Server requested to upload the notchart")
			print("Uploading: " .. noteChartUploadUrl)
			self:submitNoteChart(event.response.notechart_hash, noteChartUploadUrl)
		end
		if replayUploadUrl then
			print("Server requested to upload the replay")
			print("Uploading: " .. replayUploadUrl)
			self:submitReplay(event.response.replay_hash, replayUploadUrl)
		end
	elseif event.name == "NoteChartSubmitResponse" then
		print(event.response.message)
		print("Server received the notechart")
	elseif event.name == "ReplaySubmitResponse" then
		print(event.response.message)
		print("Server received the replay")
	elseif event.name == "TokenResponse" then
		if event.response.status then
			config.online.token = event.response.token
			print("New token: " .. event.response.token)
			print("check session")
			self.onlineModel:checkSession()
			config.online.email = ""
			config.online.password = ""
			self.configModel:writeConfig("settings")
		else
			print(event.response.message)
		end
	elseif event.name == "SessionResponse" then
		if event.response.status then
			config.online.session = event.response.session
			print("New session: " .. event.response.session)
			self.configModel:writeConfig("settings")
			self.onlineModel:setSession(event.response.session)
		else
			print("Session was not created")
			print(event.response.message)
		end
	elseif event.name == "SessionCheckResponse" then
		if event.response.status then
			print("Current session is valid")
			print("update session")
			self.onlineModel:updateSession()
			return
		else
			print("Current session is not valid")
			print("create session")
			self.onlineModel:createSession(config.online.token)
		end
	elseif event.name == "SessionUpdateResponse" then
		print(event.response.message)
	elseif event.name == "QuickLoginGetResponse" then
		if event.response.status then
			print(event.response.key)
			config.online.quick_login_key = event.response.key
			love.system.openURL(self.onlineModel.host .. "/quick_login?key=" .. event.response.key)
		else
			print(event.response.message)
		end
	elseif event.name == "QuickLoginPostResponse" then
		if event.response.status then
			event.name = "TokenResponse"
			self:receive(event)
			config.online.quick_login_key = ""
		else
			print(event.response.message)
			print("Quick login key was deleted")
			config.online.quick_login_key = ""
		end
	end
end

OnlineController.submitNoteChart = function(self, noteChartHash, url)
	local noteChartsAtHash = self.cacheModel.cacheManager:getNoteChartsAtHash(noteChartHash)
	if noteChartsAtHash then
		self.onlineModel:submitNoteChart(noteChartsAtHash[1], url)
	end
end

OnlineController.submitReplay = function(self, replayHash, url)
	self.onlineModel:submitReplay(replayHash, url)
end

OnlineController.update = function(self, dt)
	local token = self.config.online.token
	if #token == 0 then
		return
	end

	local time = os.time()
	if time - self.startTime > 300 then
		print("check session")
		self.onlineModel:checkSession()
		self.startTime = time
	end
end

return OnlineController
