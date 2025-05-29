local class = require("class")
local table_util = require("table_util")

---@alias sea.PeerId string

---@class sea.Peers
---@operator call: sea.Peers
local Peers = class()

function Peers:new()
	---@type {[sea.PeerId]: sea.Peer}
	self.peers = {}
end

---@param peer_id sea.PeerId
---@return sea.Peer?
function Peers:get(peer_id)
	return self.peers[peer_id]
end

---@param peer_id sea.PeerId
---@param peer sea.Peer
function Peers:add(peer_id, peer)
	local peers = self.peers
	assert(not peers[peer_id])
	peers[peer_id] = peer
end

---@param peer_id sea.PeerId
---@return sea.Peer
function Peers:remove(peer_id)
	local peers = self.peers
	local peer = peers[peer_id]
	assert(peer)
	peers[peer_id] = nil
	return peer
end

---@return integer
function Peers:count()
	return #table_util.keys(self.peers)
end

---@return fun(table: table, index?: sea.PeerId): sea.PeerId, sea.Peer
---@return {[sea.PeerId]: sea.Peer}
function Peers:iter()
	return pairs(self.peers)
end

return Peers
