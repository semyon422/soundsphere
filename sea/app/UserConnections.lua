local class = require("class")
local ClientRemoteValidation = require("sea.app.remotes.ClientRemoteValidation")
local Remote = require("icc.Remote")
local TaskHandler = require("icc.TaskHandler")
local RemoteHandler = require("icc.RemoteHandler")
local Queues = require("icc.Queues")
local User = require("sea.access.User")
local Peer = require("sea.app.Peer")

---@class sea.UserConnections
---@operator call: sea.UserConnections
---@field task_handler icc.TaskHandler
---@field remote_handler icc.RemoteHandler
local UserConnections = class()

UserConnections.ttl = 90

---@param repo sea.UserConnectionsRepo
---@param users_repo sea.UsersRepo
function UserConnections:new(repo, users_repo)
	self.repo = repo
	self.users_repo = users_repo
	self.queues = Queues(function(id)
		return self:getQueueFromSid(id)
	end)
end

---@param server_remote sea.ServerRemote
---@param whitelist icc.RemoteHandlerWhitelist
function UserConnections:setup(server_remote, whitelist)
	self.remote_handler = RemoteHandler(server_remote, whitelist)
	self.task_handler = TaskHandler(self.remote_handler, "server")
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
function UserConnections:getId(ip, port)
	return ip .. ":" .. port
end

---@param sid string
---@return icc.SharedMemoryQueue
function UserConnections:getQueueFromSid(sid)
	local ip, port = sid:match("^(.+):(%d+)$")
	port = tonumber(port)
	---@cast port -?
	return self.repo:getQueue(ip, port)
end

---@private
---@param user_id integer|true|nil
---@return sea.User
function UserConnections:_getUser(user_id)
	if type(user_id) == "number" then
		return self.users_repo:getUser(user_id) or User()
	end
	return User()
end

---@param ip string
---@param port integer
---@param caller_ip string
---@param caller_port integer
---@return sea.Peer?
function UserConnections:getPeer(ip, port, caller_ip, caller_port)
	if not self.repo:hasConnection(ip, port) then
		return
	end
	local user_id = self.repo:getConnectionUser(ip, port)
	local user = self:_getUser(user_id)
	local icc_peer = self.queues:getPeer(self:getId(ip, port), self:getId(caller_ip, caller_port))
	return Peer(self.task_handler, icc_peer, user, ip, port)
end

---@param caller_ip string
---@param caller_port integer
---@return sea.Peer[]
function UserConnections:getPeers(caller_ip, caller_port)
	local keys = self.repo.dict:get_keys(0)
	local peers = {}
	local sid = self:getId(caller_ip, caller_port)
	for _, key in ipairs(keys) do
		local ip, port = key:match("^c:(.+):(%d+)$")
		port = tonumber(port)
		if ip and port then
			local user_id = self.repo:getConnectionUser(ip, port)
			local user = self:_getUser(user_id)
			local icc_peer = self.queues:getPeer(self:getId(ip, port), sid)
			table.insert(peers, Peer(self.task_handler, icc_peer, user, ip, port))
		end
	end
	return peers
end

---@param user_id integer
---@param caller_ip string
---@param caller_port integer
---@return sea.Peer[]
function UserConnections:getPeersForUser(user_id, caller_ip, caller_port)
	local keys = self.repo.dict:get_keys(0)
	local peers = {}
	local sid = self:getId(caller_ip, caller_port)
	local user = self:_getUser(user_id)
	for _, key in ipairs(keys) do
		local ip, port = key:match("^c:(.+):(%d+)$")
		port = tonumber(port)
		if ip and port then
			if self.repo:getConnectionUser(ip, port) == user_id then
				local icc_peer = self.queues:getPeer(self:getId(ip, port), sid)
				table.insert(peers, Peer(self.task_handler, icc_peer, user, ip, port))
			end
		end
	end
	return peers
end

---@param sid string
---@param client_remote sea.ClientRemoteValidation
function UserConnections:processQueue(sid, client_remote)
	local msg, return_peer = self.queues:pop(sid)
	if not msg then return end

	if not msg.ret then
		assert(return_peer)
		local handler = RemoteHandler(client_remote)
		TaskHandler(handler, "client-proxy"):handleCall(return_peer, {}, msg)
	else
		assert(not return_peer)
		self.task_handler:handleReturn(msg)
	end
end

return UserConnections
