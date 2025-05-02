local IResource = require("web.framework.IResource")
local UserPage = require("sea.access.http.UserPage")
local http_util = require("web.http.util")
local json = require("web.json")

---@class sea.UserResource: web.IResource
---@operator call: sea.UserResource
local UserResource = IResource + {}

UserResource.routes = {
	{"/users/:user_id", {
		GET = "getUser",
	}},
	{"/users/:user_id/update_description", {
		POST = "updateDescription",
	}},
	{"/users/:user_id/sessions", {
		GET = "getUserSessions",
	}},
	{"/users/:user_id/settings", {
		GET = "getUserSettings",
	}},
	{"/users/:user_id/teams", {
		GET = "getUserTeams",
	}},
}

UserResource.descriptionLength = 4096

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

	self.testScores = {
		{
			artist = "Artist",
			title = "Not very long title but still it's long",
			name = "Easy",
			creator = "Someone",
			timeRate = 1.05,
			mods = "P2 AltK RD AM7 CH5 BS",
			accuracy = 0.9013,
			timeSince = "10 days ago",
			grade = "S",
			rating = "30.10",
			ratingPostfix = "ENPS"
		},
		{
			artist = "A",
			title = "Short title!",
			name = "Insane",
			creator = "( ͡° ͜ʖ ͡°)",
			timeRate = 1,
			mods = "",
			accuracy = 0.9459,
			timeSince = "1 year ago",
			grade = "A",
			rating = "517",
			ratingPostfix = "PP"
		},
		{
			artist = "I hate short titles",
			title = "This text means nothing this text means nothing this text means nothing this text means nothing this text means nothing",
			name = "123 123 123 123 123 123 123 123 123 123 123 123 123 123 123 123 123 123 123 123 123 123 123 123 123 123 123 123 123 123 123",
			creator = "( ͡° ͜ʖ ͡°)",
			timeRate = 1,
			mods = "P2 AltK RD AM7 CH5 BS",
			accuracy = 0.9459,
			timeSince = "1 year ago",
			grade = "X",
			rating = "34.34",
			ratingPostfix = "MSD"
		}
	}
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function UserResource:getUser(req, res, ctx)
	local query = http_util.decode_query_string(ctx.parsed_uri.query)

	local user = self.users:getUser(tonumber(ctx.path_params.user_id))

	if user.id == 0 then
		res.status = 404
		self.views:render_send(res, "sea/shared/http/not_found.etlua", ctx, true)
		return
	end

	local page = UserPage(self.users.users_access, ctx.session_user, user)
	page:setActivity(self.testActivity)

	ctx.page = page
	ctx.user = user
	ctx.scores = self.testScores

	ctx.can_update = page:canUpdate()
	ctx.edit_description = ctx.can_update and query.edit_description == "true"

	ctx.ignore_main_container = true
	self.views:render_send(res, "sea/access/http/user.etlua", ctx, true)
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function UserResource:updateDescription(req, res, ctx)
	local user = self.users:getUser(tonumber(ctx.path_params.user_id))
	local page = UserPage(self.users.users_access, ctx.session_user, user)

	if not page:canUpdate() then
		res.status = 403
		res:send("forbidden")
		return
	end

	---@type {[string]: any}?, string?
	local description, _ = http_util.get_json(req)

	if not description then
		res.status = 400
		res:send("invalid json")
		return
	end

	local encoded = json.encode(description)

	if encoded:len() > self.descriptionLength then
		res.status = 400
		res:send("description size limit reached")
		return
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

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function UserResource:getUserSessions(req, res, ctx)
	self.views:render_send(res, "sea/access/http/user_sessions.etlua", ctx, true)
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function UserResource:getUserSettings(req, res, ctx)
	ctx.user = self.users:getUser(tonumber(ctx.path_params.user_id))
	self.views:render_send(res, "sea/access/http/user_settings.etlua", ctx, true)
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function UserResource:getUserTeams(req, res, ctx)
	self.views:render_send(res, "sea/access/http/user_teams.etlua", ctx, true)
end

return UserResource
