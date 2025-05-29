local IntegerArray = require("sea.storage.server.IntegerArray")

local IntegerArrayOptional = {}

---@param t integer[]?
---@return string?
function IntegerArrayOptional.encode(t)
	if not t then
		return
	end
	return IntegerArray.encode(t)
end

---@param s string?
---@return integer[]?
function IntegerArrayOptional.decode(s)
	if not s then
		return
	end
	return IntegerArray.decode(s)
end

return IntegerArrayOptional
