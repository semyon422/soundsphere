local fonts = {}

local instances = {}

local fontFamilyList = {
	["Noto Sans"] = {
		"resources/fonts/NotoSansCJK-Regular.ttc",
		"resources/fonts/NotoSans-Minimal.ttf",
	},
	["Noto Sans Mono"] = {
		"resources/fonts/NotoSansMono-Regular.ttf",
		"resources/fonts/NotoSansMono-Minimal.ttf",
	}
}

local getFirstFile = function(list)
	if not list then
		return
	end
	for _, path in ipairs(list) do
		if love.filesystem.getInfo(path) then
			return path
		end
	end
end

fonts.get = function(t)
	local filename = t.filename
	local size = t.size
	if instances[filename] and instances[filename][size] then
		return instances[filename][size]
	end
	local font = love.graphics.newFont(getFirstFile(fontFamilyList[filename]) or filename, size)
	instances[filename] = instances[filename] or {}
	instances[filename][size] = font
	return font
end

return fonts
