local class = require("class")
local table_util = require("table_util")
local AnalogScratch = require("libchart.AnalogScratch")
local ScratchMapper = require("libchart.ScratchMapper")

---@class sphere.JoystickModel
---@operator call: sphere.JoystickModel
local JoystickModel = class()

---@param configModel sphere.ConfigModel
function JoystickModel:new(configModel)
	self.data = {}
	self.configModel = configModel
end

function JoystickModel:getScratchState(id, axis)
	local data = self.data
	data[id] = data[id] or {}
	if data[id][axis] then
		return data[id][axis]
	end

	local cfg = self.configModel.configs.settings.gameplay.analog_scratch

	local analogScratch = AnalogScratch(cfg.act_period, cfg.deact_period, cfg.act_w, cfg.deact_w)
	local scratchMapper = ScratchMapper(analogScratch, function(state, is_right)
		local key = ("%s%s (%s)"):format(is_right and "+" or "-", axis, id)
		local name = state and "joystickpressed" or "joystickreleased"
		love.event.push(name, key, key)
	end)
	data[id][axis] = {
		analogScratch = analogScratch,
		scratchMapper = scratchMapper,
	}

	return data[id][axis]
end

function JoystickModel:receive(event)
	if event.name ~= "joystickaxis" then
		return
	end
	local joystick, axis, value = unpack(event)
	local id = joystick:getID()

	local state = self:getScratchState(id, axis)
	state.value = value
end

function JoystickModel:update(dt)
	for id, d in pairs(self.data) do
		for axis, state in pairs(d) do
			state.analogScratch:update(state.value, dt)
			state.scratchMapper:update()
		end
	end
end

return JoystickModel
