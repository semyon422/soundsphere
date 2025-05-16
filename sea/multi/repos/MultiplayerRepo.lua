local class = require("class")

---@class sea.MultiplayerRepo
---@operator call: sea.MultiplayerRepo
local MultiplayerRepo = class()

---@param models rdb.Models
function MultiplayerRepo:new(models)
	self.models = models
end

---@return sea.Room[]
function MultiplayerRepo:getRooms()
	return self.models.rooms:select()
end

---@param id integer
---@return sea.Room?
function MultiplayerRepo:getRoom(id)
	return self.models.rooms:find({id = assert(id)})
end

---@param room sea.Room
---@return sea.Room
function MultiplayerRepo:createRoom(room)
	return self.models.rooms:create(room)
end

---@param room sea.Room
---@return sea.Room?
function MultiplayerRepo:updateRoom(room)
	return self.models.rooms:update(room, {id = assert(room.id)})[1]
end

---@param id integer
---@return sea.Room?
function MultiplayerRepo:deleteRoom(id)
	return self.models.rooms:delete({
		id = assert(id),
	})[1]
end

---@param room_id integer
---@param user_id integer
---@return sea.RoomUser?
function MultiplayerRepo:getRoomUser(room_id, user_id)
	return self.models.room_users:find({
		room_id = assert(room_id),
		user_id = assert(user_id),
	})
end

---@param room_id integer
---@return sea.RoomUser[]
function MultiplayerRepo:getRoomUsers(room_id)
	return self.models.room_users:select({
		room_id = assert(room_id),
	})
end

---@param user_id integer
---@return sea.RoomUser?
function MultiplayerRepo:getRoomUserByUserId(user_id)
	return self.models.room_users:find({
		user_id = assert(user_id),
	})
end

---@param room_user sea.RoomUser
---@return sea.RoomUser
function MultiplayerRepo:createRoomUser(room_user)
	return self.models.room_users:create(room_user)
end

---@param room_user sea.RoomUser
---@return sea.RoomUser
function MultiplayerRepo:updateRoomUser(room_user)
	return self.models.room_users:update(room_user, {id = assert(room_user.id)})[1]
end

---@param room_id integer
---@param user_id integer
---@return sea.RoomUser?
function MultiplayerRepo:deleteRoomUser(room_id, user_id)
	return self.models.room_users:delete({
		room_id = assert(room_id),
		user_id = assert(user_id),
	})[1]
end

return MultiplayerRepo
