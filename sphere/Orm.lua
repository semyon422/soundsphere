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

function orm:close()
	return self.c:close()
end

function orm:begin()
	return self.c:exec("BEGIN")
end

function orm:commit()
	return self.c:exec("COMMIT")
end

local function to_object(object, row, colnames)
	object = object or {}
	for i, k in ipairs(colnames) do
		local value = row[i]
		if type(value) == "cdata" then
			value = tonumber(value) or value
		end
		object[k] = value
	end
	return object
end

local function escape_identifier(s)
	if type(s) == "table" then
		return s[1]
	end
	s = tostring(s)
	return '`' .. (s:gsub('`', '``')) .. '`'
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
		objects[#objects + 1] = to_object({}, row, colnames)
		row = stmt:step(row)
	end
	return objects
end

function orm:select(query, ...)
	return self:query("SELECT " .. query, ...) or {}
end

function orm:update(table_name, values, conditions, ...)
	local assigns = {}
	for k, v in pairs(values) do
		table.insert(assigns, ("%s = %q"):format(
			escape_identifier(k), v
		))
	end

	self:query(("UPDATE %s SET %s WHERE %s"):format(
		escape_identifier(table_name), table.concat(assigns, ", "), conditions
	), ...)
end

function orm:delete(table_name, conditions, ...)
	self:query(("DELETE FROM %s WHERE %s"):format(
		escape_identifier(table_name), conditions
	), ...)
end

function orm:insert(table_name, values)
	local count = 0
	local keys = {}
	for key in pairs(values) do
		count = count + 1
		keys[count] = escape_identifier(key)
	end
	local pattern = ("(%s)"):format(("?, "):rep(count - 1) .. "?")

	local stmt = self.c:prepare(("INSERT INTO %s %s VALUES %s RETURNING *"):format(
		escape_identifier(table_name), ("(%s)"):format(table.concat(keys, ", ")), pattern
	))

	for i, key in ipairs(keys) do
		stmt:bind1(i, values[key])
	end

	local row, colnames = stmt:step({}, {})
	return to_object(values, row, colnames)
end

return orm
