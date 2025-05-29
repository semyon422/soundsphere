local Filehash = {}

function Filehash.encode(hex)
	assert(#hex == 32)
	return (hex:gsub("..", function(cc) return string.char(tonumber(cc, 16) or 0) end))
end

function Filehash.decode(data)
	assert(#data == 16)
	return (data:gsub(".", function(c) return ("%02x"):format(c:byte()) end))
end

return Filehash
