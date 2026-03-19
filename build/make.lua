#!/usr/bin/env luajit
-- Rizu Unified Task Runner

local args = {...}
local command = args[1]
local target = args[2]

local function execute(cmd)
	print(">> " .. cmd)
	local ok = os.execute(cmd)
	if not ok then
		os.exit(1)
	end
end

local tasks = {}

function tasks.deps()
	execute("./fetch_deps.lua " .. (target or ""))
end

function tasks.build()
	execute("./build.lua " .. (target or ""))
end

function tasks.setup()
	if target == "macos" then
		execute("./setup_cross_macos.sh")
	elseif target == "luajit" then
		execute("./setup_luajit.sh")
	elseif target == "luajit_win" then
		execute("./setup_luajit_win.sh")
	else
		execute("./setup_host.sh")
	end
end

function tasks.all()
	tasks.deps()
	tasks.build()
end

function tasks.clean()
	print("Cleaning build/deps and bin/...")
	execute("rm -rf deps bin")
	execute("mkdir -p deps bin")
end

function tasks.help()
	print([[
Rizu Build System
Usage: ./make.lua <command> [target]

Commands:
  setup [target]    Install dependencies (target: host, luajit, luajit_win, macos)
  deps [target]     Fetch binary dependencies (target: linux, windows)
  build [target]    Compile C modules (target: linux, windows, macos)
  all [target]      Run deps + build
  clean             Remove build artifacts
  help              Show this help
]])
end

if not tasks[command] then
	tasks.help()
	os.exit(1)
end

tasks[command]()
