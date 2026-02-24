local InternalPeer = require("sea.app.InternalPeer")

---@class sea.Peer: sea.InternalPeer
---@operator call: sea.Peer
local Peer = InternalPeer + {}

---@param th icc.TaskHandler
---@param icc_peer icc.IPeer
---@param user sea.User
---@param ip string
---@param port integer
---@param peer_id string
---@param session sea.Session?
function Peer:new(th, icc_peer, user, ip, port, peer_id, session)
	InternalPeer.new(self, th, icc_peer, user, peer_id)
	self.ip = ip
	self.port = port
	self.session = session
end

return Peer
