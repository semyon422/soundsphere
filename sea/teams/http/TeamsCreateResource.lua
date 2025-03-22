local IResource = require("web.framework.IResource")

---@class sea.TeamsCreateResource: web.IResource
---@operator call: sea.TeamsCreateResource
local TeamsCreateResource = IResource + {}

TeamsCreateResource.uri = "/teams/create"

---@param teams sea.Teams
---@param views web.Views
function TeamsCreateResource:new(teams, views)
	self.teams = teams
	self.views = views
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function TeamsCreateResource:GET(req, res, ctx)
	self.views:render_send(res, "sea/teams/http/teams_create.etlua", ctx, true)
end

return TeamsCreateResource
