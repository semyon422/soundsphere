local class = require("class")
local View = require("yi.views.View")
local ViewState = View.State
local LayoutEngine = require("ui.layout.LayoutEngine")
local table_util = require("table_util")

---@class yi.Engine
---@overload fun(inputs: ui.Inputs, ctx: yi.Context): yi.Engine
---@field ctx yi.Context
---@field root yi.View
---@field layout_engine ui.LayoutEngine
---@field layout_update_requesters yi.View[]
---@field transform_update_requesters yi.View[]
---@field removal_deferred yi.View[]
---@field detach_deferred yi.View[]
local Engine = class()

---@param inputs ui.Inputs
---@param ctx yi.Context
function Engine:new(inputs, ctx)
	self.inputs = inputs
	self.ctx = ctx
	self.layout_engine = LayoutEngine()
	self.root = View()
	self.root.id = "root"

	self.layout_update_requesters = {}
	self.transform_update_requesters = {}
	self.removal_deferred = {}
	self.detach_deferred = {}
end

function Engine:load()
	self.root:mount(self.ctx)
end

---@private
---@param view yi.View
---@param dt number
function Engine:updateView(view, dt)
	local state = view.state

	if state == ViewState.Active then
		self.inputs:processNode(view)
		view:update(dt)

		if not view.layout_box:isValid() then
			table.insert(self.layout_update_requesters, view)
		end

		if view.transform.dirty then
			table.insert(self.transform_update_requesters, view)
		end

		local children = view.children
		for i = 1, #children do
			self:updateView(children[i], dt)
		end
	elseif state == ViewState.Loaded then
		view.state = ViewState.Active
		view:loadComplete()
		self:updateView(view, dt)
	elseif state == ViewState.Killed then
		table.insert(self.removal_deferred, view)
	elseif state == ViewState.Detached then
		table.insert(self.detach_deferred, view)
	end
end

---@param dt number
---@param mouse_x number
---@param mouse_y number
function Engine:update(dt, mouse_x, mouse_y)
	self.inputs:beginFrame(mouse_x, mouse_y)

	table_util.clear(self.layout_update_requesters)
	table_util.clear(self.transform_update_requesters)
	table_util.clear(self.removal_deferred)
	table_util.clear(self.detach_deferred)

	self:updateView(self.root, dt)

	-- Phase 3: Layout resolution
	-- Phase 4: Transform updates
	-- Phase 5: Cleanup
end

function Engine:draw() end

function Engine:receive(event)
	if event.name == "resize" then
		self.root:setWidth(event.width)
		self.root:setHeight(event.height)
	end
end

return Engine
