local class = require("class")

---@class yi.Resources
---@overload fun(): yi.Resources
---@field fonts {[string]: love.Font}
local Resources = class()

Resources.font_paths = {
	regular = "resources/fonts/MiSans-Regular.ttf",
	bold = "resources/fonts/MiSans-Bold.ttf",
	black = "resources/fonts/MiSans-Heavy.ttf",
	icons = "resources/fonts/lucide.ttf"
}

---@alias yi.FontName "regular" | "bold" | "black" | "icons"
---@alias yi.FontSize 16 | 24 | 36 | 46 | 58 | 72

function Resources:new()
	self:setDpi(1)
end

---@param dpi number
function Resources:setDpi(dpi)
	self.dpi = dpi
	self.fonts = {}
end

---@param name yi.FontName
---@param size yi.FontSize
---@return love.Font
function Resources:getFont(name, size)
	---@cast name string
	---@cast size integer
	local key = name .. tostring(size)

	if not self.fonts[key] then
		local path = self.font_paths[name]
		local object = love.graphics.newFont(path, size, "normal", self.dpi)
		self.fonts[key] = object
	end

	return self.fonts[key]
end

return Resources
