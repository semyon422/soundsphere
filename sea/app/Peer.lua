local class = require("class")
local ClientRemoteValidation = require("sea.app.remotes.ClientRemoteValidation")
local Remote = require("icc.Remote")

---@class sea.Peer: sea.IServerRemoteContext
---@operator call: sea.Peer
---@field remote sea.ClientRemoteValidation
---@field remote_no_return sea.ClientRemoteValidation
local Peer = class()

---@param th icc.TaskHandler
---@param icc_peer icc.IPeer
---@param user sea.User
---@param ip string
---@param port integer
---@param session sea.Session?
function Peer:new(th, icc_peer, user, ip, port, session)
	local remote = Remote(th, icc_peer)
	self.remote = ClientRemoteValidation(remote)
	self.remote_no_return = ClientRemoteValidation(-remote)
	self.user = user
	self.session = session
	self.ip = ip
	self.port = port
	self.peer_id = ip .. ":" .. port
	self.peer = self
end

return Peer
