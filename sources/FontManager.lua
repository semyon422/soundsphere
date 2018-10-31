FontManager = createClass()

FontManager.path = "resources/fonts"

FontManager.construct = function(self)
	local file = io.open("resources/fonts.json", "r")
	self.jsonData = json.decode(file:read("*all"))
	file:close()
	
	self.fonts = {}
end

FontManager.getFont = function(self, type, size)
	local font = self.fonts[type .. size] or love.graphics.getFont()
	
	if not self.fonts[type .. size] then
		if self.jsonData[type] then
			font = love.graphics.newFont(self.path .. "/" .. self.jsonData[type], size)
			self.fonts[type .. size] = font
		end
	end
	
	return font
end