---@class sea.CustomAccess
---@operator call: sea.CustomAccess
---@field access table
---@field prefix string
local CustomAccess = {}

function CustomAccess:__index(k)
	local access = self.access
	---@param _ any
	---@param user sea.User
	---@param ... any
	---@return boolean
	return function(_, user, ...)
		---@type boolean
		local ret = access[k](access, user, ...)
		if ret then
			return ret
		end
		local is_owner = user:hasRole("owner")
		return is_owner
	end
end

---@param access table
---@param prefix string
local function __call(_, access, prefix)
	local self = setmetatable({}, CustomAccess)
	self.access = access
	self.prefix = prefix
	return self
end

setmetatable(CustomAccess, {__call = __call})

return CustomAccess
