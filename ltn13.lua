-- https://github.com/lunarmodules/luasocket/blob/master/ltn013.md

local ltn13 = {}

local function ret(ok, ...)
	if ok then return ... end
	return nil, ...
end

function ltn13.protect(f)
	return function(...)
		return ret(pcall(f, ...))
	end
end

function ltn13.newtry(f)
	return function(...)
		local ok, err = ...
		if ok then return ... end
		if f then f() end
		error(err)
	end
end

return ltn13
