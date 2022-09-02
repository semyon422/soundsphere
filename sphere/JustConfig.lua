local serpent = require("serpent")
local Class = require("aqua.util.Class")
local TextButtonImView2 = require("sphere.imviews.TextButtonImView2")
local CheckboxImView = require("sphere.imviews.CheckboxImView")
local LabelImView = require("sphere.imviews.LabelImView")
local just = require("just")

local JustConfig = Class:new()

JustConfig.size = 55

function JustConfig:get(key)
	return self.data[key]
end

function JustConfig:set(key, ...)
	self.data[key] = ...
end

function JustConfig:draw() end

function JustConfig:drawAfter()
	if TextButtonImView2("Write config file", "Write config file", 300, self.size) then
		self:write()
	end
	if TextButtonImView2("Delete config file", "Delete config file", 300, self.size) then
		self:remove()
	end
	if CheckboxImView("autosave", self:get("autosave"), self.size) then
		self:set("autosave", not self:get("autosave"))
	end
	just.sameline()
	LabelImView("autosave", "Autosave", self.size)
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
	love.filesystem.write(self.path, self:export(self.content))
end

function JustConfig:remove()
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
local TextButtonImView2 = require("sphere.imviews.TextButtonImView2")

local config = JustConfig:new()

config.data = --[[data]] {} --[[/data]]

function config:draw()
	self:drawAfter()
end

return config
]=]

return JustConfig
