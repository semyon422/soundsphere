local IResource = require("web.framework.IResource")
local http_util = require("http_util")

---@class sea.PolicyResource: web.IResource
---@operator call: sea.PolicyResource
local PolicyResource = IResource + {}

PolicyResource.routes = {
	{"/policies", {
		GET = "getPage",
	}},
}

---@param views web.Views
function PolicyResource:new(views)
	self.views = views
	self.policies = {
		{
			key = "terms",
			name = "Terms of Use",
			filename = "sea/shared/http/terms_of_use.md"
		},
		{
			key = "privacy",
			name = "Privacy Policy",
			filename = "sea/shared/http/privacy_policy.md"
		},
		{
			key = "dmca",
			name = "Copyright (DMCA)",
			filename = "sea/shared/http/dmca.md",
		}
	}
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function PolicyResource:getPage(req, res, ctx)
	local policy_key = ctx.query.policy_key or "terms"

	ctx.policies = self.policies
	ctx.selected_policy_key = policy_key

	for _, v in ipairs(self.policies) do
		if v.key == policy_key then
			ctx.policy_filename = v.filename
		end
	end

	ctx.responsible_person_name = "Semyon"
	ctx.responsible_person_email = "semyon@email.com"

	if not ctx.policy_filename then
		ctx.policy_filename = self.policies[1].filename
	end

	self.views:render_send(res, "sea/shared/http/policies.etlua", ctx, true)
end

return PolicyResource
