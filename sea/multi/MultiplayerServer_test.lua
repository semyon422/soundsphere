local MultiplayerServer = require("sea.multi.MultiplayerServer")
local MultiplayerClient = require("sea.multi.MultiplayerClient")
local MultiplayerClientRemote = require("sea.multi.remotes.MultiplayerClientRemote")
local MultiplayerRepo = require("sea.multi.repos.MultiplayerRepo")
local Peers = require("sea.multi.Peers")
local Peer = require("sea.multi.Peer")
local User = require("sea.access.User")
local LjsqliteDatabase = require("rdb.db.LjsqliteDatabase")
local MultiplayerDatabase = require("sea.storage.server.MultiplayerDatabase")
local RoomRules = require("sea.multi.RoomRules")
local Room = require("sea.multi.Room")
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

	return {
		db = db,
		multiplayer_repo = multiplayer_repo,
		server = server,
		peers = peers,
	}
end

local function create_peer(ctx, id)
	local client = MultiplayerClient()

	local peer = Peer()
	peer.user = User()
	peer.user.id = id
	peer.remote = MultiplayerClientRemote(client)

	ctx.peers:add("peer_" .. id, peer)

	return peer, client
end

---@param t testing.T
function test.setAll(t)
	local ctx = create_test_ctx()

	local peer_1, client_1 = create_peer(ctx, 1)
	local peer_2, client_2 = create_peer(ctx, 2)

	ctx.server:setAll("key", "value")

	t:eq(client_1.key, "value")
	t:eq(client_2.key, "value")
end

---@param t testing.T
function test.create_join_leave_room(t)
	local ctx = create_test_ctx()

	local peer_1, client_1 = create_peer(ctx, 1)
	local peer_2, client_2 = create_peer(ctx, 2)

	local room, err = ctx.server:createRoom(peer_1.user, "Room 1", "password")
	if not t:assert(room, err) then
		return
	end
	---@cast room -?

	t:eq(room.host_user_id, 1)
	t:eq(ctx.server:getRoomId(peer_1.user), room.id)

	t:tdeq(client_1.rooms, {{
		id = 1, host_user_id = 1, name = "Room 1",
		rules = RoomRules(), chartmeta_key = ChartmetaKey(), replay_base = ReplayBase(),
	}})
	t:tdeq(client_1.room_users, {{id = 1, room_id = 1, user_id = 1}})

	t:assert(ctx.server:joinRoom(peer_2.user, room.id, "password"))

	t:tdeq(client_1.room_users, {
		{id = 1, room_id = 1, user_id = 1},
		{id = 2, room_id = 1, user_id = 2},
	})

	t:assert(ctx.server:leaveRoom(peer_1.user))
	t:eq(ctx.server:getRoomId(peer_1.user), nil)

	t:tdeq(client_1.rooms, {{
		id = 1, host_user_id = 2, name = "Room 1",
		rules = RoomRules(), chartmeta_key = ChartmetaKey(), replay_base = ReplayBase(),
	}})
	t:tdeq(client_1.room_users, {{id = 2, room_id = 1, user_id = 2}})
end

---@param t testing.T
function test.update_room(t)
	local ctx = create_test_ctx()

	local peer_1, client_1 = create_peer(ctx, 1)

	local room, err = ctx.server:createRoom(peer_1.user, "Room 1", "password")
	if not t:assert(room, err) then
		return
	end
	---@cast room -?

	t:tdeq(client_1.rooms, {{
		id = 1, host_user_id = 1, name = "Room 1",
		rules = RoomRules(), chartmeta_key = ChartmetaKey(), replay_base = ReplayBase(),
	}})

	local room_values = Room()
	room_values.name = "Room 2"
	room_values.password = "password 2"

	room, err = ctx.server:updateRoom(peer_1.user, room.id, room_values)

	t:tdeq(client_1.rooms, {{
		id = 1, host_user_id = 1, name = "Room 2",
		rules = RoomRules(), chartmeta_key = ChartmetaKey(), replay_base = ReplayBase(),
	}})
end

return test
