local physfs = require("physfs")
local path_util = require("path_util")
local class = require("class")

---@class sphere.PackageMounter
---@operator call: sphere.PackageMounter
---@field paths string[]
---@field real_paths {[string]: string}
local PackageMounter = class()

---@param pkgs_path string
function PackageMounter:new(pkgs_path)
	self.pkgs_path = pkgs_path
	self.mount_path = "mount" .. tostring(os.time())
	self.paths = {}
	self.real_paths = {}
end

function PackageMounter:mount()
	---@type string[]
	local items = love.filesystem.getDirectoryItems(self.pkgs_path)

	for _, item in ipairs(items) do
		local path = path_util.join(self.pkgs_path, item)
		local info = love.filesystem.getInfo(path)

		local mount_path = path_util.join(self.mount_path, item)
		if info.type == "directory" or info.type == "symlink" or
			(info.type == "file" and item:match("%.zip$"))
		then
			local ok, err = physfs.mount(path, mount_path, false)
			if not ok then
				print(err)
			else
				self.real_paths[path] = mount_path
				table.insert(self.paths, mount_path)
			end
		end
	end
end

function PackageMounter:unmount()
	for path in pairs(self.real_paths) do
		local ok, err = physfs.unmount(path)
		if not ok then
			print(err)
		else
			self.real_paths[path] = nil
		end
	end
	self.real_paths = {}
	self.paths = {}
end

return PackageMounter
