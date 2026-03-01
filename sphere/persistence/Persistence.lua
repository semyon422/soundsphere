local class = require("class")

local Library = require("rizu.library.Library")
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
	self.library = Library(self.difficultyModel)
	self.cacheModel = self.library
	self.configModel = ConfigModel()
	self.osudirectModel = OsudirectModel(self.configModel, self.library)
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

---@param name string
---@param default_path string
---@param mode boolean?
function Persistence:openAndReadThemeConfig(name, default_path, mode)
	local config_model = self.configModel
	config_model:open(name, true)
	config_model:read(name, default_path)
end

function Persistence:unload()
	self.configModel:write()
end

return Persistence
