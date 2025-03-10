---@class sea.CustomAccess
---@operator call: sea.CustomAccess
---@field access table
---@field prefix string
---@field clock fun(): integer
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
		local is_owner = user:hasRole("owner", self.clock())
		return is_owner
	end
end

---@param access table
---@param prefix string
---@param clock fun(): integer
local function __call(_, access, prefix, clock)
	local self = setmetatable({}, CustomAccess)
	self.access = access
	self.prefix = prefix
	self.clock = clock
	return self
end

setmetatable(CustomAccess, {__call = __call})

return CustomAccess
