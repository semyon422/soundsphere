local class = require("class")
local ClientRemoteValidation = require("sea.app.remotes.ClientRemoteValidation")
local Remote = require("icc.Remote")

---@class sea.InternalPeer
---@operator call: sea.InternalPeer
---@field user sea.User
---@field peer_id string ip:port
---@field remote sea.ClientRemoteValidation
---@field remote_no_return sea.ClientRemoteValidation
---@field peer sea.InternalPeer
local InternalPeer = class()

---@param th icc.TaskHandler
---@param icc_peer icc.IPeer
---@param user sea.User
---@param peer_id string
function InternalPeer:new(th, icc_peer, user, peer_id)
	self.__th = th
	self.__icc_peer = icc_peer
	self.user = user
	self.peer_id = peer_id
	self.peer = self
	self.remote = ClientRemoteValidation(Remote(self.__th, self.__icc_peer))
	self.remote_no_return = ClientRemoteValidation(-Remote(self.__th, self.__icc_peer))
end

return InternalPeer
