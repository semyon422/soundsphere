local class = require("class")
local table_util = require("table_util")

local exts = table_util.invert({"png", "bmp", "tga", "jpg", "jpeg"})

local chars = {
	comma = ",",
	dot = ".",
	percent = "%",
}

---@alias sphere.OsuSpriteFrame integer|"comma"|"dot"|"percent"

---@class sphere.OsuSpriteFile
---@operator call: sphere.OsuSpriteFile
---@field path string
---@field name string
---@field frame sphere.OsuSpriteFrame?
---@field dpi integer?
---@field ext string?
local OsuSpriteFile = class()

---@param s string
---@return true?
local function is_integer(s)
	local n = tonumber(s)
	return n and n % 1 == 0
end

---@param path string
function OsuSpriteFile:new(path)
	local name_frame_dpi, ext = path:match("^(.+)%.(.-)$")
	name_frame_dpi = name_frame_dpi or path
	---@cast name_frame_dpi string
	---@cast ext string?

	local name_frame, dpi = name_frame_dpi:match("^(.+)@(%d+)x$")
	name_frame = name_frame or name_frame_dpi
	---@cast name_frame string
	---@cast dpi string?

	local name, frame = name_frame:match("^(.+)-(.-)$")
	if not is_integer(frame) and not chars[frame] then
		name, frame = name_frame, nil
	end
	name = name or name_frame
	---@cast name string
	---@cast frame string?

	self.path = path

	self.name = name
	self.frame = tonumber(frame) or frame
	self.dpi = tonumber(dpi)
	self.ext = ext
end

---@return string
function OsuSpriteFile:getKey()
	return self.name:lower()
end

---@return string
function OsuSpriteFile:getExt()
	return assert(self.ext):lower()
end

---@return integer
function OsuSpriteFile:getDpi()
	return self.dpi or 1
end

---@return string?
function OsuSpriteFile:getChar()
	local frame = self.frame
	if not frame then
		return
	end
	if type(frame) == "number" then
		return tostring(frame)
	end
	return chars[frame]
end

---@return boolean
function OsuSpriteFile:isSprite()
	if not self.ext then
		return false
	end
	return not not exts[self:getExt()]
end

---@param sprite_file sphere.OsuSpriteFile
---@return boolean
function OsuSpriteFile:ltExt(sprite_file)
	return exts[self:getExt()] < exts[sprite_file:getExt()]
end

---@return string
function OsuSpriteFile:getPattern()
	local out = {self.name}
	if self.frame then
		table.insert(out, "-%s")
	end
	if self.dpi then
		table.insert(out, "@%sx")
	end
	if self.ext then
		table.insert(out, ".%s")
	end
	return table.concat(out)
end

---@return string
function OsuSpriteFile:getFramePattern()
	local pattern = self:getPattern()
	return pattern:format(table_util.remove_holes("%s", self.dpi, self.ext))
end

---@return string
function OsuSpriteFile:__tostring()
	local pattern = self:getPattern()
	return pattern:format(table_util.remove_holes(self.frame, self.dpi, self.ext))
end

return OsuSpriteFile
