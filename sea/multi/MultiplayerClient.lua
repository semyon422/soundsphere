local class = require("class")
local icc_co = require("icc.co")

---@class sea.MultiplayerClient
---@operator call: sea.MultiplayerClient
local MultiplayerClient = class()

---@param server_remote sea.MultiplayerServerRemote
function MultiplayerClient:new(server_remote)
	self.server_remote = server_remote

	---@type sea.User[]
	self.users = {}
	---@type sea.Room[]
	self.rooms = {}
	---@type sea.RoomUser[]
	self.room_users = {}

	---@type string[]
	self.room_messages = {}
end

---@param key any
---@param value any
function MultiplayerClient:set(key, value)
	self[key] = value ---@diagnostic disable-line

	-- local room = value
	-- if key ~= "room" or self:isHost() then
	-- 	return
	-- end

	-- -- self:findNotechart() -- mp controller
	-- if not room.is_free_modifiers then
	-- 	self.replayBase.modifiers = room.modifiers
	-- end
	-- if not room.is_free_const then
	-- 	self.replayBase.const = room.const
	-- end
	-- if not room.is_free_rate then
	-- 	self.replayBase.rate = room.rate
	-- end
end

function MultiplayerClient:pullUserAsync()
	print(self.server_remote)
	self.user = self.server_remote:getUser()
	print("USER", self.user)
end

function MultiplayerClient:refreshAsync()
	self:pullRoomAsync()
	self:pullUsersAsync()
	self:pullRoomsAsync()
end

---@param msg string
function MultiplayerClient:addMessage(msg)
	table.insert(self.room_messages, msg)
end

function MultiplayerClient:pullRoomAsync()
	self.room = self.server_remote:getCurrentRoom()
end

function MultiplayerClient:pullUsersAsync()
	self.users = self.server_remote:getUsers()
end

function MultiplayerClient:pullRoomsAsync()
	self.rooms = self.server_remote:getRooms()
end

---@return boolean
function MultiplayerClient:isHost()
	local room = self.room
	if not room then
		return false
	end
	return room.host_user_id == self.user.id
end

function MultiplayerClient:switchReadyAsync()
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

function MultiplayerClient:stopMatchAsync()
	self.server_remote.mp_room:stopMatch()
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
	self.room.rules = rules
	self.server_remote.mp_room:setRules(rules)
	self:pullRoomAsync()
end

---@param name string
---@param password string
function MultiplayerClient:createRoomAsync(name, password)
	local room, err = self.server_remote:createRoom(name, password)
	if not room then
		print(err)
		return
	end
	self.room = room
	-- self.server_remote.mp_room:setChartmetaKey()
	-- self.server_remote.mp_room:setReplayBase()
	-- self:pushNotechart()
end

---@param id integer
---@param password string
function MultiplayerClient:joinRoomAsync(id, password)
	local ok, err = self.server_remote:joinRoom(id, password)
	if not ok then
		print(err)
		return
	end
	self:pullRoomAsync()
end

function MultiplayerClient:leaveRoomAsync()
	self.server_remote:leaveRoom()
	self.room = nil
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
