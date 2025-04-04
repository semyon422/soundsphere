local utf8 = require("utf8")

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

function types.file_name(v)
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
	elseif len > 255 then
		return nil, "too long"
	end

	return true
end

function types.binary(v)
	if type(v) ~= "string" then
		return nil, "not a string"
	end

	return true
end

function types.number(v)
	if type(v) ~= "number" then
		return nil, "not a number"
	elseif v ~= v then
		return nil, "NaN"
	elseif math.abs(v) == math.huge then
		return nil, "infinite"
	end

	return true
end

function types.normalized(v)
	if type(v) ~= "number" then
		return nil, "not a number"
	elseif v ~= v then
		return nil, "NaN"
	elseif v < 0 or v > 1 then
		return nil, "out of range"
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
types.time = types.count

function types.index(v)
	if type(v) ~= "number" then
		return nil, "not a number"
	elseif v ~= math.floor(v) then
		return nil, "not an integer"
	elseif v < 1 then
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

function types.md5hash(v)
	if type(v) ~= "string" then
		return nil, "not a string"
	elseif #v ~= 32 or not v:match("^[a-f0-9]*$") then
		return nil, "invalid md5 hash"
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

return types
