local Class = require("aqua.util.Class")
local aquafs = require("aqua.filesystem")
local json = require("json")

local MountManager = Class:new()

MountManager.filePath = "userdata/mount.json"

MountManager.mount = function(self)
	if not love.filesystem.exists(self.filePath) then
		self.jsonData = {}
		return
	end
	
	local file = io.open(self.filePath, "r")
	self.jsonData = json.decode(file:read("*all"))
	file:close()
	
	for mountPoint, newDir in pairs(self.jsonData) do
		aquafs.mount(newDir, mountPoint, 1)
	end
end

MountManager.unmount = function(self)
	for _, newDir in pairs(self.jsonData) do
		aquafs.unmount(newDir)
	end
end

return MountManager
