local aquafs	= require("aqua.filesystem")
local Class		= require("aqua.util.Class")
local json		= require("json")

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

	for _, entry in pairs(self.jsonData) do
		aquafs.mount(entry[1], entry[2], 1)
	end
end

MountManager.unmount = function(self)
	for _, newDir in pairs(self.jsonData) do
		aquafs.unmount(newDir)
	end
end

return MountManager
