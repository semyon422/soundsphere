byte = {}

byte.bytes = function(s)
	return s:byte(1, -1)
end

byte.readInteger = function(s, le)
	local number = 0
	
	for i = 1, #s do
		number = number + s:byte(#s - i + 1, #s - i + 1) * 256 ^ (i - 1)
	end
	
	if le then
		number = bit.bswap(number) / 256 ^ (4 - #s)
	end
	
	return number
end

-- byte.readInteger = function(s, le)
	-- local number = 0
	
	-- for i = 1, #s do
		-- if le then
			-- number = number + s:byte(i, i) * 256 ^ (i - 1)
		-- else
			-- number = number + s:byte(#s - i + 1, #s - i + 1) * 256 ^ (i - 1)
		-- end
	-- end
	
	-- return number
-- end

byte.readFloat = function(s, le)
	local integer = byte.readInteger(s, le)
	
	local sign = bit.rshift(integer, 31) == 1 and -1 or 1
	local exponent = bit.band(bit.rshift(integer, 23), 0xFF)
	local fraction = exponent ~= 0 and bit.bor(bit.band(integer, 0x7FFFFF), 0x800000) or bit.lshift(bit.band(integer, 0x7FFFFF), 1)
	
	return sign * (fraction * 2 ^ -23) * (2 ^ (exponent - 127))
end

byte.buffer = function(s, le)
	return {
		s = s,
		offset = 0,
		size = #s,
		le = le,
		remaining = #s
	}
end

byte.read = function(buffer, offset, size)
	return buffer.s:sub(offset + 1, offset + size)
end

byte.get = function(buffer, size)
	local out = buffer.s:sub(buffer.offset + 1, buffer.offset + size)
	buffer.offset = buffer.offset + size
	buffer.remaining = buffer.remaining - size
	return out
end

byte.getInteger = function(buffer, size)
	local out = byte.readInteger(buffer.s:sub(buffer.offset + 1, buffer.offset + size), buffer.le)
	buffer.offset = buffer.offset + size
	buffer.remaining = buffer.remaining - size
	return out
end

byte.getFloat = function(buffer)
	local out = byte.readFloat(buffer.s:sub(buffer.offset + 1, buffer.offset + 4), buffer.le)
	buffer.offset = buffer.offset + 4
	buffer.remaining = buffer.remaining - 4
	return out
end