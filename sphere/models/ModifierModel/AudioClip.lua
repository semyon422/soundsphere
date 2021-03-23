local sound = require("aqua.sound")

local Modifier = require("sphere.models.ModifierModel.Modifier")

local AudioClip = Modifier:new()

AudioClip.inconsequential = true
AudioClip.type = "TimeEngineModifier"

AudioClip.name = "AudioClip"
AudioClip.shortName = "Clip"

AudioClip.variableType = "number"
AudioClip.variableName = "value"
AudioClip.variableFormat = "%3s"
AudioClip.variableRange = {0, 10, 100}

AudioClip.value = 0

AudioClip.tostring = function(self)
    if self.value > 0 then
	    return "+" .. self.value .. "dB"
    end
end

AudioClip.tojson = function(self)
	return ([[{"name":"%s","value":%s}]]):format(self.name, self.value)
end

AudioClip.apply = function(self)
	sound.set_gain(self.value)
end

return AudioClip

