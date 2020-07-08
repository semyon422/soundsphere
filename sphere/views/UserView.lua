local Class		= require("aqua.util.Class")
local safeload	= require("aqua.util.safeload")

local UserView = Class:new()

UserView.setPath = function(self, path)
	self.path = path
end

UserView.load = function(self)
	local env = {global = _G}
	self.env = env

	local file = io.open(self.path, "r")
	safeload(file:read("*all"), env)()
	file:close()

	env.load()
end

UserView.unload = function(self)
	local env = self.env
	if env then
		env.unload()
	end
end

UserView.receive = function(self, event)
	local env = self.env
	if env then
		env.receive(event)
	end
end

UserView.update = function(self, dt)
	local env = self.env
	if env then
		env.update(dt)
	end
end

UserView.draw = function(self)
	local env = self.env
	if env then
		env.draw()
	end
end

return UserView
