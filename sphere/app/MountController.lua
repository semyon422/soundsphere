local class = require("class")
local extractAsync = require("sphere.filesystem.extract")
local thread = require("thread")

---@class sphere.MountController
---@operator call: sphere.MountController
local MountController = class()

---@param event table
function MountController:receive(event)
	if event.name == "directorydropped" then
		self:directorydropped(event[1])
	elseif event.name == "filedropped" then
		self:filedropped(event[1])
	end
end

---@param path string
function MountController:directorydropped(path)
	path = path:gsub("\\", "/")
	local mountModel = self.mountModel
	if not mountModel:isAdded(path) then
		self.mountModel:addPath(path)
	end
	self.mountModel:mount(path)
	self.configModel:write("mount")
end

---@param file love.File
function MountController:filedropped(file)
	local path = file:getFilename():gsub("\\", "/")
	if not path:find("%.osz$") then
		return
	end

	local extractPath = "userdata/charts/dropped/" .. path:match("^.+/(.-)%.osz$")

	print(("Extracting to: %s"):format(extractPath))
	local extracted = extractAsync(path, extractPath, false)
	if not extracted then
		print("Failed to extract")
		return
	end
	print("Extracted")

	self.cacheModel:startUpdate(extractPath, true)
end
MountController.filedropped = thread.coro(MountController.filedropped)

return MountController
