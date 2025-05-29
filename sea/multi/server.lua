local pkg = require("aqua.pkg")
pkg.reset()

pkg.addc()
pkg.addc("3rd-deps/lib")
pkg.addc("bin/lib")
pkg.addc("tree/lib/lua/5.1")
pkg.add()
pkg.add("3rd-deps/lua")
pkg.add("aqua")
pkg.add("ncdk")
pkg.add("chartbase")
pkg.add("libchart")
pkg.add("tree/share/lua/5.1")

pkg.export_lua()

require("preload")

local enet = require("enet")
local socket = require("socket")

local EnetPeer = require("icc.EnetPeer")
local MultiplayerApp = require("sea.multi.MultiplayerApp")

local app = MultiplayerApp()

---@type sea.AppConfig
local app_config = require("app_config")

-- enet host
local host = assert(enet.host_create(("%s:%d"):format(app_config.multiplayer.address, app_config.multiplayer.port)))

while true do
	local event = host:service()
	while event do
		local peer_id = tostring(event.peer)
		if event.type == "connect" then
			app:connected(peer_id, EnetPeer(event.peer))
		elseif event.type == "disconnect" then
			app:disconnected(peer_id)
		elseif event.type == "receive" then
			local icc_peer = EnetPeer(event.peer)
			local msg = icc_peer:decode(event.data)
			if msg then
				app:handle_peer(peer_id, icc_peer, msg)
			end
		end
		event = host:service()
	end

	app:update()

	socket.sleep(0.01)
end
