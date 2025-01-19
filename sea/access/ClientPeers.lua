local class = require("class")

---@class sea.ClientPeers
---@operator call: sea.ClientPeers
local ClientPeers = class()

---@return sea.IClientPeer?
---@return string?
function ClientPeers:new()
	---@type sea.IClientPeer[]
	self.peers = {}
end

---@param user_id integer
---@return sea.IClientPeer?
---@return string?
function ClientPeers:get(user_id)
	local client_peer = self.peers[user_id]
	if client_peer then
		return client_peer
	end
	return nil, "user not connected"
end

---@param user_id integer
---@param client_peer sea.IClientPeer
function ClientPeers:set(user_id, client_peer)
	self.peers[user_id] = client_peer
end

return ClientPeers
