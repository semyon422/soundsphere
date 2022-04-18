local ffi = require("ffi")
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

local function _unpack(tab, i, j)
	if i == j then
		return tab[i]
	end
	return tab[i], _unpack(tab, i + 1, j)
end
function ImguiConfig:get(name)
	return _unpack(self.ptrs[name], 0, self.defs[name][2] - 1)
end

function ImguiConfig:render() end

function ImguiConfig:fromFile(path)
	local content = love.filesystem.read(path)
	local config = loadstring(content)()
	config.content = content
	config.path = path
	return config
end

function ImguiConfig:write()
	love.filesystem.write(self.path, self:export(self.content))
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

return ImguiConfig
