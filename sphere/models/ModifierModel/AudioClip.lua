local sound = require("aqua.sound")

local Modifier = require("sphere.models.ModifierModel.Modifier")

local AudioClip = Modifier:new()

AudioClip.inconsequential = true
AudioClip.type = "TimeEngineModifier"

AudioClip.name = "AudioClip"
AudioClip.shortName = "Clip"

AudioClip.defaultValue = 0
AudioClip.step = 10
AudioClip.offset = 0
AudioClip.range = {0, 10}

AudioClip.getString = function(self, config)
	config = config or self.config
	local realValue = self:getRealValue(config)
    if realValue > 0 then
	    return "+" .. self.value .. "dB"
	end
end

AudioClip.apply = function(self)
	sound.set_gain(self.value)
end

return AudioClip

