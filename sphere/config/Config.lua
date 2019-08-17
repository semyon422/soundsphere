local json = require("json")

local Config = {}

Config.path = "userdata/config.json"

Config.read = function(self)
	self.data = {}
	if love.filesystem.exists(self.path) then
		local file = io.open(self.path, "r")
		self.data = json.decode(file:read("*all"))
		file:close()
	end
	self:setDefaultValues()
end

Config.write = function(self)
	local file = io.open(self.path, "w")
	file:write(json.encode(self.data))
	return file:close()
end

Config.setDefaultValues = function(self)
	local data = self.data
	
	data.dim = data.dim or {}
	data.dim.selection = data.dim.selection or 0.5
	data.dim.gameplay = data.dim.gameplay or 0.75
	
	data.speed = data.speed or 1
	data.fps = data.fps or 240
	
	data.volume = data.volume or {}
	data.volume.main = data.volume.main or 1
	data.volume.music = data.volume.music or 1
	data.volume.effects = data.volume.effects or 1
end

return Config
