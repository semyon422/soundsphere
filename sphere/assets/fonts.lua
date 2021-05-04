local fonts = {}

local instances = {}

local fontFamilyList = {
	["Noto Sans"] = {
		-- path = "resources/fonts/NotoSans-Minimal.ttf",
		path = "resources/fonts/NotoSansCJK-Regular.ttc",
		-- fallbackPath = "resources/fonts/NotoSansCJK-Regular.ttc"
	},
	["Noto Sans Mono"] = {
		-- path = "resources/fonts/NotoSansMono-Minimal.ttf"
		path = "resources/fonts/NotoSansMono-Regular.ttf"
	}
}

fonts.get = function(family, size)
	if not (instances[family] and instances[family][size]) then
		local data = fontFamilyList[family]
		local path = data.path
		local font = love.graphics.newFont(path, size)
		if data.fallbackPath then
			local fallbackFont = love.graphics.newFont(data.fallbackPath, size)
			data.fallbackFont = fallbackFont
			font:setFallbacks(fallbackFont)
		end
		instances[family] = instances[family] or {}
		instances[family][size] = font
		return font
	end
	return instances[family][size]
end

return fonts
