local View = require("yi.views.View")
local TabButton = require("yi.views.components.TabButton")
local Colors = require("yi.Colors")

---@class yi.Tabs
---@field content yi.View
---@field icon yi.Label?
---@field text yi.Label

---@class yi.TabContainer : yi.View
---@overload fun(tabs: yi.Tabs[]): yi.TabContainer
---@field tab_buttons yi.TabButton[]
local TabContainer = View + {}

---@param tabs yi.Tabs[]
function TabContainer:new(tabs)
	View.new(self)
	self.tabs = assert(tabs)
	self.active_index = 1
	self.tab_buttons = {}
end

function TabContainer:load()
	self:setup({
		arrange = "flex_row",
		background_color = Colors.panels
	})

	self.button_container = View()
	self.button_container:setup({
		arrange = "flex_col",
		width = 200,
		height = "100%",
		gap = 4,
		padding = {10, 10, 10, 10}
	})
	self:add(self.button_container)

	self.content_container = View()
	self.content_container:setup({
		grow = 1,
		padding = {10, 10, 10, 0}
	})

	self:add(self.content_container)

	for i, tab in ipairs(self.tabs) do
		local button = TabButton(tab, function()
			self:selectTab(i)
		end)
		self.button_container:add(button)
		self.content_container:add(tab.content)
		tab.content:setEnabled(false)
		self.tab_buttons[i] = button
	end

	if self.tab_buttons[1] then
		self.tab_buttons[1]:setActive(true)
		self.tabs[1].content:setEnabled(true)
	end
end

---@param index number
function TabContainer:selectTab(index)
	if index == self.active_index then return end
	if index < 1 or index > #self.tabs then return end

	self.tab_buttons[self.active_index]:setActive(false)
	self.tab_buttons[index]:setActive(true)

	local current = self.tabs[self.active_index]
	if current and current.content then
		current.content:setEnabled(false)
	end

	self.active_index = index
	local new_tab = self.tabs[index]
	if new_tab and new_tab.content then
		new_tab.content:setEnabled(true)
	end
end

return TabContainer
