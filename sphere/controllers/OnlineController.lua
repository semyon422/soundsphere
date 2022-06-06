local Class = require("aqua.util.Class")

local OnlineController = Class:new()

OnlineController.construct = function(self)
	self.startTime = os.time()
end

OnlineController.load = function(self)
	self.game.onlineModel.authManager:checkSession()
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
