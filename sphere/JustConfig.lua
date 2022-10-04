local serpent = require("serpent")
local Class = require("Class")
local just = require("just")
local imgui = require("sphere.imgui")

local JustConfig = Class:new()

function JustConfig:get(key)
	return self.data[key]
end

function JustConfig:set(key, ...)
	self.data[key] = ...
end

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
end

function JustConfig:close()
	if self:get("autosave") then
		self:write()
	end
end

function JustConfig:fromFile(path)
	local content = love.filesystem.read(path)
	local exists = content ~= nil
	content = content or self.defaultContent
	local config = assert(loadstring(content))()
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

function JustConfig:export(s)
	return (s:gsub(
		"--%[%[data%]%].+--%[%[/data%]%]",
		("--[[data]] %s --[[/data]]"):format(serpent.block(self.data, opts))
	))
end

JustConfig.defaultContent = [=[
local JustConfig = require("sphere.JustConfig")

local config = JustConfig:new()

config.data = --[[data]] {} --[[/data]]

function config:draw()
	self:drawAfter()
end

return config
]=]

return JustConfig
