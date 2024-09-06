local pkg = require("aqua.pkg")
pkg.reset()
pkg.add(".")
pkg.add("3rd-deps/lua")
pkg.add("aqua")
pkg.add("ncdk")
pkg.add("chartbase")
pkg.add("libchart")
pkg.add("tree/share/lua/5.1")
pkg.addc("3rd-deps/lib")
pkg.addc("bin/lib")
pkg.addc("tree/lib/lua/5.1")

pkg.export_lua()

require("preload")
require("aqua.string")

package.loaded.utf8 = require("lua-utf8")

local socket = require("socket")
local LuasocketServer = require("web.socket.LuasocketServer")
local ComputeApp = require("sphere.web.ComputeApp")

local app = ComputeApp()

local server = LuasocketServer("*", 8080, app)

server:load()

while true do
	server:update()
	socket.sleep(0.1)
end
