local class = require("class")

---@class rizu.ISoundDecoder
---@operator call: rizu.ISoundDecoder
local ISoundDecoder = class()

---@param buf ffi.cdata*
---@param len integer
---@return integer
function ISoundDecoder:getData(buf, len)
	error("not implemented")
end

---@param pos integer
---@return number
function ISoundDecoder:bytesToSeconds(pos)
	error("not implemented")
end

---@param pos number
---@return integer
function ISoundDecoder:secondsToBytes(pos)
	error("not implemented")
end

---@return number
function ISoundDecoder:getPosition()
	error("not implemented")
end

---@param position number
function ISoundDecoder:setPosition(position)
	error("not implemented")
end

---@return number
function ISoundDecoder:getDuration()
	error("not implemented")
end

return ISoundDecoder
