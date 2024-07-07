local class = require("class")

local CacheModel = require("sphere.persistence.CacheModel")
local ConfigModel = require("sphere.persistence.ConfigModel")
local OsudirectModel = require("sphere.persistence.OsudirectModel")
local FileFinder = require("sphere.persistence.FileFinder")
local DifficultyModel = require("sphere.models.DifficultyModel")

local dirs = require("sphere.persistence.dirs")

---@class sphere.Persistence
---@operator call: sphere.Persistence
local Persistence = class()

function Persistence:new()
	self.difficultyModel = DifficultyModel()
	self.cacheModel = CacheModel(self.difficultyModel)
	self.configModel = ConfigModel()
	self.osudirectModel = OsudirectModel(self.configModel, self.cacheModel)
	self.fileFinder = FileFinder()
end

function Persistence:load()
	dirs.create()

	local configModel = self.configModel
	configModel:open("settings", true)
	configModel:open("select", true)
	configModel:open("play", true)
	configModel:open("input", true)
	configModel:open("online", true)
	configModel:open("urls")
	configModel:open("judgements")
	configModel:open("filters")
	configModel:open("files")
	configModel:read()

	self.cacheModel:load()
end

function Persistence:unload()
	self.configModel:write()
end

return Persistence
