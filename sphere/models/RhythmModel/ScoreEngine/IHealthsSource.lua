local class = require("class")

---@class sphere.IHealthsSource
---@operator call: sphere.IHealthsSource
local IHealthsSource = class()

---@return number
function IHealthsSource:getHealths()
	error("not implemented")
end

---@return number
function IHealthsSource:getMaxHealths()
	error("not implemented")
end

---@return boolean
function IHealthsSource:isFailed()
	error("not implemented")
end

return IHealthsSource
