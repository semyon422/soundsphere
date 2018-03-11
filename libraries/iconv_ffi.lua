ffi.cdef(io.open("libraries/iconv.h", "r"):read("*a"))

libcharset = ffi.load("libraries/libcharset-1")
libiconv = ffi.load("libraries/libiconv-2")


iconv = function(instr, tocode, fromcode, outbuff_size)
	local cd = libiconv.libiconv_open(tocode, fromcode)
	
	local out = {}
	
	local outbuff_size = outbuff_size or #instr * 4
	local outbuff = ffi.new("char[?]", outbuff_size)
	
	local inbuff_size = #instr
	local inbuff = ffi.new("char[?]", #instr)
	ffi.copy(inbuff, instr, #instr)
	
	local inbuff_ptr = ffi.new("const char*[1]", inbuff)
	local outbuff_ptr = ffi.new("char*[1]", outbuff)
	local inbytesleft = ffi.new("size_t[1]", inbuff_size)
	local outbytesleft = ffi.new("size_t[1]", outbuff_size)

	while inbytesleft[0] ~= 0 do
		local err = libiconv.libiconv(cd, inbuff_ptr, inbytesleft, outbuff_ptr, outbytesleft)
		if err ~= 0 then
			libiconv.libiconv_close(cd)
			return
		end
		table.insert(out, ffi.string(outbuff, outbuff_size - outbytesleft[0]))
		outbytesleft[0] = outbuff_size
		outbuff_ptr[0] = outbuff_ptr[0] - outbuff_size
	end 
	
	inbuff_ptr[0] = inbuff_ptr[0] - inbuff_size
	libiconv.libiconv(cd, nil, nil, nil, nil)
	libiconv.libiconv_close(cd)
	
	return table.concat(out)
end
