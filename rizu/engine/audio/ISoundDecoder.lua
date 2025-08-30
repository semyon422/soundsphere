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
	return self:bytesToSeconds(self:getBytesPosition())
end

---@return integer
function ISoundDecoder:getBytesPosition()
	error("not implemented")
end

---@param pos number
function ISoundDecoder:setPosition(pos)
	self:setBytesPosition(self:secondsToBytes(pos))
end

---@param pos integer
function ISoundDecoder:setBytesPosition(pos)
	error("not implemented")
end

---@return number
function ISoundDecoder:getDuration()
	return self:bytesToSeconds(self:getBytesDuration())
end

---@return integer
function ISoundDecoder:getBytesDuration()
	error("not implemented")
end

---@return integer
function ISoundDecoder:getSampleRate()
	error("not implemented")
end

---@return integer
function ISoundDecoder:getChannelCount()
	error("not implemented")
end

---@return integer
function ISoundDecoder:getBytesPerSample()
	error("not implemented")
end

return ISoundDecoder
