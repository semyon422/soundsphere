local Class = require("aqua.util.Class")
local extract = require("sphere.filesystem.extract")

local MountController = Class:new()

MountController.receive = function(self, event)
	if event.name == "directorydropped" then
		return self:directorydropped(event[1])
	elseif event.name == "filedropped" then
		return self:filedropped(event[1])
	end
end

MountController.directorydropped = function(self, path)
	path = path:gsub("\\", "/")
	local mountModel = self.mountModel
	if not mountModel:isAdded(path) then
		self.mountModel:addPath(path)
	end
	self.mountModel:mount(path)
end

MountController.filedropped = function(self, file)
	local path = file:getFilename():gsub("\\", "/")
	if not path:find("%.osz$") then
		return
	end

	local extractPath = "userdata/charts/dropped/" .. path:match("^.+/(.-)%.osz$")

	print(("Extracting to: %s"):format(extractPath))
	local extracted = extract(path, extractPath, false)
	print(extracted and "Extracted" or "Failed to extract")
end

return MountController
