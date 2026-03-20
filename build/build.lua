#!/usr/bin/env luajit
-- Rizu Lua Build Script (Run from project root)
-- Reference: @lua-dev-env scripts

local args = {...}
local target = args[1]

-- Host detection
local host_os = (package.config:sub(1,1) == "\\") and "Windows" or "Linux"
if host_os == "Linux" then
	local handle = io.popen("uname -s")
	if handle then
		local res = handle:read("*a")
		handle:close()
		if res:match("Darwin") then host_os = "MacOS" end
	end
end

if not target then
	target = host_os
	print("No target specified, defaulting to host: " .. target)
end

local function execute(cmd)
	print("Executing: " .. cmd)
	local ok, status, code = os.execute(cmd)
	if not ok then
		print("Command failed with code: " .. tostring(code))
		os.exit(code or 1)
	end
end

-- Absolute paths are safer but we can use relative if we are in root
local build_dir = "build"
local tree = os.getenv("TREE") or "./tree"
local build_deps = build_dir .. "/deps"

local function get_ffmpeg_paths(t)
	local suffix = t:lower():match("win") and "win" or "linux"
	local base = build_deps .. "/ffmpeg-" .. suffix
	
	local inc = base .. "/include"
	local lib = base .. "/lib"
	
	-- Verification
	if not os.execute("ls " .. inc .. "/libavcodec/avcodec.h 2>/dev/null") then
		print("Warning: FFmpeg headers not found in " .. inc .. ", falling back to tree/")
		return tree .. "/include", tree .. "/lib"
	end
	
	return inc, lib
end

local function get_7z_inc()
	local base = build_deps .. "/7zsdk/C"
	if os.execute("ls " .. base .. "/Alloc.c 2>/dev/null") then
		return base
	end
	print("Warning: 7z SDK headers not found in " .. base .. ", falling back to aqua/")
	return "./aqua"
end

local function get_compiler(t)
	if host_os == "Linux" then
		if t:lower() == "windows" or t:lower() == "win64" then
			return "x86_64-w64-mingw32-gcc"
		elseif t:lower() == "macos" then
			return "x86_64-apple-darwin19-clang" -- Placeholder for osxcross
		end
	end
	return "gcc"
end

local function build_7z(t)
	print("Building 7z for " .. t .. "...")
	local src = "aqua/7z.c"
	local cc = get_compiler(t)
	local inc = "-I" .. get_7z_inc()
	local out, flags
	
	if t:lower() == "windows" or t:lower() == "win64" then
		out = "bin/win64/7z.dll"
		flags = "-shared -fPIC"
	elseif t:lower() == "macos" then
		out = "bin/macos/lib7z.dylib"
		flags = "-shared -fPIC"
	else
		out = "bin/linux64/lib7z.so"
		flags = "-D_GNU_SOURCE -shared -fPIC"
	end
	
	execute(string.format("%s %s %s -o %s %s", cc, inc, flags, out, src))
end

local function build_video(t)
	print("Building Video for " .. t .. "...")
	local src = "aqua/video.c"
	local cc = get_compiler(t)
	local out, flags, libs
	
	local ffmpeg_inc, ffmpeg_lib_dir = get_ffmpeg_paths(t)
	local luajit_inc = tree .. "/include/luajit-2.1"
	
	local inc = string.format("-I%s -I%s", luajit_inc, ffmpeg_inc)
	
	if t:lower() == "windows" or t:lower() == "win64" then
		out = "bin/win64/video.dll"
		libs = string.format("-L%s/lib -L%s -lavformat -lavcodec -lswresample -lswscale -lavutil -lm -l:libluajit-5.1.dll.a", tree, ffmpeg_lib_dir)
		flags = "-shared -fPIC"
	elseif t:lower() == "macos" then
		out = "bin/macos/video.so"
		libs = "-lavformat -lavcodec -lswresample -lswscale -lavutil -lm"
		flags = "-shared -fPIC -undefined dynamic_lookup"
	else
		out = "bin/linux64/video.so"
		libs = string.format("-L%s -lavformat -lavcodec -lswresample -lswscale -lavutil -lm", ffmpeg_lib_dir)
		flags = "-shared -fPIC -Wl,-rpath,'$ORIGIN'"
	end
	
	execute(string.format("%s %s %s -o %s %s %s", cc, inc, flags, out, src, libs))
end

execute("mkdir -p bin/linux64 bin/win64 bin/macos")
build_7z(target)
build_video(target)

print("Build successful for " .. target)
