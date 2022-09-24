local Class = require("aqua.util.Class")
local extractAsync = require("sphere.filesystem.extract")
local aquathread = require("aqua.thread")

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
	local mountModel = self.game.mountModel
	if not mountModel:isAdded(path) then
		self.game.mountModel:addPath(path)
	end
	self.game.mountModel:mount(path)
	self.game.configModel:write("mount")
end

MountController.filedropped = aquathread.coro(function(self, file)
	local path = file:getFilename():gsub("\\", "/")
	if not path:find("%.osz$") then
		return
	end

	local extractPath = "userdata/charts/dropped/" .. path:match("^.+/(.-)%.osz$")

	print(("Extracting to: %s"):format(extractPath))
	local extracted = extractAsync(path, extractPath, false)
	if not extracted then
		print("Failed to extract")
		return
	end
	print("Extracted")

	self.game.cacheModel:startUpdate(extractPath, true)
end)

return MountController
