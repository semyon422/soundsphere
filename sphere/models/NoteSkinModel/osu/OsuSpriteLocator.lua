local class = require("class")
local path_util = require("path_util")

---@class sphere.OsuSpriteLocator
---@operator call: sphere.OsuSpriteLocator
---@field repos sphere.OsuSpriteRepo[]
local OsuSpriteLocator = class()

function OsuSpriteLocator:new()
	self.repos = {}
end

---@param sprite_repo sphere.OsuSpriteRepo?
function OsuSpriteLocator:addSpriteRepo(sprite_repo)
	table.insert(self.repos, sprite_repo)
end

---@param key string
---@return string?
---@return sphere.OsuSpriteGroup?
function OsuSpriteLocator:getPrefixAndGroup(key)
	for _, repo in ipairs(self.repos) do
		local group = repo:getGroup(key)
		if group then
			return repo.prefix, group
		end
	end
end

---@param key string
---@return {[string]: string}
function OsuSpriteLocator:getCharPaths(key)
	local prefix, group = self:getPrefixAndGroup(key)
	if not prefix or not group then
		return {}
	end

	---@type {[string]: string}
	local char_paths = {}

	for char, path in pairs(group:getCharPaths()) do
		char_paths[char] = path_util.join(prefix, path)
	end

	return char_paths
end

---@param key string
---@param prefer_frame boolean?
---@return string?
function OsuSpriteLocator:getSinglePath(key, prefer_frame)
	local prefix, group = self:getPrefixAndGroup(key)
	if not prefix or not group then
		return
	end

	local path = group:getSinglePath(prefer_frame)
	if not path then
		return
	end

	return path_util.join(prefix, path)
end

---@param key string
---@return string?
---@return {[1]: integer, [2]: integer}?
function OsuSpriteLocator:getAnimation(key)
	local prefix, group = self:getPrefixAndGroup(key)
	if not prefix or not group then
		return
	end

	local pattern, range = group:getAnimation()
	if not pattern then
		return
	end

	return path_util.join(prefix, pattern), range
end

return OsuSpriteLocator
