local serpent = require("serpent")
local class = require("class")
local just = require("just")
local imgui = require("imgui")

---@class sphere.JustConfig
---@operator call: sphere.JustConfig
local JustConfig = class()

---@param key string
---@return any?
function JustConfig:get(key)
	return self.data[key]
end

---@param key string
---@param value any?
function JustConfig:set(key, value)
	self.data[key] = value
end

function JustConfig:init() end

function JustConfig:draw(w, h) end

function JustConfig:drawAfter()
	local data = self.data
	imgui.text("Config file")
	if imgui.button("Write config file", "Write") then
		self:write()
	end
	just.sameline()
	if imgui.button("Delete config file", "Delete") then
		self:remove()
	end
	just.sameline()
	data.autosave = imgui.checkbox("autosave", data.autosave, "Autosave")

	if imgui.button("Open config file", "Open") then
		love.system.openURL(self.path)
	end
	if self.skinIniPath then
		just.sameline()
		if imgui.button("Open skin.ini", "skin.ini") then
			love.system.openURL(self.skinIniPath)
		end
	end
end

function JustConfig:close()
	if self:get("autosave") then
		self:write()
	end
end

---@param path string
---@return sphere.JustConfig
---@return boolean
function JustConfig:fromFile(path)
	local content = love.filesystem.read(path)
	local exists = content ~= nil
	content = content or self.defaultContent
	local config = assert(loadstring(content, "@" .. path))()
	config.content = content
	config.path = path
	return config, exists
end

function JustConfig:write()
	print("write", self.path)
	love.filesystem.write(self.path, self:export(self.content))
end

function JustConfig:remove()
	print("remove", self.path)
	love.filesystem.remove(self.path)
end

local opts = {
	indent = "\t",
	comment = false,
	sortkeys = true,
	numformat = "%.16g",
	custom = function(tag, head, body, tail)
		local out = head .. body .. tail
		if #tag > 0 then
			out = out:gsub("\n%s+", ""):gsub(",", ", ")
		end
		return tag .. out
	end
}

---@param s string
---@return string
function JustConfig:export(s)
	return (s:gsub(
		"--%[%[data%]%].+--%[%[/data%]%]",
		("--[[data]] %s --[[/data]]"):format(serpent.block(self.data, opts))
	))
end

JustConfig.defaultContent = [=[
local JustConfig = require("sphere.JustConfig")

local config = JustConfig()

config.data = --[[data]] {} --[[/data]]

function config:draw()
	self:drawAfter()
end

return config
]=]

return JustConfig
