local class = require("class")
local Room = require("sea.multi.Room")
local RoomUpdate = require("sea.multi.RoomUpdate")
local RoomUser = require("sea.multi.RoomUser")
local MultiplayerAccess = require("sea.multi.access.MultiplayerAccess")

---@class sea.Multiplayer
---@operator call: sea.Multiplayer
local Multiplayer = class()

---@param multiplayer_repo sea.MultiplayerRepo
---@param user_connections sea.UserConnections
function Multiplayer:new(multiplayer_repo, user_connections)
	self.multiplayer_repo = multiplayer_repo
	self.user_connections = user_connections
	self.multiplayer_access = MultiplayerAccess()
end

---@param caller_ip string
---@param caller_port integer
function Multiplayer:getPeers(caller_ip, caller_port)
	return self.user_connections:getPeers(caller_ip, caller_port)
end

---@param peer sea.Peer
---@param caller_ip string
---@param caller_port integer
function Multiplayer:connected(peer, caller_ip, caller_port)
	self:pushUsers(caller_ip, caller_port)
	peer.remote_no_return:setRooms(self:getRooms())
end

---@param peer sea.Peer
---@param caller_ip string
---@param caller_port integer
function Multiplayer:disconnected(peer, caller_ip, caller_port)
	self:leaveRoom(peer.user, caller_ip, caller_port)
	self:pushUsers(caller_ip, caller_port)
end

---@param caller_ip string
---@param caller_port integer
---@return sea.User[]
function Multiplayer:getUsers(caller_ip, caller_port)
	---@type sea.User[]
	local users = {}
	for _, p in ipairs(self:getPeers(caller_ip, caller_port)) do
		if not p.user:isAnon() then
			table.insert(users, p.user)
		end
	end
	table.sort(users, function(a, b)
		return a.id < b.id
	end)
	return users
end

---@param user_id integer
---@param caller_ip string
---@param caller_port integer
---@return sea.Peer?
function Multiplayer:getPeerByUserId(user_id, caller_ip, caller_port)
	for _, p in ipairs(self:getPeers(caller_ip, caller_port)) do
		if p.user.id == user_id then
			return p
		end
	end
end

---@param room_id integer
---@param caller_ip string
---@param caller_port integer
function Multiplayer:iterRoomPeers(room_id, caller_ip, caller_port)
	local room_users = self.multiplayer_repo:getRoomUsers(room_id)

	---@type {[integer]: true}
	local user_ids = {}
	for _, room_user in ipairs(room_users) do
		user_ids[room_user.user_id] = true
	end

	---@type sea.Peer[]
	local peers = {}
	for _, p in ipairs(self:getPeers(caller_ip, caller_port)) do
		if user_ids[p.user.id] then
			table.insert(peers, p)
		end
	end

	return ipairs(peers)
end

---@return sea.Room[]
function Multiplayer:getRooms()
	local rooms = self.multiplayer_repo:getRooms()
	for _, room in ipairs(rooms) do
		room.password = nil
	end
	return rooms
end

---@param id integer
---@return sea.Room?
function Multiplayer:getRoom(id)
	return self.multiplayer_repo:getRoom(id)
end

---@param caller_ip string
---@param caller_port integer
function Multiplayer:pushUsers(caller_ip, caller_port)
	local users = self:getUsers(caller_ip, caller_port)
	for _, p in ipairs(self:getPeers(caller_ip, caller_port)) do
		p.remote_no_return:setUsers(users)
	end
end

---@param caller_ip string
---@param caller_port integer
function Multiplayer:pushRooms(caller_ip, caller_port)
	local rooms = self:getRooms()
	for _, p in ipairs(self:getPeers(caller_ip, caller_port)) do
		p.remote_no_return:setRooms(rooms)
	end
end

---@param room_id integer
---@param caller_ip string
---@param caller_port integer
function Multiplayer:pushRoomUsers(room_id, caller_ip, caller_port)
	local room_users = self.multiplayer_repo:getRoomUsers(room_id)
	for _, p in self:iterRoomPeers(room_id, caller_ip, caller_port) do
		p.remote_no_return:setRoomUsers(room_users)
	end
end

---@param room_id integer
---@param room sea.Room|sea.RoomUpdate
---@param caller_ip string
---@param caller_port integer
function Multiplayer:syncRoomParts(room_id, room, caller_ip, caller_port)
	for _, p in self:iterRoomPeers(room_id, caller_ip, caller_port) do
		if room.rules then
			p.remote_no_return:syncRules()
		end
		if room.chartmeta_key then
			p.remote_no_return:syncChart()
		end
		if room.replay_base then
			p.remote_no_return:syncReplayBase()
		end
	end
end

---@param user sea.User
---@param room_values sea.Room
---@param caller_ip string
---@param caller_port integer
---@return integer?
---@return string?
function Multiplayer:createRoom(user, room_values, caller_ip, caller_port)
	if not self.multiplayer_access:canCreateRoom(user) then
		return nil, "not allowed"
	end

	room_values.host_user_id = user.id

	local room = self.multiplayer_repo:createRoom(room_values)
	self:pushRooms(caller_ip, caller_port)

	self:joinRoom(user, room.id, room.password, caller_ip, caller_port)

	return room.id
end

---@param user sea.User
---@param room_id integer
---@param room_values sea.RoomUpdate
---@param caller_ip string
---@param caller_port integer
---@return true?
---@return string?
function Multiplayer:updateRoom(user, room_id, room_values, caller_ip, caller_port)
	local room = self.multiplayer_repo:getRoom(room_id)
	if not room then
		return nil, "not found"
	end

	if not self.multiplayer_access:canUpdateRoom(user, room) then
		return nil, "not allowed"
	end

	room_values.id = room_id

	self.multiplayer_repo:updateRoom(room_values)
	self:pushRooms(caller_ip, caller_port)

	self:syncRoomParts(room_id, room_values, caller_ip, caller_port)

	return true
end

---@param user sea.User
---@param room_id integer
---@param password string
---@param caller_ip string
---@param caller_port integer
---@return true?
---@return string?
function Multiplayer:joinRoom(user, room_id, password, caller_ip, caller_port)
	local room = self.multiplayer_repo:getRoom(room_id)
	if not room then
		return nil, "not found"
	end

	if not self.multiplayer_access:canJoinRoom(user, room) then
		return nil, "not allowed"
	end

	local room_user = self.multiplayer_repo:getRoomUserByUserId(user.id)
	if room_user then
		return nil, "is in a room"
	end

	if room.password ~= password then
		return nil, "invalid password"
	end

	room_user = RoomUser(room.id, user.id)
	room_user = self.multiplayer_repo:createRoomUser(room_user)

	self:pushRoomUsers(room_id, caller_ip, caller_port)
	self:syncRoomParts(room_id, room, caller_ip, caller_port)

	return true
end

---@param user sea.User
---@param room_id integer
---@param target_user_id integer
---@param caller_ip string
---@param caller_port integer
---@return true?
---@return string?
function Multiplayer:kickUser(user, room_id, target_user_id, caller_ip, caller_port)
	local room = self.multiplayer_repo:getRoom(room_id)
	if not room then
		return nil, "not found"
	end

	if not self.multiplayer_access:canKickUser(user, room, target_user_id) then
		return nil, "not allowed"
	end

	local room_user = self.multiplayer_repo:deleteRoomUser(room_id, target_user_id)
	if not room_user then
		return nil, "not found"
	end

	local room_users = self.multiplayer_repo:getRoomUsers(room_id)

	if room.host_user_id == target_user_id and room_users[1] then
		room.host_user_id = room_users[1].user_id
		self.multiplayer_repo:updateRoom(room)
		self:pushRooms(caller_ip, caller_port)
		self:pushRoomUsers(room_id, caller_ip, caller_port)
	elseif #room_users == 0 then
		self.multiplayer_repo:deleteRoom(room_id)
		self:pushRooms(caller_ip, caller_port)
		self:pushRoomUsers(room_id, caller_ip, caller_port)
	end

	local peer = self:getPeerByUserId(target_user_id, caller_ip, caller_port)
	if peer then
		peer.remote_no_return:setRoomUsers({})
	end

	return true
end

---@param user sea.User
---@return integer?
function Multiplayer:getRoomId(user)
	if user:isAnon() then
		return
	end
	local room_user = self.multiplayer_repo:getRoomUserByUserId(user.id)
	if not room_user then
		return
	end
	return room_user.room_id
end

---@param user sea.User
---@param caller_ip string
---@param caller_port integer
---@return true?
---@return string?
function Multiplayer:leaveRoom(user, caller_ip, caller_port)
	if user:isAnon() then
		return
	end

	local room_id = self:getRoomId(user)
	if not room_id then
		return nil, "is not in a room"
	end

	return self:kickUser(user, room_id, user.id, caller_ip, caller_port)
end

---@return sea.Room?
function Multiplayer:getCurrentRoom(user)
	local id = self:getRoomId(user)
	if id then
		return self:getRoom(id)
	end
end

---@param user sea.User
---@param room_id integer
---@param msg string
---@param caller_ip string
---@param caller_port integer
function Multiplayer:sendMessage(user, room_id, msg, caller_ip, caller_port)
	msg = ("%s: %s"):format(user.name, msg)

	for _, p in self:iterRoomPeers(room_id, caller_ip, caller_port) do
		p.remote_no_return:addMessage(msg)
	end
end

---@param user sea.User
---@param msg string
---@param caller_ip string
---@param caller_port integer
function Multiplayer:sendLocalMessage(user, msg, caller_ip, caller_port)
	local room_id = self:getRoomId(user)
	if not room_id then
		return
	end
	self:sendMessage(user, room_id, msg, caller_ip, caller_port)
end

---@param user sea.User
---@param room_values sea.RoomUpdate
---@param caller_ip string
---@param caller_port integer
---@return boolean?
---@return string?
function Multiplayer:updateLocalRoom(user, room_values, caller_ip, caller_port)
	local room_id = self:getRoomId(user)
	if not room_id then
		return
	end
	return self:updateRoom(user, room_id, room_values, caller_ip, caller_port)
end

---@param user sea.User
---@param target_user_id integer
---@param caller_ip string
---@param caller_port integer
function Multiplayer:kickLocalUser(user, target_user_id, caller_ip, caller_port)
	local room_id = self:getRoomId(user)
	if not room_id then
		return
	end
	self:kickUser(user, room_id, target_user_id, caller_ip, caller_port)
end

---@param user sea.User
---@param caller_ip string
---@param caller_port integer
function Multiplayer:switchReady(user, caller_ip, caller_port)
	local room_user = self.multiplayer_repo:getRoomUserByUserId(user.id)
	if not room_user then
		return
	end

	room_user.is_ready = not room_user.is_ready
	self.multiplayer_repo:updateRoomUser(room_user)

	self:pushRoomUsers(room_user.room_id, caller_ip, caller_port)
end

---@param user sea.User
---@param found boolean
---@param caller_ip string
---@param caller_port integer
function Multiplayer:setChartFound(user, found, caller_ip, caller_port)
	local room_user = self.multiplayer_repo:getRoomUserByUserId(user.id)
	if not room_user then
		return
	end

	room_user.chart_found = found
	self.multiplayer_repo:updateRoomUser(room_user)

	self:pushRoomUsers(room_user.room_id, caller_ip, caller_port)
end

---@param user sea.User
---@param chartplay_computed sea.ChartplayComputed
---@param caller_ip string
---@param caller_port integer
function Multiplayer:setChartplayComputed(user, chartplay_computed, caller_ip, caller_port)
	local room_user = self.multiplayer_repo:getRoomUserByUserId(user.id)
	if not room_user then
		return
	end

	room_user.chartplay_computed = chartplay_computed
	self.multiplayer_repo:updateRoomUser(room_user)

	self:pushRoomUsers(room_user.room_id, caller_ip, caller_port)
end

---@param user sea.User
---@param caller_ip string
---@param caller_port integer
function Multiplayer:startLocalMatch(user, caller_ip, caller_port)
	local room_id = self:getRoomId(user)
	if not room_id then
		return
	end

	for _, p in self:iterRoomPeers(room_id, caller_ip, caller_port) do
		p.remote_no_return:startMatch()
	end
end

return Multiplayer
