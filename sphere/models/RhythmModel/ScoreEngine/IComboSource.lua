local class = require("class")

---@class sphere.IComboSource
---@operator call: sphere.IComboSource
local IComboSource = class()

---@return integer
function IComboSource:getCombo()
	error("not implemented")
end

---@return integer
function IComboSource:getMaxCombo()
	error("not implemented")
end

return IComboSource
