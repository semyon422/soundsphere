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
	local view = safeload(file:read("*all"), env)()
	file:close()

	view:load()
	self.view = view
end

UserView.unload = function(self)
	local view = self.view
	if view then
		view:unload()
	end
end

UserView.receive = function(self, event)
	local view = self.view
	if view then
		view:receive(event)
	end
end

UserView.update = function(self, dt)
	local view = self.view
	if view then
		view:update(dt)
	end
end

UserView.draw = function(self)
	local view = self.view
	if view then
		view:draw()
	end
end

return UserView
