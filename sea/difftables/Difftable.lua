local class = require("class")
local valid = require("valid")
local types = require("sea.shared.types")

---@class sea.Difftable
---@operator call: sea.Difftable
---@field id integer
---@field name string
---@field description string
---@field symbol string
---@field created_at integer
local Difftable = class()

local validate_difftable = valid.struct({
	name = types.name,
	description = types.description,
	symbol = types.name,
})

---@return true?
---@return string[]?
function Difftable:validate()
	local ok, errs = validate_difftable(self)
	if not ok then
		return nil, valid.flatten(errs)
	end
	return true
end

return Difftable
