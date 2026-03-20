#!/usr/bin/env luajit
-- Simple dependency fetcher for Rizu (Run from project root)

-- Add build/ to path to find deps.lua
package.path = package.path .. ";./build/?.lua"

local deps = require("deps")
local args = {...}
local target = args[1]

-- Detection for host
local host_os = (package.config:sub(1,1) == "\\") and "Windows" or "Linux"
if not target then
	target = host_os
	print("No target specified, defaulting to host: " .. target)
end

local function execute(cmd)
	print("Executing: " .. cmd)
	local ok = os.execute(cmd)
	if not ok then
		print("Command failed!")
		return false
	end
	return true
end

local build_dir = "build"
local downloads_dir = build_dir .. "/downloads"
local deps_dir = build_dir .. "/deps"
local bin_dir = "bin"

execute("mkdir -p " .. downloads_dir .. " " .. deps_dir)

local function file_exists(name)
   local f = io.open(name, "r")
   if f ~= nil then io.close(f) return true else return false end
end

local function download_if_missing(url, dest)
	if file_exists(dest) then
		local f = io.open(dest, "r")
		local size = f:seek("end")
		f:close()
		if size > 0 then
			print("Using existing archive: " .. dest .. " (" .. size .. " bytes)")
			return true
		end
	end
	print("Downloading: " .. url)
	return execute("curl -L " .. url .. " -o " .. dest)
end

local function download_ffmpeg(t)
	local config = deps.ffmpeg[t:lower()]
	if not config then
		print("No FFmpeg config for target: " .. t)
		return
	end
	
	local dest = downloads_dir .. "/" .. config.archive
	local extract_to = deps_dir .. "/" .. config.dir
	
	if not download_if_missing(config.url, dest) then return end
	
	execute("mkdir -p " .. extract_to)
	
	if config.archive:match("%.tar%.xz$") then
		execute("tar -xf " .. dest .. " -C " .. extract_to .. " --strip-components=1")
	else
		execute("mkdir -p " .. extract_to .. "-tmp")
		execute("unzip -o " .. dest .. " -d " .. extract_to .. "-tmp")
		execute("cp -r " .. extract_to .. "-tmp/*/* " .. extract_to .. "/")
		execute("rm -rf " .. extract_to .. "-tmp")
	end
	
	-- Only copy the runtime binaries to bin/
	local platform_bin = bin_dir .. (t:lower() == "linux" and "/linux64" or "/win64")
	execute("mkdir -p " .. platform_bin)
	
	if t:lower() == "linux" then
		execute("find " .. extract_to .. "/lib -maxdepth 1 -name \"*.so.[0-9]*\" ! -name \"*.so.[0-9]*.*[0-9]*\" -exec cp -L {} " .. platform_bin .. " \\;")
		execute("find " .. extract_to .. "/lib -maxdepth 1 -name \"*.so\" -exec cp -L {} " .. platform_bin .. " \\;")
		print("Bundled FFmpeg .so files to " .. platform_bin)
	else
		execute("cp -r " .. extract_to .. "/bin/*.dll " .. platform_bin .. "/")
	end
end

local function download_7zsdk()
	local config = deps.sevenzip
	local dest = downloads_dir .. "/" .. config.archive
	local extract_to = deps_dir .. "/" .. config.dir
	
	if not download_if_missing(config.url, dest) then return end
	
	execute("mkdir -p " .. extract_to)
	
	if not execute("7z x -y " .. dest .. " -o" .. extract_to) then
		execute("7zr x -y " .. dest .. " -o" .. extract_to)
	end
	print("7z SDK extracted to " .. extract_to)
end

local function download_love_macos()
	local config = deps.love_macos
	local dest = downloads_dir .. "/" .. config.archive
	
	if not download_if_missing(config.url, dest) then return end
	
	-- No extraction needed here, RepoBuilder will extract it
	-- Just copy to build/package/ for RepoBuilder
	execute("cp " .. dest .. " build/package/love-macos.zip")
	print("love-macos.zip ready in build/package/")
end

if target:lower() == "linux" or target:lower() == "windows" or target:lower() == "win64" then
	download_ffmpeg(target)
	download_7zsdk()
elseif target:lower() == "macos" then
	print("MacOS target selected.")
	download_7zsdk()
	download_love_macos()
else
	print("Unsupported target: " .. target)
	os.exit(1)
end

print("Dependency fetch complete for " .. target)
