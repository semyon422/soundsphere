local class = require("class")

---@class sphere.OsuSpriteGroup
---@operator call: sphere.OsuSpriteGroup
---@field sprite_files {[sphere.OsuSpriteFrame|table]: sphere.OsuSpriteFile}
local OsuSpriteGroup = class()

local NO_FRAME = {}

---@param key string
function OsuSpriteGroup:new(key)
	self.key = key
	self.sprite_files = {}
end

---@param sprite_file sphere.OsuSpriteFile
function OsuSpriteGroup:add(sprite_file)
	assert(sprite_file:getKey() == self.key)

	if not sprite_file:isSprite() then
		return
	end

	local sprite_files = self.sprite_files

	local frame = sprite_file.frame or NO_FRAME
	local prev = sprite_files[frame]
	if not prev then
		sprite_files[frame] = sprite_file
		return
	end

	if prev:getDpi() > sprite_file:getDpi() then
		return
	end
	if prev:getDpi() == sprite_file:getDpi() and prev:ltExt(sprite_file) then
		return
	end

	sprite_files[frame] = sprite_file
end

---@return {[string]: string}
function OsuSpriteGroup:getCharPaths()
	---@type {[string]: string}
	local char_paths = {}

	for _, sprite_file in pairs(self.sprite_files) do
		local char = sprite_file:getChar()
		if char then
			char_paths[char] = sprite_file.path
		end
	end

	return char_paths
end

---@param prefer_frame boolean?
---@return string?
function OsuSpriteGroup:getSinglePath(prefer_frame)
	local sprite_files = self.sprite_files

	local zeroth_frame = sprite_files[0]
	local no_frame = sprite_files[NO_FRAME]

	if prefer_frame and zeroth_frame then
		return zeroth_frame.path
	elseif no_frame then
		return no_frame.path
	elseif zeroth_frame then
		return zeroth_frame.path
	end
end

---@return string?
---@return {[1]: integer, [2]: integer}?
function OsuSpriteGroup:getAnimation()
	local sprite_files = self.sprite_files

	local zeroth_frame = sprite_files[0]
	local no_frame = sprite_files[NO_FRAME]

	if not zeroth_frame then
		if no_frame then
			return no_frame.path
		end
		return
	end

	local max_frame = 0
	for frame = 0, #sprite_files do
		if not sprite_files[frame] then  -- break on holes
			break
		end
		max_frame = frame
	end

	return zeroth_frame:getFramePattern(), {0, max_frame}
end

return OsuSpriteGroup
