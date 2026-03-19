#!/usr/bin/env luajit
-- Simple dependency fetcher for Rizu

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

-- We are now inside build/
local build_dir = "."
local downloads_dir = build_dir .. "/downloads"
local deps_dir = build_dir .. "/deps"
local bin_dir = "../bin"

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
		-- We want to bundle ONLY the files that satisfy the SONAME dependencies.
		-- In FFmpeg, these are typically libav*.so.NN
		-- We use find to locate symlinks that point to the actual library and have the major version.
		local lib_src = extract_to .. "/lib"
		execute("mkdir -p " .. platform_bin)
		
		-- Copy major versioned files (dereferenced)
		-- We look for files matching lib*.so.[0-9]* but NOT having more than one dot after .so
		-- This matches .so.62 but not .so.62.29.101
		execute("find " .. lib_src .. " -maxdepth 1 -name \"*.so.[0-9]*\" ! -name \"*.so.[0-9]*.*[0-9]*\" -exec cp -L {} " .. platform_bin .. " \\;")
		
		-- Also copy the base .so dereferenced (useful for build time if needed, though redundant for runtime)
		-- execute("find " .. lib_src .. " -maxdepth 1 -name \"*.so\" -exec cp -L {} " .. platform_bin .. " \\;")
		
		print("Bundled major-versioned FFmpeg .so files to " .. platform_bin)
	else
		execute("cp -r " .. extract_to .. "/bin/*.dll " .. platform_bin .. "/")
	end
	
	print("FFmpeg for " .. t .. " extracted to " .. extract_to .. " and binaries copied to " .. platform_bin)
end

local function download_7zsdk()
	local config = deps.sevenzip
	local dest = downloads_dir .. "/" .. config.archive
	local extract_to = deps_dir .. "/" .. config.dir
	
	if not download_if_missing(config.url, dest) then return end
	
	execute("mkdir -p " .. extract_to)
	
	-- Extraction needs 7zip installed on host (setup_host.sh should handle this)
	if not execute("7z x -y " .. dest .. " -o" .. extract_to) then
		-- fallback to 7zr if 7z is not found
		execute("7zr x -y " .. dest .. " -o" .. extract_to)
	end
	print("7z SDK extracted to " .. extract_to)
end

if target:lower() == "linux" or target:lower() == "windows" or target:lower() == "win64" then
	download_ffmpeg(target)
	download_7zsdk()
elseif target:lower() == "macos" then
	print("MacOS target selected.")
	download_7zsdk()
else
	print("Unsupported target: " .. target)
	os.exit(1)
end

print("Dependency fetch complete for " .. target)
