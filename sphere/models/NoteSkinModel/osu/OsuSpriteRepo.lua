local class = require("class")
local OsuSpriteFile = require("sphere.models.NoteSkinModel.osu.OsuSpriteFile")
local OsuSpriteGroup = require("sphere.models.NoteSkinModel.osu.OsuSpriteGroup")

---@class sphere.OsuSpriteRepo
---@operator call: sphere.OsuSpriteRepo
local OsuSpriteRepo = class()

---@param prefix string
---@param paths string[]
function OsuSpriteRepo:new(prefix, paths)
	self.prefix = prefix
	self.paths = paths

	---@type sphere.OsuSpriteGroup[]
	local sprite_groups = {}
	self.sprite_groups = sprite_groups

	for _, path in ipairs(paths) do
		local sprite_file = OsuSpriteFile(path)
		local key = sprite_file:getKey()
		sprite_groups[key] = sprite_groups[key] or OsuSpriteGroup(key)
		sprite_groups[key]:add(sprite_file)
	end
end

---@param key string
---@return sphere.OsuSpriteGroup
function OsuSpriteRepo:getGroup(key)
	return self.sprite_groups[key]
end

return OsuSpriteRepo
