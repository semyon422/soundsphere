local Class = require("Class")

local ScreenshotModel = Class:new()

local prefix = "userdata/screenshots/screenshot "
local path_fmt = prefix .. "%s.png"
local pathn_fmt = prefix .. "%s (%s).png"
local function get_path()
	local date = os.date("%d.%m.%Y %H-%M-%S")

	local path = path_fmt:format(date)
	local info = love.filesystem.getInfo(path, "file")
	if not info then
		return path
	end

	for i = 2, 10 do
		path = pathn_fmt:format(date, i)
		info = love.filesystem.getInfo(path, "file")
		if not info then
			return path
		end
	end

	return pathn_fmt:format(date, "?")
end

ScreenshotModel.capture = function(self, open)
	love.graphics.captureScreenshot(function(imageData)
		local path = get_path()
		local fileData = imageData:encode("png")
		assert(love.filesystem.write(path, fileData:getString()))
		if open then
			love.system.openURL("file://" .. love.filesystem.getSource() .. "/" .. path)
		end
	end)
end

ScreenshotModel.receive = function(self, event)
	if event.name ~= "keypressed" then
		return
	end

	local screenshot = self.game.configModel.configs.settings.input.screenshot
	if event[1] == screenshot.capture then
		local open = love.keyboard.isDown(screenshot.open)
		self:capture(open)
	end
end

return ScreenshotModel
