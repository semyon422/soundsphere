local fonts = {}

fonts.dpi = 1

local instances = {}

local fontFamilyList = {
	["Noto Sans"] = {
		"resources/fonts/NotoSansCJK-Regular.ttc",
		"resources/fonts/NotoSans-Minimal.ttf",
		height = 813 / 758,
	},
	["Noto Sans Mono"] = {
		"resources/fonts/NotoSansMono-Regular.ttf",
		"resources/fonts/NotoSansMono-Minimal.ttf",
		height = 730 / 699,
	}
}

---@param list table?
---@return string?
local function getFirstFile(list)
	if not list then
		return
	end
	for _, path in ipairs(list) do
		if love.filesystem.getInfo(path) then
			return path
		end
	end
end

function fonts.reset()
	instances = {}
end

---@param filename string
---@param size number
---@return love.Font
function fonts.get(filename, size)
	if instances[filename] and instances[filename][size] then
		return instances[filename][size]
	end
	local f = fontFamilyList[filename]
	local font = love.graphics.newFont(getFirstFile(f) or filename, size, "normal", fonts.dpi)
	instances[filename] = instances[filename] or {}
	instances[filename][size] = font
	if f and f.height then
		font:setLineHeight(f.height)
	end
	return font
end

return fonts
