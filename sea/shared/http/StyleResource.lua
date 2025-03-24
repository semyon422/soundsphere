local IResource = require("web.framework.IResource")

---@class sea.StyleResource: web.IResource
---@operator call: sea.StyleResource
local StyleResource = IResource + {}

StyleResource.uri = "/style.css"

local files = {
	"sea/access/http/users.css",
	"sea/leaderboards/http/rankings.css"
}

---@param path string
---@return string
local function read_file(path)
	local f = io.open(path, "rb")
	if not f then
		error(("no file '%s'"):format(path))
	end
	local c = f:read("*a")
	f:close()
	return c
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function StyleResource:GET(req, res, ctx)
	local out = {}
	for _, path in ipairs(files) do
		table.insert(out, read_file(path))
	end

	res.headers:set("Content-Type", "text/css")
	res:send(table.concat(out, "\n"))
end

return StyleResource
