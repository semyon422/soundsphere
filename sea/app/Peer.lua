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
	self.__th = th
	self.__icc_peer = icc_peer
	self.user = user
	self.session = session
	self.ip = ip
	self.port = port
	self.peer_id = ip .. ":" .. port
	self.peer = self
end

function Peer:__index(k)
	local v = Peer[k]
	if v ~= nil then return v end

	if k == "remote" then
		self.remote = ClientRemoteValidation(Remote(self.__th, self.__icc_peer))
		return self.remote
	elseif k == "remote_no_return" then
		self.remote_no_return = ClientRemoteValidation(-Remote(self.__th, self.__icc_peer))
		return self.remote_no_return
	end
end

return Peer
