local Screen = require("yi.views.Screen")
local h = require("yi.h")
local Label = require("yi.views.Label")
local Checkbox = require("yi.views.components.Checkbox")
local Slider = require("yi.views.components.Slider")
local NumericStepper = require("yi.views.components.NumericStepper")
local Textbox = require("yi.views.components.Textbox")
local Button = require("yi.views.components.Button")

---@class yi.Test : yi.Screen
---@operator call: yi.Test
local Test = Screen + {}

function Test:load()
	Screen.load(self)

	self:setup({
		id = "test_screen",
		w = "100%",
		h = "100%",
		arrange = "flex_col",
		justify_content = "center",
		align_items = "start",
		padding = {40, 40, 40, 40},
		gap = 20,
		background_color = {0.05, 0.05, 0.07, 1},
		keyboard = true,
	})

	local res = self:getResources()
	local font = res:getFont("bold", 36)
	local label_font = res:getFont("regular", 24)

	self:add(Label(font, "UI Components Test Screen"))

	-- Checkbox Row
	self:add(h(require("yi.views.View")(), {arrange = "flex_row", align_items = "center", gap = 10}, {
		Label(label_font, "Checkbox:"),
		Checkbox(true, function(v) print("Checkbox changed:", v) end)
	}))

	-- Slider Row
	self:add(h(require("yi.views.View")(), {arrange = "flex_col", align_items = "start", gap = 5}, {
		Label(label_font, "Slider (0-100, step 5):"),
		Slider(50, 0, 100, 5, function(v) print("Slider changed:", v) end)
	}))

	-- Numeric Stepper Row
	self:add(h(require("yi.views.View")(), {arrange = "flex_row", align_items = "center", gap = 10}, {
		Label(label_font, "Numeric Stepper:"),
		NumericStepper(10, 0, 100, 1, function(v) print("Stepper changed:", v) end)
	}))

	-- Textbox Row
	self:add(h(require("yi.views.View")(), {arrange = "flex_col", align_items = "start", gap = 5}, {
		Label(label_font, "Textbox:"),
		Textbox("", "Type something here...", function(v) print("Textbox changed:", v) end)
	}))

	-- Button Row
	self:add(h(require("yi.views.View")(), {arrange = "flex_row", align_items = "center", gap = 10}, {
		Label(label_font, "Button:"),
		Button("Click Me!", function() print("Button clicked!") end)
	}))

	-- Wrap Layout Showcase
	self:add(h(require("yi.views.View")(), {arrange = "flex_col", align_items = "start", gap = 5, w = "100%"}, {
		Label(label_font, "Wrap Layout (resize window to see):"),
		h(require("yi.views.View")(), {arrange = "wrap_row", w = "100%", gap = 10, line_gap = 10}, {
			Button("Item 1", function() end),
			Button("Item 2", function() end),
			Button("Item 3", function() end),
			Button("Item 4", function() end),
			Button("Item 5", function() end),
			Button("Item 6", function() end),
			Button("Item 7", function() end),
			Button("Item 8", function() end),
		})
	}))

	self:add(Label(res:getFont("regular", 16), "Press ESC to return to Menu"))
end

function Test:onKeyDown(e)
	if e.key == "escape" then
		self.parent:set("menu")
	end
end

return Test
