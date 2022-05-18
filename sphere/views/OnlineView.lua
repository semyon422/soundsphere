local ffi = require("ffi")
local imgui = require("cimgui")
local ImguiView = require("sphere.views.ImguiView")
local align = require("aqua.imgui.config").align
local inside = require("aqua.util.inside")

local OnlineView = ImguiView:new()

local emailPtr = ffi.new("char[128]")
local passwordPtr = ffi.new("char[128]")
OnlineView.draw = function(self)
	if not self.isOpen[0] then
		return
	end
	self:closeOnEscape()

	imgui.SetNextWindowPos({align(0.5, 733), 279}, 0)
	imgui.SetNextWindowSize({454, 522}, 0)
	local flags = imgui.love.WindowFlags("NoMove", "NoResize")
	if imgui.Begin("Online", self.isOpen, flags) then
		local active = inside(self, "gameController.configModel.configs.online.session.active")
		if active then
			imgui.Text("You are logged in")
		end
		imgui.InputText("Email", emailPtr, ffi.sizeof(emailPtr))
		imgui.InputText("Password", passwordPtr, ffi.sizeof(passwordPtr), imgui.love.InputTextFlags("Password"))
		if imgui.Button("Login") then
			print(ffi.string(emailPtr), ffi.string(passwordPtr))
			self.navigator:login(ffi.string(emailPtr), ffi.string(passwordPtr))
		end
		if imgui.Button("Quick login using browser") then
			self.navigator:quickLogin()
		end
	end
	imgui.End()
end

return OnlineView
