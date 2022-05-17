local ffi = require("ffi")
local imgui = require("cimgui")
local ImguiView = require("sphere.views.ImguiView")
local align = require("aqua.imgui.config").align

local SelectOverlayView = ImguiView:new()

local textPtr = ffi.new("char[128]")
SelectOverlayView.draw = function(self)
    local viewport = imgui.GetMainViewport()
    imgui.SetNextWindowPos(viewport.Pos)
    imgui.SetNextWindowSize(viewport.Size)
	local flags = imgui.love.WindowFlags("NoMove", "NoDecoration", "NoBackground", "NoBringToFrontOnFocus")
	if not imgui.Begin("Select overlay", nil, flags) then
		return imgui.End()
	end

	local margin = 6
	imgui.SetCursorPos({align(0.5, 733 + margin), 89 + margin})
	imgui.PushItemWidth(281 - 2 * margin)
	imgui.InputTextWithHint("##Search line", "Search", textPtr, ffi.sizeof(textPtr))

	if imgui.IsWindowFocused() then
		imgui.CaptureMouseFromApp(false)
		imgui.CaptureKeyboardFromApp(false)
	end

	imgui.End()
end

return SelectOverlayView
