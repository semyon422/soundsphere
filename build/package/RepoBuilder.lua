local class = require("class")
local stbl = require("stbl")
local crc32 = require("crc32")
local json = require("3rd-deps.lua.json")
local util = require("build.package.util")
local config = require("build.package.config")

local _name = config.repo.name

---@class repo.RepoBuilder
---@operator call: repo.RepoBuilder
local RepoBuilder = class()

---@param git_repo repo.GitRepo | repo.CurrentRepo
function RepoBuilder:new(git_repo)
	self.git_repo = git_repo
end

local function serialize(t)
	return ("return %s\n"):format(stbl.encode(t))
end

function RepoBuilder:writeConfigs(gamedir)
	util.write(gamedir .. "/version.lua", serialize({
		date = self.git_repo:log_date(),
		commit = self.git_repo:log_commit(),
	}))

	-- Note: Rizu uses different config structure than old sphere
	-- If sphere/persistence/ConfigModel/urls.lua exists, update it
	local urls_path = gamedir .. "/sphere/persistence/ConfigModel/urls.lua"
	if util.popen_read("ls " .. urls_path):find("urls.lua") then
		local urls = dofile(urls_path)
		urls.host = config.game.api
		urls.websocket = config.game.websocket
		urls.update = config.game.repo .. "/files.json"
		urls.osu = config.osu
		urls.multiplayer = config.game.multiplayer
		util.write(urls_path, serialize(urls))
	end
end

local extract_list = {
	"bin",
	"resources",
	"userdata",
	"game-appimage",
	"game-linux",
	"game-macos",
	"game-win64.bat",
}

local include_list = {
	"rizu",
	"sphere",
	"sea",
	"aqua",
	"chartbase",
	"libchart",
	"native",
	"preload",
	"ui",
	"yi",
}

function RepoBuilder:buildGenericRepo()
	util.md("repo")

	local gamerepo = "repo/" .. _name
	local gamedir = gamerepo .. "/gamedir.love"

	util.rm(gamerepo)
	util.md(gamerepo)
	util.md(gamedir)

	local src_root = self.git_repo:getDirName()

	print("Copying core folders...")
	for _, dir in ipairs(include_list) do
		if util.popen_read("ls -d " .. src_root .. "/" .. dir):find(dir) then
			util.cp(src_root .. "/" .. dir, gamedir)
		end
	end

	print("Copying root lua files...")
	os.execute(("cp %s/*.lua %s/"):format(src_root, gamedir))

	print("Copying 3rd-deps/lua...")
	util.md(gamedir .. "/3rd-deps")
	util.cp(src_root .. "/3rd-deps/lua", gamedir .. "/3rd-deps/")

	print("Extracting platform files...")
	for _, dir in ipairs(extract_list) do
		if util.popen_read("ls -d " .. src_root .. "/" .. dir):find(dir) then
			if dir == "userdata" then
				-- Exclude large local data folders when copying userdata
				os.execute(("tar -cf - --exclude=charts --exclude=scores --exclude=db -C %q %q | tar -xf - -C %q"):format(src_root, dir, gamerepo))
			else
				util.cp(src_root .. "/" .. dir, gamerepo)
			end
		end
	end
	
	-- Move 3rd-deps/lib to bin/ if it exists
	if util.popen_read("ls -d " .. src_root .. "/3rd-deps/lib"):find("lib") then
		util.md(gamerepo .. "/bin")
		util.cp(src_root .. "/3rd-deps/lib/*", gamerepo .. "/bin/")
	end

	print("Cleaning up unnecessary files...")
	util.findall(gamedir, '-regextype posix-egrep -not -regex ".*\\.(lua|c|sql)$" -type f -delete')
	util.findall(gamerepo, '-name ".*" -delete')
	util.findall(gamerepo, "-empty -type d -delete")

	self:writeConfigs(gamedir)

	print("Zipping game.love...")
	os.execute(("7z a -tzip %s/game.love ./%s/*"):format(gamerepo, gamedir))
	util.rm(gamedir)

	if util.popen_read("ls " .. src_root .. "/conf.lua"):find("conf.lua") then
		util.cp(src_root .. "/conf.lua", gamerepo)
	end
	
	-- Copy build/package/conf.lua as launcher config if it exists
	if util.popen_read("ls build/package/conf.lua"):find("conf.lua") then
		util.cp("build/package/conf.lua", gamerepo)
	end
end

function RepoBuilder:build()
	self:buildGenericRepo()

	local gamerepo = "repo/" .. _name
	local files = {}
	for line in util.find(gamerepo, "-type f") do
		local content = util.read(line)
		if content then
			table.insert(files, {
				path = line:gsub(("^%s/"):format(gamerepo), ""),
				url = config.game.repo .. line:gsub("^repo", ""),
				hash = crc32.hash(content),
			})
		end
	end

	util.write(gamerepo .. "/userdata/files.lua", serialize(files))
	util.write("repo/files.json", json.encode(files))
end

function RepoBuilder:build_zip()
	os.execute(("7z a -tzip repo/%s_temp.zip ./repo/%s"):format(_name, _name))
	util.rm(("repo/%s.zip"):format(_name))
	util.mv(("repo/%s_temp.zip"):format(_name), ("repo/%s.zip"):format(_name))
end

function RepoBuilder:update_zip()
	util.md("repo/tmp")
	util.md(("repo/tmp/%s"):format(_name))
	util.cp(("repo/%s/game.love"):format(_name), ("repo/tmp/%s/game.love"):format(_name))
	os.execute(("7z u -tzip repo/%s.zip ./repo/tmp/%s"):format(_name, _name))
	util.rm("repo/tmp")
end

function RepoBuilder:buildMacos()
	local game_app = ("repo/macos/%s.app"):format(_name)
	local Contents = game_app .. "/Contents"
	local Frameworks = Contents .. "/Frameworks"
	local Resources = Contents .. "/Resources"

	util.rm("repo/macos")
	util.md("repo/macos")
	
	local love_zip = "build/downloads/love-macos.zip"
	if not util.popen_read("ls " .. love_zip):find("love-macos.zip") then
		print("Warning: " .. love_zip .. " not found, skipping macOS app build")
		return
	end

	os.execute("7z x -tzip " .. love_zip .. " -orepo/macos")
	util.mv("repo/macos/love.app", game_app)
	util.findall(game_app, "-type l -delete")
	util.findall(Frameworks, '-type f -not -regex "^.*/A/[^/]*$" -delete')
	
	if util.popen_read("ls build/package/Info.plist"):find("Info.plist") then
		util.cp("build/package/Info.plist", game_app .. "/Contents")
	end
	
	util.rm(Resources)
	util.cp(("repo/%s"):format(_name), Resources)
	
	if util.popen_read("ls -d " .. Resources .. "/bin/mac64"):find("mac64") then
		for path in util.find(Resources .. "/bin/mac64", "-type f") do
			util.mv(path, Frameworks)
		end
	end
	
	util.rm(Resources .. "/bin/win64")
	util.rm(Resources .. "/bin/linux64")

	util.findall(game_app, "-empty -type d -delete")

	os.execute(("7z a -tzip repo/%s_macos_temp.zip ./"):format(_name) .. game_app)
	util.rm(("repo/%s_macos.zip"):format(_name))
	util.mv(("repo/%s_macos_temp.zip"):format(_name), ("repo/%s_macos.zip"):format(_name))
end

return RepoBuilder
