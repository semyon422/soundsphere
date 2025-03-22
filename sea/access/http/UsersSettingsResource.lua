local IResource = require("web.framework.IResource")

---@class sea.UsersSettingsResource: web.IResource
---@operator call: sea.UsersSettingsResource
local UsersSettingsResource = IResource + {}

UsersSettingsResource.uri = "/users/:user_id/settings"

---@param users sea.Users
---@param views web.Views
function UsersSettingsResource:new(users, views)
	self.users = users
	self.views = views
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function UsersSettingsResource:GET(req, res, ctx)
	ctx.user = self.users:getUser(tonumber(ctx.path_params.user_id))
	self.views:render_send(res, "sea/access/http/user_settings.etlua", ctx, true)
end

return UsersSettingsResource
