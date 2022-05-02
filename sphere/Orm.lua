local sqlite = require("ljsqlite3")

local Orm = {}

Orm.print_queries = false

function Orm:new()
	local object = {table_infos = {}}
	setmetatable(object, self)
	self.__index = self
	return object
end

function Orm:open(db)
	self.c = sqlite.open(db)
end

function Orm:close()
	return self.c:close()
end

function Orm:begin()
	return self.c:exec("BEGIN")
end

function Orm:commit()
	return self.c:exec("COMMIT")
end

local function to_object(object, row, colnames)
	object = object or {}
	for i, k in ipairs(colnames) do
		local value = row[i]
		if k:find("^__boolean_") then
			k = k:sub(11)
			if tonumber(value) == 1 then
				value = true
			else
				value = false
			end
		elseif type(value) == "cdata" then
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

function Orm:exec(query)
	return self.c:exec(query)
end

function Orm:stmt(query, ...)
	if self.print_queries then
		print(
			(query:gsub("\n", " "):gsub("%s+", " ")) ..
			(select("#", ...) and (" {%s}"):format(table.concat({...}, ", ")) or "")
		)
	end
	local stmt = self.c:prepare(query)
	for i = 1, select("#", ...) do
		stmt:bind1(i, select(i, ...))
	end
	return stmt
end

function Orm:query(...)
	local stmt = self:stmt(...)

	local colnames = {}
	local objects = {}

	local row = stmt:step({}, colnames)
	if not row then
		stmt:close()
		return
	end
	while row do
		objects[#objects + 1] = to_object({}, row, colnames)
		row = stmt:step(row)
	end
	stmt:close()
	return objects
end

function Orm:table_info(table_name)
	local info = self.table_infos[table_name]
	if info then
		return info
	end
	info = self:query("PRAGMA table_info(" .. escape_identifier(table_name) .. ")")
	self.table_infos[table_name] = info
	return info
end

function Orm:select(table_name, conditions, ...)
	return self:query(("SELECT * FROM %s %s"):format(
		escape_identifier(table_name), conditions and "WHERE " .. conditions or ""
	), ...) or {}
end

function Orm:update(table_name, values, conditions, ...)
	local table_info = self:table_info(table_name)

	local assigns = {}
	for _, column in ipairs(table_info) do
		local key = column.name
		local value = values[key]
		if value ~= nil then
			if type(value) == "boolean" then
				value = value and 1 or 0
			end
			if type(value) ~= "number" then
				value = ("%q"):format(value)
			end
			table.insert(assigns, ("%s = %s"):format(
				escape_identifier(key), value
			))
		end
	end

	self:query(("UPDATE %s SET %s WHERE %s"):format(
		escape_identifier(table_name), table.concat(assigns, ", "), conditions
	), ...)
end

function Orm:delete(table_name, conditions, ...)
	self:query(("DELETE FROM %s WHERE %s"):format(
		escape_identifier(table_name), conditions
	), ...)
end

function Orm:insert(table_name, values, ignore)
	local table_info = self:table_info(table_name)

	local count = 0
	local query_keys = {}
	for _, column in ipairs(table_info) do
		local key = column.name
		if values[key] then
			table.insert(query_keys, escape_identifier(key))
			count = count + 1
		end
	end

	local pattern = ("(%s)"):format(("?, "):rep(count - 1) .. "?")
	query_keys = ("(%s)"):format(table.concat(query_keys, ", "))

	local stmt = self:stmt(("INSERT%s INTO %s %s VALUES %s RETURNING *"):format(
		ignore and " OR IGNORE" or "", escape_identifier(table_name), query_keys, pattern
	))

	local i = 1
	for _, column in ipairs(table_info) do
		local key = column.name
		if values[key] then
			stmt:bind1(i, values[key])
			i = i + 1
		end
	end

	local row, colnames = stmt:step({}, {})
	assert(not stmt:step())
	stmt:close()
	if not colnames then
		return values
	end
	return to_object(values, row, colnames)
end

return Orm
