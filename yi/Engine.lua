local class = require("class")
local View = require("yi.views.View")
local ViewState = View.State
local LayoutEngine = require("ui.layout.LayoutEngine")
local LayoutEnums = require("ui.layout.Enums")
local CommandBuffer = require("yi.renderer.CommandBuffer")
local Renderer = require("yi.renderer")
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

	self.rebuild_command_buffer = true
	self.layout_update_requesters = {}
	self.transform_update_requesters = {}
	self.removal_deferred = {}
	self.detach_deferred = {}
end

function Engine:load()
	self.root:mount(self.ctx)
	self:updateRootDimensions()
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
		self.rebuild_command_buffer = true
		self:updateView(view, dt)
	elseif state == ViewState.Killed then
		table.insert(self.removal_deferred, view)
	elseif state == ViewState.Detached then
		table.insert(self.detach_deferred, view)
	elseif state == ViewState.Destoryed then
		error("DO NOT CALL View:destroy() manually!!!")
	end
end

---@private
---@param view yi.View
---@param kill boolean
function Engine:remove(view, kill)
	local parent = view.parent
	if parent then
		local idx = table_util.indexof(parent.children, view)
		if idx then
			table.remove(parent.children, idx)
			self.rebuild_command_buffer = true
			parent.layout_box:markDirty(LayoutEnums.Axis.Both)
			table.insert(self.layout_update_requesters, parent)
		end
	end

	if kill then
		view:destroy()
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

	for i = 1, #self.removal_deferred do
		self:remove(self.removal_deferred[i], true)
	end

	for i = 1, #self.detach_deferred do
		self:remove(self.detach_deferred[i], false)
	end

	local updated_roots = self.layout_engine:updateLayout(self.layout_update_requesters)

	if updated_roots then
		for node, _ in pairs(updated_roots) do
			---@cast node yi.View
			node:updateTransforms()
		end
	end

	for i = 1, #self.transform_update_requesters do
		local view = self.transform_update_requesters[i]
		view:updateTransforms()
	end

	if self.rebuild_command_buffer then
		self.rebuild_command_buffer = false
		self.command_buffer = CommandBuffer(self.root)
	end
end

function Engine:draw()
	Renderer(self.command_buffer)
end

function Engine:updateRootDimensions()
	self.root:setWidth(love.graphics.getWidth())
	self.root:setHeight(love.graphics.getHeight())
end

---@type ui.ModifierKeys
local modifiers = {
	control = false,
	shift = false,
	super = false,
	alt = false
}

function Engine:receive(event)
	if event.name == "resize" then
		self:updateRootDimensions()
	elseif event.name ~= "framestarted" then
		modifiers.control = love.keyboard.isDown("lctrl", "rctrl")
		modifiers.shift = love.keyboard.isDown("lshift", "rshift")
		modifiers.alt = love.keyboard.isDown("lalt", "ralt")
		self.inputs:receive(event, modifiers)
	end
end

return Engine
