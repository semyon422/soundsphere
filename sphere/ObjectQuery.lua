local Class = require("Class")

local ObjectQuery = Class:new()

ObjectQuery.construct = function(self)
	self.joins = {}
end

ObjectQuery.setJoin = function(self, t, dbTable, on)
	table.insert(self.joins, {t .. " JOIN", dbTable, on})
end

ObjectQuery.setInnerJoin = function(self, dbTable, on)
	self:setJoin("INNER", dbTable, on)
end

ObjectQuery.setLeftJoin = function(self, dbTable, on)
	self:setJoin("LEFT", dbTable, on)
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

ObjectQuery.getQueryParams = function(self)
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

ObjectQuery.getCountQueryParams = function(self)
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

ObjectQuery.getCount = function(self)
	local out = {}

	table.insert(out, "SELECT COUNT(1) as c")
	table.insert(out, ("FROM %s"):format(self.table))
	table.insert(out, self:concatJoins())

	return self.db:query(table.concat(out, " "))[1].c
end

return ObjectQuery
