local ncdk = require("ncdk")
local json = require("json")
local NoteSkin = require("sphere.screen.gameplay.CloudburstEngine.NoteSkin")

local NoteSkinLoader = {}

NoteSkinLoader.data = {}
NoteSkinLoader.path = "userdata/skins"

NoteSkinLoader.load = function(self, metaData)
	if not metaData then
		return self:loadEmptySkin()
	elseif metaData.type == "json:full" then
		return self:loadJsonRaw(metaData)
	end
end

NoteSkinLoader.loadEmptySkin = function(self)
	local noteSkin = NoteSkin:new()

	noteSkin.noteSkinData = {cses = {}}
	noteSkin.playField = {}

	noteSkin:load()

	return noteSkin
end

NoteSkinLoader.loadJsonRaw = function(self, metaData)
	local noteSkin = NoteSkin:new()
	noteSkin.metaData = metaData

	local file = io.open(metaData.directoryPath .. "/" .. metaData.path, "r")
	noteSkin.noteSkinData = json.decode(file:read("*all"))
	file:close()

	local file = io.open(metaData.directoryPath .. "/" .. noteSkin.noteSkinData.playfield, "r")
	noteSkin.playField = json.decode(file:read("*all"))
	file:close()

	noteSkin:load()

	return noteSkin
end

return NoteSkinLoader
