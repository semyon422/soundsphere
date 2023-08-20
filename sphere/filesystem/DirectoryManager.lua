local class = require("class")

---@class sphere.DirectoryManager
---@operator call: sphere.DirectoryManager
local DirectoryManager = class()

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

function DirectoryManager:createDirectories()
	for _, path in ipairs(defaultDirectories) do
		if not love.filesystem.getInfo(path) then
			love.filesystem.createDirectory(path)
		end
	end
end

return DirectoryManager
