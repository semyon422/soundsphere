local Class = require("aqua.util.Class")

local DirectoryManager = Class:new()

local defaultDirectories = {
	"userdata",
	"userdata/skins",
	"userdata/charts",
	"userdata/charts/downloads",
	"userdata/export",
	"userdata/hitsounds",
	"userdata/replays",
	"userdata/score_systems",
	"userdata/screenshots",
}

DirectoryManager.createDirectories = function(self)
	for _, path in ipairs(defaultDirectories) do
		if not love.filesystem.getInfo(path) then
			love.filesystem.createDirectory(path)
		end
	end
end

return DirectoryManager
