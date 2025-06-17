local class = require("class")
local Room = require("sea.multi.Room")
local RoomUpdate = require("sea.multi.RoomUpdate")
local RoomUser = require("sea.multi.RoomUser")
local MultiplayerAccess = require("sea.multi.access.MultiplayerAccess")

---@class sea.MultiplayerServer
---@operator call: sea.MultiplayerServer
local MultiplayerServer = class()

---@param multiplayer_repo sea.MultiplayerRepo
---@param peers sea.Peers
function MultiplayerServer:new(multiplayer_repo, peers)
	self.multiplayer_repo = multiplayer_repo
	self.peers = peers
	self.multiplayer_access = MultiplayerAccess()
end

function MultiplayerServer:iterPeers()
	return self.peers:iter()
end

---@param user sea.User
---@param user_name string
---@return integer
function MultiplayerServer:loginOffline(user, user_name)
	user.id = -math.random(1, 1e9)
	user.name = ("%s (%s)"):format(user_name, -user.id)
	self:pushUsers()
	return user.id
end

function MultiplayerServer:update()

end

---@param peer sea.Peer
function MultiplayerServer:connected(peer)
	self:pushUsers()
	peer.remote_no_return:setRooms(self:getRooms())
end

---@param peer sea.Peer
function MultiplayerServer:disconnected(peer)
	self:leaveRoom(peer.user)
	self:pushUsers()
end

---@return sea.User[]
function MultiplayerServer:getUsers()
	---@type sea.User[]
	local users = {}
	for _, p in self.peers:iter() do
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
---@return sea.Peer?
function MultiplayerServer:getPeerByUserId(user_id)
	for _, p in self.peers:iter() do
		if p.user.id == user_id then
			return p
		end
	end
end

---@param room_id integer
function MultiplayerServer:iterRoomPeers(room_id)
	local room_users = self.multiplayer_repo:getRoomUsers(room_id)

	---@type {[integer]: true}
	local user_ids = {}
	for _, room_user in ipairs(room_users) do
		user_ids[room_user.user_id] = true
	end

	---@type sea.Peer[]
	local peers = {}
	for _, p in self:iterPeers() do
		if user_ids[p.user.id] then
			table.insert(peers, p)
		end
	end

	return ipairs(peers)
end

---@return sea.Room[]
function MultiplayerServer:getRooms()
	local rooms = self.multiplayer_repo:getRooms()
	for _, room in ipairs(rooms) do
		room.password = nil
	end
	return rooms
end

---@param id integer
---@return sea.Room?
function MultiplayerServer:getRoom(id)
	return self.multiplayer_repo:getRoom(id)
end

function MultiplayerServer:pushUsers()
	local users = self:getUsers()
	for _, p in self.peers:iter() do
		p.remote_no_return:setUsers(users)
	end
end

function MultiplayerServer:pushRooms()
	local rooms = self:getRooms()
	for _, p in self.peers:iter() do
		p.remote_no_return:setRooms(rooms)
	end
end

---@param room_id integer
function MultiplayerServer:pushRoomUsers(room_id)
	local room_users = self.multiplayer_repo:getRoomUsers(room_id)
	for _, p in self:iterRoomPeers(room_id) do
		p.remote_no_return:setRoomUsers(room_users)
	end
end

---@param room_id integer
---@param room sea.Room|sea.RoomUpdate
function MultiplayerServer:syncRoomParts(room_id, room)
	for _, p in self:iterRoomPeers(room_id) do
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
---@return integer?
---@return string?
function MultiplayerServer:createRoom(user, room_values)
	if not self.multiplayer_access:canCreateRoom(user) then
		return nil, "not allowed"
	end

	room_values.host_user_id = user.id

	local room = self.multiplayer_repo:createRoom(room_values)
	self:pushRooms()

	self:joinRoom(user, room.id, room.password)

	return room.id
end

---@param user sea.User
---@param room_id integer
---@param room_values sea.RoomUpdate
---@return true?
---@return string?
function MultiplayerServer:updateRoom(user, room_id, room_values)
	local room = self.multiplayer_repo:getRoom(room_id)
	if not room then
		return nil, "not found"
	end

	if not self.multiplayer_access:canUpdateRoom(user, room) then
		return nil, "not allowed"
	end

	room_values.id = room_id

	self.multiplayer_repo:updateRoom(room_values)
	self:pushRooms()

	self:syncRoomParts(room_id, room_values)

	return true
end

---@param room_id integer
---@param password string
---@return true?
---@return string?
function MultiplayerServer:joinRoom(user, room_id, password)
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

	self:pushRoomUsers(room_id)
	self:syncRoomParts(room_id, room)

	return true
end

---@param user sea.User
---@param room_id integer
---@param target_user_id integer
---@return true?
---@return string?
function MultiplayerServer:kickUser(user, room_id, target_user_id)
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
		self:pushRooms()
		self:pushRoomUsers(room_id)
	elseif #room_users == 0 then
		self.multiplayer_repo:deleteRoom(room_id)
		self:pushRooms()
		self:pushRoomUsers(room_id)
	end

	local peer = self:getPeerByUserId(target_user_id)
	if peer then
		peer.remote_no_return:setRoomUsers({})
	end

	return true
end

---@param user sea.User
---@return integer?
function MultiplayerServer:getRoomId(user)
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
---@return true?
---@return string?
function MultiplayerServer:leaveRoom(user)
	if user:isAnon() then
		return
	end

	local room_id = self:getRoomId(user)
	if not room_id then
		return nil, "is not in a room"
	end

	return self:kickUser(user, room_id, user.id)
end

---@return sea.Room?
function MultiplayerServer:getCurrentRoom(user)
	local id = self:getRoomId(user)
	if id then
		return self:getRoom(id)
	end
end

---@param user sea.User
---@param room_id integer
---@param msg string
function MultiplayerServer:sendMessage(user, room_id, msg)
	msg = ("%s: %s"):format(user.name, msg)

	for _, p in self:iterRoomPeers(room_id) do
		p.remote_no_return:addMessage(msg)
	end
end

---@param user sea.User
---@param msg string
function MultiplayerServer:sendLocalMessage(user, msg)
	local room_id = self:getRoomId(user)
	if not room_id then
		return
	end
	self:sendMessage(user, room_id, msg)
end

---@param user sea.User
---@param room_values sea.RoomUpdate
---@return boolean?
---@return string?
function MultiplayerServer:updateLocalRoom(user, room_values)
	local room_id = self:getRoomId(user)
	if not room_id then
		return
	end
	return self:updateRoom(user, room_id, room_values)
end

---@param user sea.User
---@param target_user_id integer
function MultiplayerServer:kickLocalUser(user, target_user_id)
	local room_id = self:getRoomId(user)
	if not room_id then
		return
	end
	self:kickUser(user, room_id, target_user_id)
end

---@param user sea.User
function MultiplayerServer:switchReady(user)
	local room_user = self.multiplayer_repo:getRoomUserByUserId(user.id)
	if not room_user then
		return
	end

	room_user.is_ready = not room_user.is_ready
	self.multiplayer_repo:updateRoomUser(room_user)

	self:pushRoomUsers(room_user.room_id)
end

---@param user sea.User
---@param found boolean
function MultiplayerServer:setChartFound(user, found)
	local room_user = self.multiplayer_repo:getRoomUserByUserId(user.id)
	if not room_user then
		return
	end

	room_user.chart_found = found
	self.multiplayer_repo:updateRoomUser(room_user)

	self:pushRoomUsers(room_user.room_id)
end

---@param user sea.User
---@param chartplay_computed sea.ChartplayComputed
function MultiplayerServer:setChartplayComputed(user, chartplay_computed)
	local room_user = self.multiplayer_repo:getRoomUserByUserId(user.id)
	if not room_user then
		return
	end

	room_user.chartplay_computed = chartplay_computed
	self.multiplayer_repo:updateRoomUser(room_user)

	self:pushRoomUsers(room_user.room_id)
end

---@param user sea.User
function MultiplayerServer:startLocalMatch(user)
	local room_id = self:getRoomId(user)
	if not room_id then
		return
	end

	for _, p in self:iterRoomPeers(room_id) do
		p.remote_no_return:startMatch()
	end
end

return MultiplayerServer
