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

---@param keys string[]
---@return string?
---@return sphere.OsuSpriteGroup?
function OsuSpriteLocator:getPrefixAndGroup(keys)
	for _, repo in ipairs(self.repos) do
		for _, key in ipairs(keys) do
			local group = repo:getGroup(key)
			if group then
				return repo.prefix, group
			end
		end
	end
end

---@param keys string[]
---@return {[string]: string}
function OsuSpriteLocator:getCharPaths(keys)
	local prefix, group = self:getPrefixAndGroup(keys)
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

---@param keys string[]
---@param prefer_frame boolean?
---@return string?
function OsuSpriteLocator:getSinglePath(keys, prefer_frame)
	local prefix, group = self:getPrefixAndGroup(keys)
	if not prefix or not group then
		return
	end

	local path = group:getSinglePath(prefer_frame)
	if not path then
		return
	end

	return path_util.join(prefix, path)
end

---@param keys string[]
---@return string?
---@return {[1]: integer, [2]: integer}?
function OsuSpriteLocator:getAnimation(keys)
	local prefix, group = self:getPrefixAndGroup(keys)
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
