local IResource = require("web.framework.IResource")
local UserPage = require("sea.access.http.UserPage")
local http_util = require("http_util")

---@class sea.UserResource: web.IResource
---@operator call: sea.UserResource
local UserResource = IResource + {}

UserResource.uri = "/users/:user_id"

---@param users sea.Users
---@param views web.Views
function UserResource:new(users, views)
	self.users = users
	self.views = views

	self.testActivity = {
		["21-03-2025"] = 30,
		["24-03-2025"] = 40,
		["25-03-2025"] = 10,
	}
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function UserResource:GET(req, res, ctx)
	local query = http_util.decode_query_string(ctx.parsed_uri.query)

	local user = self.users:getUser(tonumber(ctx.path_params.user_id))

	if user.id == 0 then
		self.views:render_send(res, "sea/shared/http/not_found.etlua", ctx, true)
		return
	end

	ctx.user = user
	ctx.page = UserPage(self.testActivity)
	ctx.ignore_main_container = true
	ctx.owner = ctx.user.id == ctx.session_user.id
	ctx.edit_description = ctx.owner and query.edit_description == "true"
	self.views:render_send(res, "sea/access/http/user.etlua", ctx, true)
end

return UserResource
