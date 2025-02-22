local Difftable = require("sea.difftables.Difftable")

---@type rdb.ModelOptions
local difftables = {}

difftables.metatable = Difftable

return difftables
