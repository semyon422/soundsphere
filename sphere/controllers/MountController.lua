local Class = require("aqua.util.Class")

local MountController = Class:new()

MountController.receive = function(self, event)
	if event.name ~= "directorydropped" then
		return
	end

	local mountModel = self.mountModel
	local path = event[1]
	if not mountModel:isAdded(path) then
		self.mountModel:addPath(path)
	end
	self.mountModel:mount(path)
end

return MountController
