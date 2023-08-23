local sqlite = require("ljsqlite3")
local class = require("class")

---@class sphere.Orm
---@operator call: sphere.Orm
local Orm = class()

Orm.print_queries = false
Orm.NULL = {}

function Orm:new()
	self.table_infos = {}
end

---@param db string
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

---@param object table?
---@param row table
---@param colnames table
---@return table
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

---@param s string|table
---@return string
local function escape_identifier(s)
	if type(s) == "table" then
		return s[1]
	end
	s = tostring(s)
	return '`' .. (s:gsub('`', '``')) .. '`'
end

---@param query string
function Orm:exec(query)
	self.c:exec(query)
end

---@param query string
---@param ... any?
---@return ffi.cdata*
function Orm:stmt(query, ...)
	if self.print_queries then
		local values = {...}
		for i = 1, select("#", ...) do
			values[i] = tostring(select(i, ...))
		end
		print(
			(query:gsub("\n", " "):gsub("%s+", " ")) ..
			(select("#", ...) > 0 and (" {%s}"):format(table.concat(values, ", ")) or "")
		)
	end
	local stmt = self.c:prepare(query)
	for i = 1, select("#", ...) do
		stmt:bind1(i, select(i, ...))
	end
	return stmt
end

---@param ... any?
---@return table?
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

---@param table_name string
---@return table?
function Orm:table_info(table_name)
	local info = self.table_infos[table_name]
	if info then
		return info
	end
	info = self:query("PRAGMA table_info(" .. escape_identifier(table_name) .. ")")
	self.table_infos[table_name] = info
	return info
end

---@param table_name string
---@param conditions string?
---@param ... any?
---@return table
function Orm:select(table_name, conditions, ...)
	return self:query(("SELECT * FROM %s %s"):format(
		escape_identifier(table_name), conditions and "WHERE " .. conditions or ""
	), ...) or {}
end

---@param table_name string
---@param values table
---@param conditions string?
---@param ... any?
---@return table?
function Orm:update(table_name, values, conditions, ...)
	local table_info = assert(self:table_info(table_name), "no such table: " .. table_name)

	local assigns = {}
	for _, column in ipairs(table_info) do
		local key = column.name
		local value = values[key]
		if value ~= nil then
			if value == self.NULL then
				value = "NULL"
			elseif type(value) == "boolean" then
				value = value and 1 or 0
			elseif type(value) ~= "number" then
				value = ("%q"):format(value)
			end
			if value ~= value then
				value = 0
			end
			table.insert(assigns, ("%s = %s"):format(
				escape_identifier(key), value
			))
		end
	end

	if not conditions then
		return self:query(("UPDATE %s SET %s"):format(escape_identifier(table_name), table.concat(assigns, ", ")))
	end

	return self:query(("UPDATE %s SET %s WHERE %s"):format(
		escape_identifier(table_name), table.concat(assigns, ", "), conditions
	), ...)
end

---@param table_name string
---@param conditions string?
---@param ... any?
function Orm:delete(table_name, conditions, ...)
	self:query(("DELETE FROM %s WHERE %s"):format(
		escape_identifier(table_name), conditions
	), ...)
end

---@param table_name string
---@param values table
---@param ignore boolean?
---@return table
function Orm:insert(table_name, values, ignore)
	local table_info = assert(self:table_info(table_name), "no such table: " .. table_name)

	local count = 0
	local query_keys = {}
	local query_values = {}
	for _, column in ipairs(table_info) do
		local key = column.name
		local value = values[key]
		if value then
			if value == self.NULL then
				value = nil
			end
			count = count + 1
			query_keys[count] = escape_identifier(key)
			query_values[count] = value
		end
	end

	local pattern = ("(%s)"):format(("?, "):rep(count - 1) .. "?")
	local keys = ("(%s)"):format(table.concat(query_keys, ", "))

	local stmt = self:stmt(("INSERT%s INTO %s %s VALUES %s RETURNING *"):format(
		ignore and " OR IGNORE" or "", escape_identifier(table_name), keys, pattern
	), unpack(query_values, 1, count))

	local row, colnames = stmt:step({}, {})
	assert(not stmt:step())
	stmt:close()
	if not colnames then
		return values
	end
	return to_object(values, row, colnames)
end

---@param v any
---@return any
local function format_value(v)
	local tv = type(v)
	if tv == "string" then
		return ("%q"):format(v)
	elseif tv == "boolean" then
		return v and 1 or 0
	elseif tv == "number" then
		return v
	end
end

local _format_cond = {
	contains = function(k, v)
		return ("%s LIKE %s"):format(k, format_value("%" .. v .. "%"))
	end,
	startswith = function(k, v)
		return ("%s LIKE %s"):format(k, format_value(v .. "%"))
	end,
	endswith = function(k, v)
		return ("%s LIKE %s"):format(k, format_value("%" .. v))
	end,
	["in"] = function(k, v)
		local _v = {}
		for i = 1, #v do
			_v[i] = format_value(v[i])
		end
		return ("%s IN (%s)"):format(k, table.concat(_v, ", "))
	end,
	["notin"] = function(k, v)
		local _v = {}
		for i = 1, #v do
			_v[i] = format_value(v[i])
		end
		return ("%s NOT IN (%s)"):format(k, table.concat(_v, ", "))
	end,
	eq = "%s = %s",
	ne = "%s != %s",
	isnull = "%s IS NULL",
	gt = "%s > %s",
	gte = "%s >= %s",
	lt = "%s < %s",
	lte = "%s <= %s",
	regex = "%s REGEXP %s",
}

---@param op string
---@param k string
---@param v any
---@return string
local function format_cond(op, k, v)
	local fmt = _format_cond[op]
	if type(fmt) == "function" then
		return fmt(k, v)
	end
	return fmt:format(k, format_value(v))
end

---@param t table
---@return string
function Orm:build_condition(t)
	local conds = {}

	for k, v in pairs(t) do
		if type(k) == "string" then
			local field, op = k:match("^(.+)__(.+)$")
			if not field then
				field, op = k, "eq"
			end
			table.insert(conds, format_cond(op, field, v))
		elseif type(v) == "table" then
			table.insert(conds, self:build_condition(v))
		end
	end

	for i = 1, #conds do
		conds[i] = "(" .. conds[i] .. ")"
	end

	local op = t[1] == "or" and "OR" or "AND"
	return table.concat(conds, (" %s "):format(op))
end

return Orm
