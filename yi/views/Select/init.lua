local View = require("yi.views.View")
local Screen = require("yi.views.Screen")
local h = require("yi.h")

---@class yi.Select : yi.Screen
---@overload fun(): yi.Select
local Select = Screen + {}

function Select:new()
	Screen.new(self)
	self.id = "select"
	self.handles_keyboard_input = true

	self:setWidth("100%")
	self:setHeight("100%")

	self:addArray({
		h(View(), {w = "70%", h = "100%", background_color = {1, 0, 1, 1}}),
		h(View(), {w = "30%", h = "100%", pivot = "top_right", background_color = {0, 1, 1, 1}})
	})
end

function Select:load()
	Screen.load(self)
	local game = self:getGame()
	self.select_controller = game.selectController
	self.select_model = game.selectModel
end

function Select:enter()
	self.select_controller:load()
	love.mouse.setVisible(true)
end

function Select:exit()
	self.select_controller:unload()
	self:kill()
end

function Select:update(_)
	self.select_controller:update()
end

function Select:onKeyDown(e)
	local k = e.key

	if k == "j" then
		self.select_model:scrollNoteChartSet(1)
	elseif k == "k" then
		self.select_model:scrollNoteChartSet(-1)
	elseif k == "return" then
		self.parent:set("gameplay")
	end
end

function Select:receive(event)
	self.select_controller:receive(event)
end

return Select
