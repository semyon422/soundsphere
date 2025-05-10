local IKeyValueStorage = require("sea.chart.storage.IKeyValueStorage")

---@class sea.TableStorage: sea.IKeyValueStorage
---@operator call: sea.TableStorage
local TableStorage = IKeyValueStorage + {}

---@param key string
---@return string?
---@return string?
function TableStorage:get(key)
	local value = rawget(self, key)
	if not value then
		return nil, "value not found"
	end
	return value
end

---@param key string
---@param value string
---@return true?
---@return string?
function TableStorage:set(key, value)
	rawset(self, key, value)
	return true
end

return TableStorage
