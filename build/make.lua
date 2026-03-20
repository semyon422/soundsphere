#!/usr/bin/env luajit
-- Rizu Unified Task Runner (Run from project root)

-- Initialize package paths
require("pkg_config")

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
	execute("luajit build/fetch_deps.lua " .. (target or ""))
end

function tasks.build()
	execute("luajit build/build.lua " .. (target or ""))
end

function tasks.setup()
	if target == "macos" then
		execute("./build/setup_cross_macos.sh")
	elseif target == "luajit" then
		execute("./build/setup_luajit.sh")
	elseif target == "luajit_win" then
		execute("./build/setup_luajit_win.sh")
	else
		execute("./build/setup_host.sh")
	end
end

local function get_repo_builder()
	local CurrentRepo = require("build.package.CurrentRepo")
	local RepoBuilder = require("build.package.RepoBuilder")
	return RepoBuilder(CurrentRepo())
end

function tasks.package()
	local builder = get_repo_builder()
	builder:build_zip()
	builder:buildMacos()
end

function tasks.repo()
	local builder = get_repo_builder()
	builder:build()
end

function tasks.all()
	tasks.deps()
	tasks.build()
end

function tasks.clean()
	print("Cleaning build/deps and bin/...")
	execute("rm -rf build/deps bin repo")
	execute("mkdir -p build/deps bin")
end

function tasks.help()
	print([[
Rizu Build System (Execute from root)
Usage: ./build/make.lua <command> [target]

Commands:
  setup [target]    Install dependencies (target: host, luajit, luajit_win, macos)
  deps [target]     Fetch binary dependencies (target: linux, windows, macos)
  build [target]    Compile C modules (target: linux, windows, macos)
  package           Bundle game into zip/app
  repo              Build update repository
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
