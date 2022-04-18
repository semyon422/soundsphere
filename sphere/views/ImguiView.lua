local imgui = require("cimgui")
local ffi = require("ffi")
local Class = require("aqua.util.Class")

local ImguiView = Class:new()

ImguiView.construct = function(self)
	self.isOpen = ffi.new("bool[1]", true)
end

ImguiView.draw = function(self)
	if self.isOpen[0] then
		imgui.Begin("Window", self.isOpen, 0)
		imgui.End()
	end
end

return ImguiView
