local Class = require("aqua.util.Class")

local DirectoryManager = Class:new()

DirectoryManager.createDirectories = function(self)
	self:createDirectory("userdata")
	self:createDirectory("userdata/skins")
	self:createDirectory("userdata/charts")
	self:createDirectory("userdata/export")
	self:createDirectory("userdata/hitsounds")
	self:createDirectory("userdata/replays")
	self:createDirectory("userdata/score_systems")
	self:createDirectory("userdata/screenshots")
end

DirectoryManager.createDirectory = function(self, path)
	if not love.filesystem.getInfo(path) then
		love.filesystem.createDirectory(path)
	end
end

return DirectoryManager
