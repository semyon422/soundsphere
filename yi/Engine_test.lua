local Engine = require("yi.Engine")
local View = require("yi.views.View")
local Context = require("yi.Context")
local Inputs = require("ui.input.Inputs")

local test = {}

---@class yi.MockView : yi.View
---@overload fun(): yi.MockView
local MockView = View + {}
function MockView:new()
	View.new(self)
	self.update_calls = 0
	self.load_calls = 0
	self.load_complete_calls = 0
end

function MockView:load()
	self.load_calls = self.load_calls + 1
end

function MockView:loadComplete()
	self.load_complete_calls = self.load_complete_calls + 1
end

function MockView:update(_)
	self.update_calls = self.update_calls + 1
end

---@param t testing.T
function test.mounting_lifecycle(t)
	local inputs = Inputs()
	local ctx = Context({}, inputs)
	local engine = Engine(inputs, ctx)

	local v1 = MockView()
	engine.root:add(v1)

	t:eq(v1.state, View.State.AwaitsMount) -- The root is still not mounted here
	t:eq(v1.load_calls, 0)

	engine:load() -- Mounts the root
	t:eq(v1.state, View.State.Loaded)
	t:eq(v1.load_calls, 1)
	t:eq(v1.load_complete_calls, 0)

	engine:update(0.016, 0, 0)
	t:eq(v1.state, View.State.Active)
	t:eq(v1.load_complete_calls, 1)
	t:eq(v1.update_calls, 1)

	engine:update(0.016, 0, 0)
	t:eq(v1.state, View.State.Active)
	t:eq(v1.load_complete_calls, 1)
	t:eq(v1.update_calls, 2)
end

---@param t testing.T
function test.states_and_updates(t)
	local inputs = Inputs()
	local ctx = Context({}, inputs)
	local engine = Engine(inputs, ctx)
	engine:load()

	local v_active = engine.root:add(MockView())
	local v_killed = engine.root:add(MockView())
	local v_detached = engine.root:add(MockView())

	t:eq(v_active.state, View.State.Loaded)
	t:eq(v_killed.state, View.State.Loaded)
	t:eq(v_detached.state, View.State.Loaded)

	-- First update to transition them to Active
	engine:update(0.016, 0, 0)
	t:eq(v_active.state, View.State.Active)
	t:eq(v_killed.state, View.State.Active)
	t:eq(v_detached.state, View.State.Active)

	v_killed:kill()
	v_detached:detach()

	engine:update(0.016, 0, 0)

	-- Active should be updated again
	t:eq(v_active.update_calls, 2)
	-- Killed and Detached should NOT be updated this frame
	t:eq(v_killed.update_calls, 1)
	t:eq(v_detached.update_calls, 1)

	-- Check deferred lists
	t:eq(#engine.removal_deferred, 1)
	t:eq(engine.removal_deferred[1], v_killed)
	t:eq(#engine.detach_deferred, 1)
	t:eq(engine.detach_deferred[1], v_detached)

	-- Only one will remain
	t:eq(#engine.root.children, 1)
	t:eq(engine.root.children[1], v_active)

	-- Verify destroyed
	t:eq(v_killed.children, nil)
end

---@param t testing.T
function test.layout_and_transforms(t)
	local inputs = Inputs()
	local ctx = Context({}, inputs)
	local engine = Engine(inputs, ctx)
	engine:load()

	-- Set root size
	engine.root.layout_box:setWidth(1000)
	engine.root.layout_box:setHeight(1000)

	local v1 = engine.root:add(MockView())
	v1.layout_box:setWidth(100)
	v1.layout_box:setHeight(100)
	v1.transform:setX(10)
	v1.transform:setY(20)

	local v2 = v1:add(MockView())
	v2.layout_box:setWidth(50)
	v2.layout_box:setHeight(50)
	v2.transform:setX(5)
	v2.transform:setY(5)

	-- First update to resolve initial layout and transforms
	engine:update(0.016, 0, 0)

	local x, y = v1.transform.love_transform:transformPoint(0, 0)
	t:eq(x, 10)
	t:eq(y, 20)

	local x2, y2 = v2.transform.love_transform:transformPoint(0, 0)
	t:eq(x2, 15) -- 10 + 5
	t:eq(y2, 25) -- 20 + 5

	-- Change V1 position via transform
	v1.transform:setX(50)
	v1.transform:setY(60)
	engine:update(0.016, 0, 0)

	x, y = v1.transform.love_transform:transformPoint(0, 0)
	t:eq(x, 50)
	t:eq(y, 60)

	x2, y2 = v2.transform.love_transform:transformPoint(0, 0)
	t:eq(x2, 55) -- 50 + 5
	t:eq(y2, 65) -- 60 + 5
end

return test
