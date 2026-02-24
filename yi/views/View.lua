local Node = require("ui.Node")
local LayoutEnums = require("ui.layout.Enums")
local Transform = require("yi.Transform")
local Arrange = LayoutEnums.Arrange
local JustifyContent = LayoutEnums.JustifyContent
local AlignItems = LayoutEnums.AlignItems

---@alias yi.Color [number, number, number, number]
---@alias yi.BlendMode [string, string]
---@alias yi.Outline {thickness: number, color: yi.Color}

---@class yi.View : ui.Node
---@operator call: yi.View
---@field id string?
---@field parent yi.View
---@field children yi.View[]
---@field draw? fun(self: yi.View)
---@field color yi.Color?
---@field blend_mode yi.BlendMode?
---@field background_color yi.Color?
---@field corner_radius number?
---@field outline yi.Outline?
---@field stencil boolean?
---@field ctx yi.Context
---@field transform yi.Transform
local View = Node + {}

View.State = {
	AwaitsMount = 1,
	Loaded = 2,
	Active = 3,
	Detached = 4,
	Killed = 5,
	Destoryed = 6
}

local State = View.State

function View:new()
	Node.new(self)
	self.state = State.AwaitsMount
	self.transform = Transform()
end

---@param ctx yi.Context
function View:mount(ctx)
	self.ctx = ctx
	self:load()
	self.state = State.Loaded

	local c = self.children
	for i = 1, #c do
		local v = c[i]
		if v.state == State.AwaitsMount then
			v:mount(ctx)
		end
	end
end

---@generic T: yi.View
---@param view T
---@param params {[string]: any}?
---@return T
function View:add(view, params)
	---@cast view yi.View
	Node.add(self, view)

	if params then
		view:setup(params)
	end

	if self.ctx and view.state == State.AwaitsMount then
		view:mount(self.ctx)
	end

	return view
end

---@param views yi.View[]
function View:addArray(views)
	for i = 1, #views do
		self:add(views[i])
	end
end

--- Takes a table with parameters and applies them using setters
---@param params {[string]: any}
function View:setup(params)
	assert(params, "No params passed to setup(), don't forget to pass them when you override the function")
	for k, v in pairs(params) do
		local f = self.Setters[k]
		if f then
			if f == true then
				self[k] = v ---@diagnostic disable-line
			else
				f(self, v)
			end
		end
	end
end

function View:load() end

function View:loadComplete() end

function View:destroy()
	Node.destroy(self)
	self.state = State.Destoryed
end

---@param dt number
function View:update(dt) end

---@param mouse_x number
---@param mouse_y number
function View:isMouseOver(mouse_x, mouse_y)
	local imx, imy = self.transform.love_transform:inverseTransformPoint(mouse_x, mouse_y)
	return imx >= 0 and imx < self.layout_box.x.size and imy >= 0 and imy < self.layout_box.y.size
end

function View:updateTransforms()
	local parent_tf = self.parent and self.parent.transform.love_transform
	local parent_lb = self.parent and self.parent.layout_box

	self.transform:update(self.layout_box, parent_tf, parent_lb)

	local c = self.children
	for i = 1, #c do
		c[i]:updateTransforms()
	end
end

function View:kill()
	self.state = State.Killed
end

function View:detach()
	if self.state == State.Active then
		self.state = State.Detached
	else
		error("Can't detach not active view")
	end
end

---@param view yi.View
function View:attach(view)
	table.insert(self.children, view)
end

---@return yi.Context
function View:getContext()
	if not self.ctx then
		error("Context is not available")
	end
	return self.ctx
end

---@return sphere.GameController
function View:getGame()
	return self:getContext().game
end

---@return ui.Inputs
function View:getInputs()
	return self:getContext().inputs
end

---@return yi.Resources
function View:getResources()
	return self:getContext().resources
end

---@return number
function View:getWidth()
	return self.layout_box.x.preferred_size
end

---@return number
function View:getHeight()
	return self.layout_box.y.preferred_size
end

---@return number
function View:getCalculatedWidth()
	return self.layout_box.x.size
end

---@return number
function View:getCalculatedHeight()
	return self.layout_box.y.size
end

---@param v "auto" | "fit" | string | number
function View:setWidth(v)
	if v == "auto" then
		self.layout_box:setWidthAuto()
	elseif v == "fit" then
		self.layout_box:setWidthFit()
	elseif type(v) == "string" then
		if v:sub(-1) == "%" then
			local num_part = v:sub(1, -2)
			local num = tonumber(num_part)
			if num then
				self.layout_box:setWidthPercent(num * 0.01)
			end
		end
	elseif type(v) == "number" then
		self.layout_box:setWidth(v)
	end
end

---@param v "auto" | "fit" | string | number
function View:setHeight(v)
	if v == "auto" then
		self.layout_box:setHeightAuto()
	elseif v == "fit" then
		self.layout_box:setHeightFit()
	elseif type(v) == "string" then
		if v:sub(-1) == "%" then
			local num_part = v:sub(1, -2)
			local num = tonumber(num_part)
			if num then
				self.layout_box:setHeightPercent(num * 0.01)
			end
		end
	elseif type(v) == "number" then
		self.layout_box:setHeight(v)
	end
end

---@param v number
function View:setMinWidth(v)
	self.layout_box:setMinWidth(v)
end

---@param v number
function View:setMaxWidth(v)
	self.layout_box:setMaxWidth(v)
end

---@param v number
function View:setMinHeight(v)
	self.layout_box:setMinHeight(v)
end

---@param v number
function View:setMaxHeight(v)
	self.layout_box:setMaxHeight(v)
end

---@param v "absolute" | "flex_row" | "flex_col" | "grid"
function View:setArrange(v)
	local arrange = Arrange.Absolute

	if v == "absolute" then
		arrange = Arrange.Absolute
	elseif v == "flex_row" then
		arrange = Arrange.FlexRow
	elseif v == "flex_col" then
		arrange = Arrange.FlexCol
	elseif v == "grid" then
		arrange = Arrange.Grid
	end

	self.layout_box:setArrange(arrange)
end

---@param v boolean
function View:setReversed(v)
	self.layout_box:setReversed(v)
end

---@param v number
function View:setChildGap(v)
	self.layout_box:setChildGap(v)
end

---@param str string
---@return ui.AlignItems
local function str_to_align(str)
	if str == "center" then
		return AlignItems.Center
	elseif str == "end" then
		return AlignItems.End
	elseif str == "stretch" then
		return AlignItems.Stretch
	end
	return AlignItems.Start
end

---@param v "start" | "center" | "end" | "stretch"
function View:setAlignItems(v)
	self.layout_box:setAlignItems(str_to_align(v))
end

---@param v ("start" | "center" | "end" | "stretch")?
function View:setAlignSelf(v)
	if not v then
		self.layout_box:setAlignSelf(nil)
		return
	end
	self.layout_box:setAlignSelf(str_to_align(v))
end

---@param v "start" | "center" | "end" | "space_between"
function View:setJustifyContent(v)
	local j = JustifyContent.Start
	if v == "center" then
		j = JustifyContent.Center
	elseif v == "end" then
		j = JustifyContent.End
	elseif v == "space_between" then
		j = JustifyContent.SpaceBetween
	end
	self.layout_box:setJustifyContent(j)
end

---@param v [number, number, number, number]
function View:setPaddings(v)
	self.layout_box:setPaddings(v)
end

---@param v [number, number, number, number]
function View:setMargins(v)
	self.layout_box:setMargins(v)
end

---@param v number
function View:setGrow(v)
	self.layout_box:setGrow(v)
end

---@param x number
function View:setX(x)
	self.transform:setX(x)
end

---@param y number
function View:setY(y)
	self.transform:setY(y)
end

---@param sx number
function View:setScaleX(sx)
	self.transform:setScaleX(sx)
end

---@param sy number
function View:setScaleY(sy)
	self.transform:setScaleY(sy)
end

---@param a number
function View:setAngle(a)
	self.transform:setAngle(a)
end

---@enum (key) ui.PivotString
local pivots = {
	top_left = {x = 0, y = 0},
	top_center = {x = 0.5, y = 0},
	top_right = {x = 1, y = 0},
	center_left = {x = 0, y = 0.5},
	center = {x = 0.5, y = 0.5},
	center_right = {x = 1, y = 0.5},
	bottom_left = {x = 0, y = 1},
	bottom_center = {x = 0.5, y = 1},
	bottom_right = {x = 1, y = 1},
}

---@param v ui.PivotString
function View:setOrigin(v)
	local o = pivots[v]
	self.transform:setOrigin(o.x, o.y)
end

---@param v ui.PivotString
function View:setAnchor(v)
	local a = pivots[v]
	self.transform:setAnchor(a.x, a.y)
end

---@param v ui.PivotString
function View:setPivot(v)
	local p = pivots[v]
	self.transform:setAnchor(p.x, p.y)
	self.transform:setOrigin(p.x, p.y)
end

---@param v yi.Color
function View:setColor(v)
	local c = self.color or {}
	c[1] = v[1]
	c[2] = v[2]
	c[3] = v[3]
	c[4] = v[4]
	self.color = c
end

---@param v yi.Color
function View:setBackgroundColor(v)
	local c = self.background_color or {}
	c[1] = v[1]
	c[2] = v[2]
	c[3] = v[3]
	c[4] = v[4]
	self.background_color = c
end

View.Setters = {
	width = View.setWidth,
	height = View.setHeight,
	min_width = View.setMinWidth,
	max_width = View.setMaxWidth,
	min_height = View.setMinHeight,
	max_height = View.setMaxHeight,

	-- Tailwind CSS
	w = View.setWidth,
	h = View.setHeight,
	min_w = View.setMinWidth,
	max_w = View.setMaxWidth,
	min_h = View.setMinHeight,
	max_h = View.setMaxHeight,

	-- Transform
	x = View.setX,
	y = View.setY,
	angle = View.setAngle,
	scale_x = View.setScaleX,
	scale_y = View.setScaleY,
	anchor = View.setAnchor,
	origin = View.setOrigin,
	pivot = View.setPivot,

	-- General layout settings
	arrange = View.setArrange,
	display = View.setArrange,
	padding = View.setPaddings,
	margin = View.setMargins,

	-- Flex
	reversed = View.setReversed,
	gap = View.setChildGap,
	align_items = View.setAlignItems,
	align_self = View.setAlignSelf,
	justify_content = View.setJustifyContent,
	grow = View.setGrow,

	-- View
	handles_mouse_input = true,
	handles_keyboard_input = true,
	color = View.setColor,
	background_color = View.setBackgroundColor,
	corner_radius = true,
	stencil = true,
	id = true,
	mouse = function(self, v) self.handles_mouse_input = v end,
	keyboard = function(self, v) self.handles_keyboard_input = v end
}

return View
