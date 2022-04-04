local Class = require("aqua.util.Class")

local Screenshot = Class:new()

Screenshot.path = "userdata/screenshots"
Screenshot.captureKey = ""
Screenshot.openKey = ""

Screenshot.capture = function(self)
	love.graphics.captureScreenshot(function(imageData)
		self.imageData = imageData
		self:save()
		if self.needOpen then
			self:open()
		end
	end)
end

Screenshot.save = function(self)
	local imageData = self.imageData
	if not imageData then
		return
	end
	local fileData = imageData:encode("png")

	self.filePath = self.path .. "/" .. "screenshot" .. os.time() .. ("%3d"):format(math.random(1, 1000)) .. ".png"
	local file = assert(love.filesystem.newFile(self.filePath, "w"))
	file:write(fileData:getString())
	file:close()
end

Screenshot.open = function(self)
	if not self.filePath then
		return
	end
	love.system.openURL("file://" .. love.filesystem.getSource() .. "/" .. self.filePath)
end

Screenshot.receive = function(self, event)
	if event.name ~= "keypressed" then
		return
	end

	local settings = self.configModel.configs.settings
	if event[1] == settings.input.screenshotCapture then
		self.needOpen = love.keyboard.isDown(settings.input.screenshotOpen)
		self:capture()
	end
end

return Screenshot
