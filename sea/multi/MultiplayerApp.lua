local class = require("class")
local icc_co = require("icc.co")

local TaskHandler = require("icc.TaskHandler")
local RemoteHandler = require("icc.RemoteHandler")
local Remote = require("icc.Remote")

local User = require("sea.access.User")
local Session = require("sea.access.Session")

local Peers = require("sea.multi.Peers")
local Peer = require("sea.multi.Peer")

local MultiplayerServer = require("sea.multi.MultiplayerServer")
local MultiplayerServerRemote = require("sea.multi.remotes.MultiplayerServerRemote")

local LjsqliteDatabase = require("rdb.db.LjsqliteDatabase")
local MultiplayerDatabase = require("sea.storage.server.MultiplayerDatabase")
local MultiplayerRepo = require("sea.multi.repos.MultiplayerRepo")

local MultiplayerClientRemoteValidation = require("sea.multi.remotes.MultiplayerClientRemoteValidation")

local whitelist = require("sea.multi.remotes.whitelist")

---@class sea.MultiplayerApp
---@operator call: sea.MultiplayerApp
local MultiplayerApp = class()

function MultiplayerApp:new()
	self.mp_db = MultiplayerDatabase(LjsqliteDatabase())
	self.mp_db:open()

	self.multiplayer_repo = MultiplayerRepo(self.mp_db.models)

	self.peers = Peers()
	self.server = MultiplayerServer(self.multiplayer_repo, self.peers)

	self.remote_handler = RemoteHandler(MultiplayerServerRemote(self.server), whitelist)

	self.task_handler = TaskHandler(self.remote_handler)
	self.task_handler.timeout = 60
end

---@param peer_id sea.PeerId
---@param icc_peer icc.IPeer
---@param msg icc.Message
function MultiplayerApp:handle_msg(peer_id, icc_peer, msg)
	local peers = self.peers
	local peer = peers:get(peer_id)
	if not peer then
		return
	end

	self.task_handler:handle(icc_peer, peer, msg)
end

---@param peer_id sea.PeerId
---@param icc_peer icc.IPeer
---@param msg icc.Message
function MultiplayerApp:handle_peer(peer_id, icc_peer, msg)
	local ok, err = xpcall(self.handle_msg, debug.traceback, self, peer_id, icc_peer, msg)
	if not ok then
		print("icc error ", err)
	end
end

function MultiplayerApp:update()
	local ok, err = pcall(self.task_handler.update, self.task_handler)
	if not ok then
		print(err)
	end
end

---@param peer_id string
---@param icc_peer icc.IPeer
function MultiplayerApp:connected(peer_id, icc_peer)
	local remote = Remote(self.task_handler, icc_peer) --[[@as sea.MultiplayerClientRemote]]

	local peer = Peer()
	peer.remote = MultiplayerClientRemoteValidation(remote)
	peer.remote_no_return = MultiplayerClientRemoteValidation(-remote)
	peer.user = User()
	peer.session = Session()

	self.peers:add(peer_id, peer)

	icc_co.wrap(function()
		self.server:connected(peer)
	end)()
end

---@param peer_id string
function MultiplayerApp:disconnected(peer_id)
	local peer = self.peers:remove(peer_id)

	icc_co.wrap(function()
		self.server:disconnected(peer)
	end)()
end

return MultiplayerApp
