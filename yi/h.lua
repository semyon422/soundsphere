local table_util = require("table_util")

local mixed_params = {} ---@type {[string]: any}

---@param view_instance yi.View
---@param params {[string]: any, [number]: table}? Can take either key=value, or table with key values
---@param children yi.View[]? View instances
---@return yi.View
local function create(view_instance, params, children)
	table_util.clear(mixed_params)

	if params then
		for k, v in pairs(params) do
			if type(k) == "string" then
				mixed_params[k] = v
			elseif type(k) == "number" and type(v) == "table" then
				---@cast v {[string]: any}
				for k2, v2 in pairs(v) do
					mixed_params[k2] = v2
				end
			end
		end

		view_instance:setup(mixed_params)
	end

	if children then
		for i = 1, #children do
			view_instance:add(children[i])
		end
	end

	return view_instance
end

return create
