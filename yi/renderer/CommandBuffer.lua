local C = require("yi.renderer.Commands")

---@alias yi.CommandBuffer (yi.Commands | any)[]

local insert = table.insert
local buf = {} ---@type yi.CommandBuffer

---@param view yi.View
local function traverse(view)
	local has_state =
		view.background_color or
		view.draw

	if view.stencil then
		insert(buf, C.STENCIL_START)
		insert(buf, view)
	end

	if has_state then
		insert(buf, C.PUSH_STATE)
		insert(buf, C.APPLY_TRANSFORM)
		insert(buf, view.transform.love_transform)
	end

	if view.background_color then
		insert(buf, C.PUSH_STATE)

		insert(buf, C.SET_COLOR)
		insert(buf, view.background_color)

		insert(buf, C.DRAW_BACKGROUND_LAYER)
		insert(buf, view)

		insert(buf, C.POP_STATE)
	end

	if view.draw then
		insert(buf, C.PUSH_STATE)

		if view.color then
			insert(buf, C.SET_COLOR)
			insert(buf, view.color)
		end

		if view.blend_mode then
			insert(buf, C.SET_BLEND_MODE)
			insert(buf, view.blend_mode)
		end

		insert(buf, C.DRAW_VIEW)
		insert(buf, view)

		insert(buf, C.POP_STATE)
	end

	if has_state then
		insert(buf, C.POP_STATE)
	end

	local c = view.children
	for i = 1, #c do
		traverse(c[i])
	end

	if view.outline and view.outline.color and view.outline.thickness then
		insert(buf, C.PUSH_STATE)

		insert(buf, C.SET_COLOR)
		insert(buf, view.outline.color)

		insert(buf, C.APPLY_TRANSFORM)
		insert(buf, view.transform.love_transform)

		insert(buf, C.DRAW_OUTLINE)
		insert(buf, view)

		insert(buf, C.POP_STATE)
	end

	if view.stencil then
		insert(buf, C.STENCIL_END)
	end
end

---@param view yi.View
---@return yi.CommandBuffer
return function(view)
	buf = {}
	traverse(view)
	return buf
end
