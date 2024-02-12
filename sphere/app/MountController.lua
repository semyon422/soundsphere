local class = require("class")
local fs_util = require("fs_util")
local thread = require("thread")

---@class sphere.MountController
---@operator call: sphere.MountController
local MountController = class()

---@param configModel sphere.ConfigModel
---@param cacheModel sphere.CacheModel
function MountController:new(configModel, cacheModel)
	self.configModel = configModel
	self.cacheModel = cacheModel
end

---@param file love.File
function MountController:filedropped(file)
	local path = file:getFilename():gsub("\\", "/")
	if not path:find("%.osz$") then
		return
	end

	local extractPath = "userdata/charts/dropped/" .. path:match("^.+/(.-)%.osz$")

	print(("Extracting to: %s"):format(extractPath))
	local extracted = fs_util.extractAsync(path, extractPath, false)
	if not extracted then
		print("Failed to extract")
		return
	end
	print("Extracted")

	self.cacheModel:startUpdate(extractPath, true)
end
MountController.filedropped = thread.coro(MountController.filedropped)

return MountController
