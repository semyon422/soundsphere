local class = require("class")

---@class sphere.ObjectQuery
---@operator call: sphere.ObjectQuery
local ObjectQuery = class()

function ObjectQuery:new()
	self.joins = {}
end

---@param t string
---@param dbTable string
---@param on string
function ObjectQuery:setJoin(t, dbTable, on)
	table.insert(self.joins, {t .. " JOIN", dbTable, on})
end

---@param dbTable string
---@param on string
function ObjectQuery:setInnerJoin(dbTable, on)
	self:setJoin("INNER", dbTable, on)
end

---@param dbTable string
---@param on string
function ObjectQuery:setLeftJoin(dbTable, on)
	self:setJoin("LEFT", dbTable, on)
end

---@param field string
---@param condition string
---@return string
function ObjectQuery:newBooleanCase(field, condition)
	return ([[
		CASE WHEN %s THEN TRUE
		ELSE FALSE
		END __boolean_%s
	]]):format(condition, field)
end

---@return string
function ObjectQuery:concatJoins()
	local out = {}
	for _, join in ipairs(self.joins) do
		table.insert(out, join[1] .. " " .. join[2] .. " ON " .. join[3])
	end
	return table.concat(out, "\n")
end

---@return string
function ObjectQuery:getQueryParams()
	local out = {}

	table.insert(out, ("SELECT %s"):format(table.concat(self.fields, ", ")))
	table.insert(out, ("FROM %s"):format(self.table))
	table.insert(out, self:concatJoins())

	if self.where then
		table.insert(out, ("WHERE %s"):format(self.where))
	end
	if self.groupBy then
		table.insert(out, ("GROUP BY %s"):format(self.groupBy))
	end
	if self.orderBy then
		table.insert(out, ("ORDER BY %s"):format(self.orderBy))
	end

	return table.concat(out, " ")
end

---@return string
function ObjectQuery:getCountQueryParams()
	local out = {}

	table.insert(out, "SELECT COUNT(1) as c")
	table.insert(out, ("FROM %s"):format(self.table))
	table.insert(out, self:concatJoins())

	if self.where then
		table.insert(out, ("WHERE %s"):format(self.where))
	end
	if self.groupBy then
		table.insert(out, ("GROUP BY %s"):format(self.groupBy))
	end

	return table.concat(out, " ")
end

---@return number
function ObjectQuery:getCount()
	local out = {}

	table.insert(out, "SELECT COUNT(1) as c")
	table.insert(out, ("FROM %s"):format(self.table))
	table.insert(out, self:concatJoins())

	return self.db:query(table.concat(out, " "))[1].c
end

return ObjectQuery
