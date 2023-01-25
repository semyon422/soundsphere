local ScreenView = require("sphere.views.ScreenView")
local thread = require("thread")
local just = require("just")

local Layout = require("sphere.views.EditorView.Layout")
local EditorViewConfig = require("sphere.views.EditorView.EditorViewConfig")
local SnapGridView = require("sphere.views.EditorView.SnapGridView")

local EditorView = ScreenView:new()

local loading
EditorView.load = thread.coro(function(self)
	if loading then
		return
	end
	loading = true

	self.game.editorController:load()

	self.snapGridView = SnapGridView:new()
	self.snapGridView.game = self.game

	loading = false
end)

EditorView.update = function(self, dt)
	self.game.editorModel:update()
end

EditorView.receive = function(self, event)
	self.game.editorController:receive(event)
end

EditorView.draw = function(self)
	just.container("screen container", true)

	local kp = just.keypressed
	if kp("escape") then self:quit()
	end

	Layout:draw()
	EditorViewConfig(self)
	self.snapGridView:draw()
	just.container()
end

EditorView.quit = function(self)
	self:changeScreen("selectView")
end

EditorView.unload = function(self)
	self.game.editorController:unload()
end

return EditorView
