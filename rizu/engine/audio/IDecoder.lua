local class = require("class")
local ffi = require("ffi")

---@class rizu.audio.IDecoder
---@operator call: rizu.audio.IDecoder
local IDecoder = class()

---@param buf ffi.cdata*
---@param len integer
---@return integer
function IDecoder:getData(buf, len)
	error("not implemented")
end

---@param len integer
---@return string
function IDecoder:getDataString(len)
	local buf = ffi.new("int8_t[?]", len)
	local read = self:getData(buf, len)
	return ffi.string(buf, read)
end

---@param pos integer
---@return number
function IDecoder:bytesToSeconds(pos)
	error("not implemented")
end

---@param pos number
---@return integer
function IDecoder:secondsToBytes(pos)
	error("not implemented")
end

---@return number
function IDecoder:getPosition()
	return self:bytesToSeconds(self:getBytesPosition())
end

---@return integer
function IDecoder:getBytesPosition()
	error("not implemented")
end

---@param pos number
function IDecoder:setPosition(pos)
	self:setBytesPosition(self:secondsToBytes(pos))
end

---@param pos integer
function IDecoder:setBytesPosition(pos)
	error("not implemented")
end

---@return number
function IDecoder:getDuration()
	return self:bytesToSeconds(self:getBytesDuration())
end

---@return integer
function IDecoder:getBytesDuration()
	error("not implemented")
end

---@return integer
function IDecoder:getSampleRate()
	error("not implemented")
end

---@return integer
function IDecoder:getChannelCount()
	error("not implemented")
end

---@return integer
function IDecoder:getBytesPerSample()
	error("not implemented")
end

function IDecoder:release() end

return IDecoder
