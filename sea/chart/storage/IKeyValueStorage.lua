local class = require("class")

---@class sea.IKeyValueStorage
---@operator call: sea.IKeyValueStorage
local IKeyValueStorage = class()

---@param key string
---@return string?
---@return string?
function IKeyValueStorage:get(key) end

---@param key string
---@param value string
---@return true?
---@return string?
function IKeyValueStorage:set(key, value) end

return IKeyValueStorage
