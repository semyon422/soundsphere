local sound = require("aqua.sound")

local Modifier = require("sphere.models.ModifierModel.Modifier")

local AudioClip = Modifier:new()

AudioClip.type = "TimeEngineModifier"
AudioClip.interfaceType = "slider"

AudioClip.name = "AudioClip"

AudioClip.defaultValue = 0
AudioClip.step = 10
AudioClip.range = {0, 100}

AudioClip.getString = function(self, config)
	local value = config.value
    if value > 0 then
	    return "+" .. value .. "dB"
	end
end

AudioClip.apply = function(self, config)
	sound.set_gain(config.value)
end

return AudioClip

