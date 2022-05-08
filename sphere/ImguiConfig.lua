local ffi = require("ffi")
local imgui = require("cimgui")
local serpent = require("serpent")
local Class = require("aqua.util.Class")

local ImguiConfig = Class:new()

function ImguiConfig:setDefs(defs)
	local ptrs = {}
	for k, v in pairs(defs) do
		ptrs[k] = ffi.new(unpack(v))
	end
	self.ptrs = ptrs
	self.defs = defs
	return ptrs, defs
end

local function _unpack(t, i, j)
	if not t then return end
	if i == j then return t[i] end
	return t[i], _unpack(t, i + 1, j)
end

local function _pack(t, s, ...)
	for i = 1, select("#", ...) do
		t[i - s - 1] = select(i, ...)
	end
end

function ImguiConfig:get(key)
	return _unpack(self.ptrs[key], 0, self.defs[key][2] - 1)
end

function ImguiConfig:set(key, ...)
	assert(self.defs[key][2] == select("#", ...), "Wrong number of arguments")
	_pack(self.ptrs[key], 0, ...)
end

function ImguiConfig:render() end

function ImguiConfig:renderAfter()
	if imgui.Button("Write config file") then
		self:write()
	end
	if imgui.Button("Delete config file") then
		self:remove()
	end
end

function ImguiConfig:fromFile(path)
	local content = love.filesystem.read(path)
	local exists = content ~= nil
	content = content or self.defaultContent
	local config = assert(loadstring(content))()
	config.content = content
	config.path = path
	return config, exists
end

function ImguiConfig:write()
	love.filesystem.write(self.path, self:export(self.content))
end

function ImguiConfig:remove()
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

function ImguiConfig:export(s)
	for k, v in pairs(self.defs) do
		v[3] = {self:get(k)}
	end
	return (s:gsub(
		"--%[%[defs%]%].+--%[%[/defs%]%]",
		("--[[defs]] %s --[[/defs]]"):format(serpent.block(self.defs, opts))
	))
end

ImguiConfig.defaultContent = [=[
local ImguiConfig = require("sphere.ImguiConfig")
local imgui = require("cimgui")

local config = ImguiConfig:new()

local ptrs = config:setDefs(--[[defs]] {} --[[/defs]])

function config:render()
	if imgui.Button("Save") then
		self:write()
	end
end

return config
]=]

return ImguiConfig
