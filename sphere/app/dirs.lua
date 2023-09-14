local dirs = {}

local dirs_list = {
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

function dirs.create()
	for _, path in ipairs(dirs_list) do
		if not love.filesystem.getInfo(path) then
			love.filesystem.createDirectory(path)
		end
	end
end

return dirs
