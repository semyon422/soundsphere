local IResource = require("web.framework.IResource")

---@class sea.UserTeamsResource: web.IResource
---@operator call: sea.UserTeamsResource
local UserTeamsResource = IResource + {}

UserTeamsResource.uri = "/users/:user_id/teams"

---@param users sea.Users
---@param views web.Views
function UserTeamsResource:new(users, views)
	self.users = users
	self.views = views
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function UserTeamsResource:GET(req, res, ctx)
	self.views:render_send(res, "sea/access/http/user_teams.etlua", ctx, true)
end

return UserTeamsResource
