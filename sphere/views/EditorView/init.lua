local ScreenView = require("sphere.views.ScreenView")
local thread = require("thread")
local just = require("just")

local Layout = require("sphere.views.EditorView.Layout")
local EditorViewConfig = require("sphere.views.EditorView.EditorViewConfig")

local EditorView = ScreenView:new()

local loading
EditorView.load = thread.coro(function(self)
	if loading then
		return
	end
	loading = true

	loading = false
end)

EditorView.draw = function(self)
	just.container("screen container", true)

	local kp = just.keypressed
	if kp("escape") then self:quit()
	end

	Layout:draw()
	EditorViewConfig(self)
	just.container()
end

EditorView.quit = function(self)
	self:changeScreen("selectView")
end

return EditorView
