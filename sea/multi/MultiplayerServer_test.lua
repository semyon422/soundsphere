local MultiplayerServer = require("sea.multi.MultiplayerServer")
local MultiplayerClient = require("sea.multi.MultiplayerClient")
local MultiplayerClientRemote = require("sea.multi.remotes.MultiplayerClientRemote")
local MultiplayerServerRemote = require("sea.multi.remotes.MultiplayerServerRemote")
local MultiplayerRepo = require("sea.multi.repos.MultiplayerRepo")
local Peers = require("sea.multi.Peers")
local Peer = require("sea.multi.Peer")
local User = require("sea.access.User")
local LjsqliteDatabase = require("rdb.db.LjsqliteDatabase")
local MultiplayerDatabase = require("sea.storage.server.MultiplayerDatabase")
local RoomRules = require("sea.multi.RoomRules")
local Room = require("sea.multi.Room")
local RoomUpdate = require("sea.multi.RoomUpdate")
local RoomUser = require("sea.multi.RoomUser")
local ChartmetaKey = require("sea.chart.ChartmetaKey")
local ReplayBase = require("sea.replays.ReplayBase")

local test = {}

local function create_test_ctx()
	local db = MultiplayerDatabase(LjsqliteDatabase())
	db.path = ":memory:"
	db:open()

	-- db.orm:debug(true)

	local models = db.models

	local multiplayer_repo = MultiplayerRepo(models)
	local peers = Peers()

	local server = MultiplayerServer(multiplayer_repo, peers)
	local server_remote = MultiplayerServerRemote(server)

	return {
		db = db,
		multiplayer_repo = multiplayer_repo,
		server = server,
		server_remote = server_remote,
		peers = peers,
	}
end

local function create_peer(ctx, id)
	local client = MultiplayerClient(ctx.server_remote, ReplayBase())

	local peer = Peer()
	peer.user = User()
	peer.user.id = id
	peer.remote = MultiplayerClientRemote(client)

	ctx.peers:add("peer_" .. id, peer)

	return peer, client
end

---@param t testing.T
function test.pushUsers(t)
	local ctx = create_test_ctx()

	local peer_1, client_1 = create_peer(ctx, 1)
	local peer_2, client_2 = create_peer(ctx, 2)

	ctx.server:pushUsers()

	t:tdeq(client_1.users, {peer_1.user, peer_2.user})
	t:tdeq(client_2.users, {peer_1.user, peer_2.user})
end

---@param t testing.T
function test.create_join_leave_room(t)
	local ctx = create_test_ctx()

	local peer_1, client_1 = create_peer(ctx, 1)
	local peer_2, client_2 = create_peer(ctx, 2)

	local room_values = Room()
	room_values.name = "Room 1"
	room_values.password = "password"

	local room_id, err = ctx.server:createRoom(peer_1.user, room_values)
	if not t:assert(room_id, err) then
		return
	end
	---@cast room_id -?

	local room = assert(client_1.rooms[1])

	t:eq(room.host_user_id, 1)
	t:eq(ctx.server:getRoomId(peer_1.user), room.id)

	t:tdeq(client_1.rooms, {{
		id = 1, host_user_id = 1, name = "Room 1",
		rules = RoomRules(), chartmeta_key = ChartmetaKey(), replay_base = ReplayBase(),
	}})

	local room_user_1 = RoomUser(1, 1)
	room_user_1.id = 1
	t:tdeq(client_1.room_users, {room_user_1})
	t:tdeq(client_2.room_users, {})

	t:assert(ctx.server:joinRoom(peer_2.user, room.id, "password"))

	local room_user_2 = RoomUser(1, 2)
	room_user_2.id = 2
	t:tdeq(client_1.room_users, {room_user_1, room_user_2})
	t:tdeq(client_2.room_users, {room_user_1, room_user_2})

	t:assert(ctx.server:leaveRoom(peer_1.user))
	t:eq(ctx.server:getRoomId(peer_1.user), nil)

	t:tdeq(client_1.rooms, {{
		id = 1, host_user_id = 2, name = "Room 1",
		rules = RoomRules(), chartmeta_key = ChartmetaKey(), replay_base = ReplayBase(),
	}})
	t:tdeq(client_1.room_users, {})
	t:tdeq(client_2.room_users, {room_user_2})
end

---@param t testing.T
function test.update_room(t)
	local ctx = create_test_ctx()

	local peer_1, client_1 = create_peer(ctx, 1)

	local room_values = Room()
	room_values.name = "Room 1"
	room_values.password = "password"

	local room_id, err = ctx.server:createRoom(peer_1.user, room_values)
	if not t:assert(room_id, err) then
		return
	end
	---@cast room_id -?

	t:tdeq(client_1.rooms, {{
		id = 1, host_user_id = 1, name = "Room 1",
		rules = RoomRules(), chartmeta_key = ChartmetaKey(), replay_base = ReplayBase(),
	}})

	local room_values = RoomUpdate()
	room_values.name = "Room 2"
	room_values.password = "password 2"

	local ok, err = ctx.server:updateRoom(peer_1.user, room_id, room_values)
	if not t:assert(ok, err) then
		return
	end

	t:tdeq(client_1.rooms, {{
		id = 1, host_user_id = 1, name = "Room 2",
		rules = RoomRules(), chartmeta_key = ChartmetaKey(), replay_base = ReplayBase(),
	}})
end

return test
