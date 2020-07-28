local json = require("json")
local safeload = require("aqua.util.safeload")
local TomlNoteSkinLoader = require("sphere.models.NoteSkinModel.TomlNoteSkinLoader")

local NoteSkinLoader = {}

NoteSkinLoader.data = {}
NoteSkinLoader.path = "userdata/skins"

NoteSkinLoader.load = function(self, noteSkin)
	if noteSkin.type == "toml:simple-v3" then
		return self:loadTomlSimpleLatest(noteSkin)
	elseif noteSkin.type == "json:full-v3" then
		return self:loadJsonFullLatest(noteSkin)
	end
end

NoteSkinLoader.loadTomlSimpleLatest = function(self, noteSkin)
	return TomlNoteSkinLoader:new():load(noteSkin)
end

NoteSkinLoader.loadJsonFullLatest = function(self, noteSkin)
	local file = io.open(noteSkin.directoryPath .. "/" .. noteSkin.path, "r")
	noteSkin.data = json.decode(file:read("*all"))
	file:close()

	local file = io.open(noteSkin.directoryPath .. "/" .. noteSkin.data.playfield, "r")
	noteSkin.playField = json.decode(file:read("*all"))
	file:close()

	local file = io.open(noteSkin.directoryPath .. "/" .. noteSkin.data.env, "r")
	noteSkin.env = {}
	noteSkin.env.math = math
	safeload(file:read("*all"), noteSkin.env)()
	file:close()

	noteSkin.notes = noteSkin.data.notes or {}
end

return NoteSkinLoader
