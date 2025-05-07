local IResource = require("web.framework.IResource")

---@class sea.StyleResource: web.IResource
---@operator call: sea.StyleResource
local StyleResource = IResource + {}

StyleResource.routes = {
	{"/style.css", {
		GET = "getStyle",
	}},
}

local files = {
	"sea/shared/http/style.css",
	"sea/shared/http/header.css",
	"sea/shared/http/ranking_table.css",
	"sea/shared/http/index.css",
	"sea/access/http/user.css",
	"sea/access/http/users.css",
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
function StyleResource:getStyle(req, res, ctx)
	local out = {}
	for _, path in ipairs(files) do
		table.insert(out, read_file(path))
	end

	res.headers:set("Content-Type", "text/css")
	res:send(table.concat(out, "\n"))
end

return StyleResource
