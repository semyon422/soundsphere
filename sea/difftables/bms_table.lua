local socket_url = require("socket.url")  ---@diagnostic disable-line
local http_util = require("web.http.util")
local json = require("web.json")

local bms_table = {}

---@param s string
---@return {[string]: string}
local function parse_args(s)
	---@type {[string]: string}
	local arg = {}
	s:gsub("([%-%w]+)=([\"'])(.-)%2", function(w, _, a)
		arg[w] = a
	end)
	return arg
end

---@param link string
---@return {name: string, symbol: string}?
---@return {md5: string, level: integer}|string?
function bms_table.fetch(link)
	local body, status = http_util.request(assert(link))
	if not body then
		return nil, status  ---@diagnostic disable-line
	end
	if status ~= 200 then
		return nil, "status ~= 200"
	end

	---@type string?
	local header_path
	for args in body:gmatch("<meta(.-)%/?>") do
		args = parse_args(args)
		if args.name == "bmstable" then
			header_path = args.content
			break
		end
	end

	if not header_path then
		return nil, "header url not found"
	end

	---@type string
	local header_link = socket_url.absolute(link, header_path)
	body, status = http_util.request(header_link)
	if not body then
		return nil, status  ---@diagnostic disable-line
	end
	if status ~= 200 then
		return nil, "status ~= 200"
	end

	---@type boolean, {data_url: string?, name: string, symbol: string}
	local ok, header = pcall(json.decode, body)
	if not ok then
		return nil, "invalid json"
	end
	if not header.data_url then
		return nil, "data url not found"
	end

	---@type string
	local data_link = socket_url.absolute(link, header.data_url)
	body, status = http_util.request(data_link)
	if not body then
		return nil, status  ---@diagnostic disable-line
	end
	if status ~= 200 then
		return nil, "status ~= 200"
	end

	---@type boolean, table
	local ok, data = pcall(json.decode, body)
	if not ok then
		return nil, "invalid json"
	end

	return header, data
end

return bms_table
