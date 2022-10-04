local Class = require("Class")

local OnlineController = Class:new()

OnlineController.construct = function(self)
	self.startTime = os.time()
end

OnlineController.load = function(self)
	self.game.onlineModel.authManager:checkSession()
	self.game.multiplayerModel:connect()
end

OnlineController.unload = function(self)
	local multiplayerModel = self.game.multiplayerModel
	if multiplayerModel.status == "connected" then
		multiplayerModel:disconnect()
	end
end

OnlineController.update = function(self, dt)
	local config = self.game.configModel.configs.online
	local token = config.token
	if #token == 0 then
		return
	end

	local time = os.time()
	if time - self.startTime > 300 then
		self.game.onlineModel.authManager:checkSession()
		self.startTime = time
	end
end

return OnlineController
