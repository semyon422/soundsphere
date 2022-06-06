local ffi = require("ffi")
local imgui = require("cimgui")
local ImguiView = require("sphere.views.ImguiView")
local align = require("aqua.imgui.config").align

local SelectOverlayView = ImguiView:new()

local textPtr = ffi.new("char[128]")
local groupPtr = ffi.new("bool[1]")
local sortPtr = ffi.new("int[1]")
SelectOverlayView.draw = function(self)
    local viewport = imgui.GetMainViewport()
    imgui.SetNextWindowPos(viewport.Pos)
    imgui.SetNextWindowSize(viewport.Size)
	local flags = imgui.love.WindowFlags("NoMove", "NoDecoration", "NoBackground", "NoBringToFrontOnFocus")
	if not imgui.Begin("Select overlay", nil, flags) then
		return imgui.End()
	end

	local margin = 6
	-- imgui.SetCursorPos({align(0.5, 733 + margin), 89 + margin})
	-- imgui.PushItemWidth(281 - 2 * margin)
	-- imgui.InputTextWithHint("##Search line", "Search", textPtr, ffi.sizeof(textPtr))

	-- imgui.SetCursorPos({align(0.5, 1014 + margin), 89 + margin})
	-- imgui.PushItemWidth(173 - 2 * margin)
	-- imgui.Combo_Str("##Sort combo", sortPtr, table.concat({"a", "b", "c"}, "\0"))

	imgui.SetCursorPos({align(0.5, 1187 + margin), 89 + margin})
	imgui.PushItemWidth(454 - 2 * margin)

	groupPtr[0] = self.game.noteChartSetLibraryModel.collapse
	if imgui.Checkbox("Group", groupPtr) then
		self.navigator:changeCollapse()
	end

	local capture = false
	if not imgui.IsWindowFocused() then
		capture = true
	end
	imgui.CaptureMouseFromApp(capture)
	imgui.CaptureKeyboardFromApp(capture)

	imgui.End()
end

return SelectOverlayView
