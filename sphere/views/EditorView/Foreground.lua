local just = require("just")
local gfx_util = require("gfx_util")
local spherefonts = require("sphere.assets.fonts")

local Layout = require("sphere.views.EditorView.Layout")

local function Hotkeys(self)
	local editorModel = self.game.editorModel
	local notificationModel = self.game.notificationModel

	local lctrl = love.keyboard.isDown("lctrl")

	local kp = just.keypressed
	if lctrl then
		if kp("s") then
			self.game.editorController:save()
			notificationModel:notify("saved")
		elseif kp("c") then
			editorModel:copyNotes()
			notificationModel:notify("copy " .. #editorModel.copiedNotes .. " notes")
		elseif kp("x") then
			editorModel:copyNotes(true)
			notificationModel:notify("cut " .. #editorModel.copiedNotes .. " notes")
		elseif kp("v") then
			editorModel:pasteNotes()
			notificationModel:notify("paste " .. #editorModel.copiedNotes .. " notes")
		end
	end

	if kp("delete") then
		local deleted = editorModel:deleteNotes()
		notificationModel:notify("delete " .. deleted .. " notes")
	end
end

local function Notification(self)
	local w, h = Layout:move("header")

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setFont(spherefonts.get("Noto Sans", 24))
	gfx_util.printFrame(self.game.notificationModel.message, 0, 0, w, h, "center", "center")
end

return function(self)
	Notification(self)
	Hotkeys(self)
end
