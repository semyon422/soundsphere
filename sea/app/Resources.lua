local class = require("class")
local LoginResource = require("sea.access.http.LoginResource")
local RegisterResource = require("sea.access.http.RegisterResource")
local UsersResource = require("sea.access.http.UsersResource")
local StyleResource = require("sea.shared.http.StyleResource")
local WebsocketClientResource = require("sea.shared.http.WebsocketClientResource")
local WebsocketServerResource = require("sea.shared.http.WebsocketServerResource")

---@class sea.Resources
---@operator call: sea.Resources
local Resources = class()

---@param domain sea.Domain
---@param views web.Views
---@param sessions web.Sessions
function Resources:new(domain, views, sessions)
	self.style = StyleResource()
	self.login = LoginResource(sessions, domain.users, views)
	self.register = RegisterResource(sessions, domain.users, views)
	self.users = UsersResource(domain.users, views)
	self.ws_client = WebsocketClientResource(views)
	self.ws_server = WebsocketServerResource()
end

function Resources:getList()
	return {
		self.style,
		self.login,
		self.register,
		self.users,
		self.ws_client,
		self.ws_server,
	}
end

return Resources
