local class = require("class")
local icc_co = require("icc.co")
local Room = require("sea.multi.Room")
local RoomUpdate = require("sea.multi.RoomUpdate")

---@class sea.MultiplayerClient
---@operator call: sea.MultiplayerClient
local MultiplayerClient = class()

---@param server_remote sea.MultiplayerServerRemote
---@param replay_base sea.ReplayBase
function MultiplayerClient:new(server_remote, replay_base)
	self.server_remote = server_remote
	self.replay_base = replay_base

	---@type sea.User[]
	self.users = {}
	---@type sea.Room[]
	self.rooms = {}
	---@type sea.RoomUser[]
	self.room_users = {}

	---@type string[]
	self.room_messages = {}

	---@type integer?
	self.user_id = nil
	---@type integer?
	self.room_id = nil
end

---@param rooms sea.Room[]
function MultiplayerClient:setRooms(rooms)
	self.rooms = rooms
end

---@param room_users sea.RoomUser[]
function MultiplayerClient:setRoomUsers(room_users)
	self.room_users = room_users
	if #room_users == 0 then
		self.room_id = nil
		return
	end
	self.room_id = room_users[1].room_id
end

---@param users sea.User[]
function MultiplayerClient:setUsers(users)
	self.users = users
end

---@param msg string
function MultiplayerClient:addMessage(msg)
	table.insert(self.room_messages, msg)
end

function MultiplayerClient:syncRules()
end

function MultiplayerClient:syncChart()
	local room = self:getMyRoom()
	if not room then
		return
	end

	local rules = room.rules
	if not rules.chart then
		-- self.selectModel:setConfig(mp_model.chartview)  -- mp controller
	end
end

function MultiplayerClient:syncReplayBase()
	local room = self:getMyRoom()
	if not room then
		return
	end

	local rules = room.rules
	if not rules.modifiers then
		self.replay_base.modifiers = room.replay_base.modifiers
	end
	if not rules.const then
		self.replay_base.const = room.replay_base.const
	end
	if not rules.rate then
		self.replay_base.rate = room.replay_base.rate
	end
end

function MultiplayerClient:refreshAsync()

end

---@return boolean
function MultiplayerClient:isLoggedIn()
	return not not self.user_id
end

---@param user_name string
function MultiplayerClient:loginOffline(user_name)
	self.user_id = self.server_remote:loginOffline(user_name)
end

---@param id integer
---@return sea.Room?
function MultiplayerClient:getRoom(id)
	for _, room in ipairs(self.rooms) do
		if room.id == id then
			return room
		end
	end
end

---@return sea.Room?
function MultiplayerClient:getMyRoom()
	if not self.room_id then
		return
	end
	return self:getRoom(self.room_id)
end

---@return boolean
function MultiplayerClient:isInRoom()
	return not not self.room_id
end

---@param id integer
---@return sea.User?
function MultiplayerClient:getUser(id)
	for _, user in ipairs(self.users) do
		if user.id == id then
			return user
		end
	end
end

---@param user_id integer
---@return sea.RoomUser?
function MultiplayerClient:getRoomUser(user_id)
	for _, room_user in ipairs(self.room_users) do
		if room_user.user_id == user_id then
			return room_user
		end
	end
end

---@return sea.RoomUser?
function MultiplayerClient:getMyRoomUser()
	if not self.user_id then
		return
	end
	return self:getRoomUser(self.user_id)
end

---@return boolean
function MultiplayerClient:isHost()
	local room = self:getMyRoom()
	if not room then
		return false
	end
	return room.host_user_id == self.user_id
end

function MultiplayerClient:switchReadyAsync()
	local room_user = self:getRoomUser(self.user_id)
	if room_user then
		room_user.is_ready = not room_user.is_ready
	end
	self.server_remote.mp_user:switchReady()
end

---@param is_playing boolean
function MultiplayerClient:setPlayingAsync(is_playing)
	self.is_playing = is_playing
	self.server_remote.mp_user:setPlaying(is_playing)
end

---@param msg string
function MultiplayerClient:sendMessageAsync(msg)
	self.server_remote.mp_user:sendMessage(msg)
end

function MultiplayerClient:startMatchAsync()
	self.server_remote.mp_room:startMatch()
end

function MultiplayerClient:startClientMatch() -- !!!
	if self.is_playing then
		-- if self.is_playing or not self.chartview then -- !!!
		return
	end

	self:setPlaying(true)

	local room = self:getMyRoom()
	if not room or not self:isHost() then
		return
	end

	self:syncRules()
	self:syncChart()
	self:syncReplayBase()
end

function MultiplayerClient:stopMatchAsync()
	self.server_remote.mp_room:stopMatch()
end

function MultiplayerClient:stopClientMatch()
	if self.is_playing then
		self:setPlaying(false)
	end
end

---@param user_id integer
function MultiplayerClient:setHostAsync(user_id)
	self.server_remote.mp_room:setHost(user_id)
end

---@param user_id integer
function MultiplayerClient:kickUserAsync(user_id)
	self.server_remote.mp_room:kickUser(user_id)
end

---@param rules sea.RoomRules
function MultiplayerClient:setRulesAsync(rules)
	local room = assert(self:getMyRoom())
	room.rules = rules

	local room_values = RoomUpdate()
	room_values.rules = rules

	self.server_remote.mp_room:updateRoom(room_values)
end

---@param name string
---@param password string
---@param chartmeta_key sea.ChartmetaKey
function MultiplayerClient:createRoomAsync(name, password, chartmeta_key)
	local room_values = Room()
	room_values.name = name
	room_values.password = password
	room_values.replay_base = self.replay_base
	room_values.chartmeta_key = chartmeta_key

	local room_id, err = self.server_remote:createRoom(room_values)
	if not room_id then
		print(err)
		return
	end
	self.room_id = room_id
end

---@param id integer
---@param password string
function MultiplayerClient:joinRoomAsync(id, password)
	local ok, err = self.server_remote:joinRoom(id, password)
	if not ok then
		print(err)
	end
end

function MultiplayerClient:leaveRoomAsync()
	self.server_remote:leaveRoom()
	self.room_id = nil
	self.room_messages = {}
end

MultiplayerClient.switchReady = icc_co.callwrap(MultiplayerClient.switchReadyAsync)
MultiplayerClient.setPlaying = icc_co.callwrap(MultiplayerClient.setPlayingAsync)
MultiplayerClient.sendMessage = icc_co.callwrap(MultiplayerClient.sendMessageAsync)
MultiplayerClient.startMatch = icc_co.callwrap(MultiplayerClient.startMatchAsync)
MultiplayerClient.stopMatch = icc_co.callwrap(MultiplayerClient.stopMatchAsync)
MultiplayerClient.setHost = icc_co.callwrap(MultiplayerClient.setHostAsync)
MultiplayerClient.kickUser = icc_co.callwrap(MultiplayerClient.kickUserAsync)
MultiplayerClient.setRules = icc_co.callwrap(MultiplayerClient.setRulesAsync)
MultiplayerClient.createRoom = icc_co.callwrap(MultiplayerClient.createRoomAsync)
MultiplayerClient.joinRoom = icc_co.callwrap(MultiplayerClient.joinRoomAsync)
MultiplayerClient.leaveRoom = icc_co.callwrap(MultiplayerClient.leaveRoomAsync)

return MultiplayerClient
