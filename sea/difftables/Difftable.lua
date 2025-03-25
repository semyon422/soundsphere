local class = require("class")

---@class sea.Difftable
---@operator call: sea.Difftable
---@field id integer
---@field name string
---@field description string
---@field symbol string
---@field created_at integer
local Difftable = class()

---@return true?
---@return string[]?
function Difftable:validate()
	local errs = {}

	if type(self.name) ~= "string" or #self.name == 0 then
		table.insert(errs, "invalid name")
	end
	if type(self.description) ~= "string" then
		table.insert(errs, "invalid description")
	end
	if type(self.symbol) ~= "string" then
		table.insert(errs, "invalid symbol")
	end

	if #errs > 0 then
		return nil, errs
	end

	return true
end

return Difftable
