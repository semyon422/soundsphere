local sqlite = require("ljsqlite3")

local orm = {}

function orm:new()
	local object = {}
	setmetatable(object, self)
	self.__index = self
	return object
end

function orm:open(db)
	self.c = sqlite.open(db)
end

function orm:close(db)
	return self.c:close()
end

function orm:begin()
	return self.c:exec("BEGIN;")
end

function orm:commit()
	return self.c:exec("COMMIT;")
end

function orm:toobject(object, row, colnames)
	object = object or {}
	for i, k in ipairs(colnames) do
		object[k] = row[i]
	end
	return object
end

function orm:query(query, ...)
	local stmt = self.c:prepare(query)
	for i = 1, select("#", ...) do
		stmt:bind1(i, select(i, ...))
	end

	local colnames = {}
	local objects = {}

	local row = stmt:step({}, colnames)
	if not row then
		return
	end
	while row do
		print(unpack(row))
		objects[#objects + 1] = orm:toobject({}, row, colnames)
		row = stmt:step(row)
	end
	return objects
end

function orm:select(query, ...)
	return self:query("select " .. query, ...) or {}
end

function orm:update(table_name, values, conditions, ...)
	local assigns = {}
	for k, v in pairs(values) do
		table.insert(assigns, ("%s = %q"):format(k, v))
	end

	self:query(("update %q set %s where %s returning *"):format(
		table_name, table.concat(assigns, ", "), conditions
	), ...)
end

function orm:delete(table_name, conditions, ...)
	self:query(("delete from %q where %s"):format(
		table_name, conditions
	), ...)
end

function orm:insert(table_name, values)
	local count = 0
	local keys = {}
	for key in pairs(values) do
		count = count + 1
		keys[count] = key
	end
	local pattern = ("(%s)"):format(("?, "):rep(count - 1) .. "?")

	local stmt = self.c:prepare(("insert into %q %s values %s returning *"):format(
		table_name, ("(%s)"):format(table.concat(keys, ", ")), pattern
	))

	local i = 1
	for _, key in ipairs(keys) do
		stmt:bind1(i, values[key])
		i = i + 1
	end
	local row, colnames = stmt:step({}, {})

	local types = {}
	for k, v in pairs(values) do
		types[k] = type(v)
	end
	local object = orm:toobject(values, row, colnames)

	for k, v in pairs(types) do
		if v == "number" then
			object[k] = tonumber(object[k])
		end
	end

	return object
end

return orm
