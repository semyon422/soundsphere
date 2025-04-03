local utf8 = require("utf8")
local table_util = require("table_util")

local types = {}

function types.name(v)
	if type(v) ~= "string" then
		return nil, "not a string"
	end

	---@type integer?
	local len = utf8.len(v)
	if not len then
		return nil, "not a valid UTF-8 string"
	end

	if len == 0 then
		return nil, "too short"
	elseif len > 32 then
		return nil, "too long"
	end

	return true
end

function types.description(v)
	if type(v) ~= "string" then
		return nil, "not a string"
	end

	---@type integer?
	local len = utf8.len(v)
	if not len then
		return nil, "not a valid UTF-8 string"
	end

	if len > 4096 then
		return nil, "too long"
	end

	return true
end

function types.count(v)
	if type(v) ~= "number" then
		return nil, "not a number"
	elseif v ~= math.floor(v) then
		return nil, "not an integer"
	elseif v < 0 then
		return nil, "negative"
	end

	return true
end

function types.boolean(v)
	if type(v) ~= "boolean" then
		return nil, "not a boolean"
	end

	return true
end

--------------------------------------------------------------------------------

---@param enum rdb.Enum
function types.new_enum(enum)
	return function(v)
		return not not enum:encode_safe(v)
	end
end

---@param t type|fun(v: any): boolean
---@param type_name string?
function types.new_is_array_of(t, type_name)
	if not type_name and type(t) == "string" then
		type_name = t
	end
	if not type_name then
		return function(v)
			return table_util.is_array_of(v, t)
		end
	end
	return function(v)
		if not table_util.is_array_of(v, t) then
			return nil, "not a " .. type_name
		end
		return true
	end
end

return types
