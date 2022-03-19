local Class = require("aqua.util.Class")

local ObjectQuery = Class:new()

ObjectQuery.construct = function(self)
	self.joins = {}
end

ObjectQuery.setInnerJoin = function(self, dbTable, on)
	table.insert(self.joins, {"INNER JOIN", dbTable, on})
end

ObjectQuery.newBooleanCase = function(self, field, condition)
	return ([[
		CASE WHEN %s THEN TRUE
		ELSE FALSE
		END __boolean_%s
	]]):format(condition, field)
end

ObjectQuery.concatJoins = function(self)
	local out = {}
	for _, join in ipairs(self.joins) do
		table.insert(out, join[1] .. " " .. join[2] .. " ON " .. join[3])
	end
	return table.concat(out, "\n")
end

ObjectQuery.getPage = function(self, pageNum, perPage)
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

	table.insert(out, "LIMIT ? OFFSET ?")

	return self.db:query(table.concat(out, " "), perPage, (pageNum - 1) * perPage)
end

ObjectQuery.getCount = function(self)
	return self.db:query(([[
		SELECT COUNT(1) as c
		FROM %s
		%s
	]]):format(self.table, self:concatJoins()))[1].c
end

ObjectQuery.getPosition = function(self, ...)
	local dbTables = {self.table}
	for _, join in ipairs(self.joins) do
		table.insert(dbTables, join[2])
	end

	local fields = {("ROW_NUMBER() OVER(ORDER BY %s) AS pos"):format(self.orderBy or self.table .. "_id")}
	local where = {}
	for _, dbTable in ipairs(dbTables) do
		table.insert(fields, dbTable .. ".id AS " .. dbTable .. "_id")
		table.insert(where, dbTable .. "_id = ?")
	end

	local out = {}

	table.insert(out, ("SELECT %s"):format(table.concat(fields, ", ")))
	table.insert(out, ("FROM %s"):format(self.table))
	table.insert(out, self:concatJoins())

	if self.where then
		table.insert(out, ("WHERE %s"):format(self.where))
	end
	if self.groupBy then
		table.insert(out, ("GROUP BY %s"):format(self.groupBy))
	end

	local result = self.db:query(([[
		SELECT pos FROM
		(%s)
		WHERE %s
	]]):format(
		table.concat(out, " "),
		table.concat(where, " and ")
	), ...)

	return result and result[1] and tonumber(result[1].pos)
end

return ObjectQuery
