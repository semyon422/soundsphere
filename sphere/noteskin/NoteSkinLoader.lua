local ncdk = require("ncdk")
local json = require("json")
local toml = require("lua-toml.toml")
local NoteSkin = require("sphere.screen.gameplay.GraphicEngine.NoteSkin")
local TomlNoteSkinLoader = require("sphere.noteskin.TomlNoteSkinLoader")

local NoteSkinLoader = {}

NoteSkinLoader.data = {}
NoteSkinLoader.path = "userdata/skins"

NoteSkinLoader.load = function(self, metaData)
	if metaData.type == "toml:simple-v2" then
		return self:loadTomlSimpleLatest(metaData)
	elseif metaData.type == "json:full-v3" then
		return self:loadJsonFullLatest(metaData)
	else
		return self:loadEmptySkin()
	end
end

NoteSkinLoader.loadEmptySkin = function(self)
	local noteSkin = NoteSkin:new()

	noteSkin.noteSkinData = {cses = {}}
	noteSkin.playField = {}
	noteSkin.env = {}

	noteSkin:load()

	return noteSkin
end

NoteSkinLoader.loadTomlSimpleV1 = function(self, metaData)
	return TomlNoteSkinLoader:new():load(metaData, 1)
end

NoteSkinLoader.loadTomlSimpleLatest = function(self, metaData)
	return TomlNoteSkinLoader:new():load(metaData)
end

local safeload = function(chunk, env)
	if chunk:byte(1) == 27 then
		error("bytecode is not allowed")
	end
	local f, message = loadstring(chunk)
	if not f then
		error(message)
	end
	setfenv(f, env)
	return f
end

NoteSkinLoader.loadJsonFullLatest = function(self, metaData)
	local noteSkin = NoteSkin:new()
	noteSkin.metaData = metaData

	local file = io.open(metaData.directoryPath .. "/" .. metaData.path, "r")
	noteSkin.noteSkinData = json.decode(file:read("*all"))
	file:close()

	local file = io.open(metaData.directoryPath .. "/" .. noteSkin.noteSkinData.playfield, "r")
	noteSkin.playField = json.decode(file:read("*all"))
	file:close()

	local file = io.open(metaData.directoryPath .. "/" .. noteSkin.noteSkinData.env, "r")
	noteSkin.env = {}
	noteSkin.env.math = math
	safeload(file:read("*all"), noteSkin.env)()
	file:close()

	noteSkin:load()

	return noteSkin
end

return NoteSkinLoader
