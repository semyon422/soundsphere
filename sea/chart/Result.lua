local table_util = require("table_util")
local Enum = require("rdb.Enum")

---@enum (key) sea.Result
local Result = {
	fail = 0, -- determined by sea.Healths
	pass = 1, -- determined by sea.Healths
	fc = 2, -- miss_count = 0
	pfc = 3, -- not_perfect_count = 0
}

Result = Enum(Result)
---@cast Result +{condition: fun(self: rdb.Enum, result: sea.Result): sea.Result[]}

---@param result sea.Result
function Result:condition(result)
	local list = self:list()
	if result == "fail" then
		return list
	end

	local index = table_util.indexof(list, result)

	---@type sea.Result[]
	local values = {}
	for i = index, #list do
		table.insert(values, list[i])
	end

	return values
end

return Result
