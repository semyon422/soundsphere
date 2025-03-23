local IResource = require("web.framework.IResource")

---@class sea.LogoutResource: web.IResource
---@operator call: sea.LogoutResource
local LogoutResource = IResource + {}

LogoutResource.uri = "/logout"

---@param sessions web.Sessions
---@param users sea.Users
function LogoutResource:new(sessions, users)
	self.sessions = sessions
	self.users = users
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function LogoutResource:POST(req, res, ctx)
	if not ctx.session then
		res.status = 400
		return
	end

	self.users:logout(ctx.session_user, ctx.session.id)
	self.sessions:set(res.headers, {})

	res.status = 302
	res.headers:set("HX-Location", "/")
end

return LogoutResource
