local class = require("class")

---@class ncdk2.Tempo
---@operator call: ncdk2.Tempo
---@field point ncdk2.Point
local Tempo = class()

---@param tempo number
function Tempo:new(tempo)
	self.tempo = tempo
end

---@return number
function Tempo:getBeatDuration()
	return 60 / self.tempo
end

---@param a ncdk2.Tempo
---@return string
function Tempo.__tostring(a)
	return ("Tempo(%s)"):format(a.tempo)
end

return Tempo
