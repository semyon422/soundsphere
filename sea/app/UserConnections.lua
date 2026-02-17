local class = require("class")
local ClientRemoteValidation = require("sea.app.remotes.ClientRemoteValidation")
local Remote = require("icc.Remote")
local TaskHandler = require("icc.TaskHandler")
local RemoteHandler = require("icc.RemoteHandler")
local QueuePeer = require("icc.QueuePeer")
local Message = require("icc.Message")

---@class sea.Peer
---@field remote sea.ClientRemoteValidation
---@field remote_no_return sea.ClientRemoteValidation
---@field queue icc.SharedMemoryQueue
local Peer = class()

---@param th icc.TaskHandler
---@param queue icc.SharedMemoryQueue
function Peer:new(th, queue)
	local icc_peer = QueuePeer(queue)
	local remote = Remote(th, icc_peer)
	self.remote = ClientRemoteValidation(remote)
	self.remote_no_return = ClientRemoteValidation(-remote)
	self.queue = queue
end

---@class sea.UserConnections
---@operator call: sea.UserConnections
---@field task_handler icc.TaskHandler
---@field remote_handler icc.RemoteHandler
local UserConnections = class()

UserConnections.ttl = 90

---@param repo sea.UserConnectionsRepo
function UserConnections:new(repo)
	self.repo = repo
end

---@param server_remote sea.ServerRemote
---@param whitelist icc.RemoteHandlerWhitelist
function UserConnections:setup(server_remote, whitelist)
	self.remote_handler = RemoteHandler(server_remote, whitelist)
	self.task_handler = TaskHandler(self.remote_handler)
end

---@param ip string
---@param port integer
---@param user_id? integer
function UserConnections:onConnect(ip, port, user_id)
	self:heartbeat(ip, port, user_id)
end

---@param ip string
---@param port integer
---@param user_id? integer
function UserConnections:onDisconnect(ip, port, user_id)
	self.repo:removeConnection(ip, port)
	if user_id then
		self.repo:setUserOffline(user_id)
	end
end

---@param user_id integer
function UserConnections:onUserConnect(user_id)
	self.repo:setUserOnline(user_id, self.ttl)
end

---@param user_id integer
function UserConnections:onUserDisconnect(user_id)
	self.repo:setUserOffline(user_id)
end

---@param ip string
---@param port integer
---@param user_id? integer
function UserConnections:heartbeat(ip, port, user_id)
	self.repo:setConnection(ip, port, user_id, self.ttl)
	if user_id then
		self.repo:setUserOnline(user_id, self.ttl)
	end
end

function UserConnections:getOnlineCount()
	return self.repo:getGlobalCount()
end

---@param user_id integer
---@return boolean
function UserConnections:isUserOnline(user_id)
	return self.repo:isUserOnline(user_id)
end

---@param ip string
---@param port integer
---@return sea.Peer?
function UserConnections:getPeer(ip, port)
	if not self.repo:hasConnection(ip, port) then
		return
	end
	return Peer(self.task_handler, self.repo:getQueue(ip, port))
end

---@return sea.Peer[]
function UserConnections:getPeers()
	local keys = self.repo.dict:get_keys(0)
	local peers = {}
	for _, key in ipairs(keys) do
		local ip, port = key:match("^c:(.+):(%d+)$")
		if ip and port then
			table.insert(peers, Peer(self.task_handler, self.repo:getQueue(ip, tonumber(port))))
		end
	end
	return peers
end

---@param user_id integer
---@return sea.Peer[]
function UserConnections:getPeersForUser(user_id)
	local keys = self.repo.dict:get_keys(0)
	local peers = {}
	for _, key in ipairs(keys) do
		local ip, port = key:match("^c:(.+):(%d+)$")
		if ip and port then
			if self.repo:getConnectionUser(ip, tonumber(port)) == user_id then
				table.insert(peers, Peer(self.task_handler, self.repo:getQueue(ip, tonumber(port))))
			end
		end
	end
	return peers
end

return UserConnections
