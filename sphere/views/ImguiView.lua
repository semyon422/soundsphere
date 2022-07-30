local imgui = require("cimgui")
local ffi = require("ffi")
local Class = require("aqua.util.Class")
local aquaevent = require("aqua.event")

local keystate = aquaevent.keystate

local ImguiView = Class:new()

ImguiView.construct = function(self)
	self.isOpen = ffi.new("bool[1]", false)
end

ImguiView.draw = function(self)
	if self.isOpen[0] then
		imgui.Begin("Window", self.isOpen, 0)
		imgui.End()
	end
end

ImguiView.toggle = function(self, state)
	if state == nil then
		self.isOpen[0] = not self.isOpen[0]
	else
		self.isOpen[0] = state
	end
end

ImguiView.closeOnEscape = function(self)
	if keystate.escape then
		self.isOpen[0] = false
		return true
	end
end

return ImguiView
