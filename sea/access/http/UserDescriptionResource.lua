local IResource = require("web.framework.IResource")
local UserPage = require("sea.access.http.UserPage")
local http_util = require("aqua.web.http.util")
local json = require("aqua.web.json")

---@class sea.UserDescriptionResource: web.IResource
---@operator call: sea.UserDescriptionResource
local UserDescriptionResource = IResource + {}

UserDescriptionResource.uri = "/users/:user_id/edit_description"
UserDescriptionResource.descriptionLength = 4096

---@param users sea.Users
---@param views web.Views
function UserDescriptionResource:new(users, views)
	self.users = users
	self.views = views
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function UserDescriptionResource:POST(req, res, ctx)
	local user = self.users:getUser(tonumber(ctx.path_params.user_id))
	local page = UserPage(self.users.users_access, ctx.session_user, user)

	if not page:canUpdate() then
		res.status = 403
		return nil, "forbidden"
	end

	---@type {[string]: any}?, string?
	local description, _ = http_util.get_json(req)

	if not description then
		res.status = 400
		return nil, "invalid json"
	end

	local encoded = json.encode(description)

	if encoded:len() > self.descriptionLength then
		res.status = 400
		return nil, "description size limit reached"
	end

	if not description.ops then
		encoded = ""
	end

	if #description.ops == 1 and description.ops[1].insert == "\n" then
		encoded = ""
	end

	-- TODO: Replace user description with `encoded`
	res.status = 200
end

return UserDescriptionResource
