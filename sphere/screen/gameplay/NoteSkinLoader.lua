local ncdk = require("ncdk")
local json = require("json")
local NoteSkin = require("sphere.screen.gameplay.CloudburstEngine.NoteSkin")

local NoteSkinLoader = {}

NoteSkinLoader.data = {}
NoteSkinLoader.path = "userdata/skins"

NoteSkinLoader.load = function(self, metaData)
	if not metaData then
		return self:loadEmptySkin()
	elseif metaData.type == "json:full-v2" then
		return self:loadJsonFullLatest(metaData)
	elseif metaData.type == "json:full-v1" or metaData.type == "json:full" then
		return self:loadJsonFullV1(metaData)
	end
end

NoteSkinLoader.loadEmptySkin = function(self)
	local noteSkin = NoteSkin:new()

	noteSkin.noteSkinData = {cses = {}}
	noteSkin.playField = {}

	noteSkin:load()

	return noteSkin
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

	noteSkin:load()

	return noteSkin
end

NoteSkinLoader.loadJsonFullV1 = function(self, metaData)
	local noteSkin = self:loadJsonFullLatest(metaData)
	
	for _, note in pairs(noteSkin.data) do
		local head = note["Head"]
		for _, part in pairs(note) do
			part.cs = part.cs or head.cs
			part.layer = part.layer or head.layer
			part.image = part.image or head.image
			
			part.sb = {}

			part.gc = {}
			local gc = part.gc

			gc.x = {part.x or head.x, -(part.fx or head.fx)}
			gc.y = {part.y or head.y, -(part.fy or head.fy)}
			gc.w = {part.w or head.w}
			gc.h = {part.h or head.h}
			gc.ox = {part.ox or head.ox}
			gc.oy = {part.oy or head.oy}
		end
	end

	return noteSkin
end

return NoteSkinLoader
