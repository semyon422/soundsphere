local ffi = require("ffi")

ffi.cdef([[
	int MultiByteToWideChar(
		uint32_t CodePage,
		uint32_t dwFlags,
		const char *lpMultiByteStr,
		int32_t cbMultiByte,
		wchar_t *lpWideCharStr,
		int32_t cchWideChar
	);
	int WideCharToMultiByte(
		uint32_t CodePage,
		uint32_t dwFlags,
		wchar_t *lpWideCharStr,
		int32_t cchWideChar,
		char *lpMultiByteStr,
		int32_t cbMultiByte,
		char *lpDefaultChar,
		bool *lpUsedDefaultChar
	);
	int _wgetenv_s(
		size_t *pReturnValue,
		wchar_t *buffer,
		size_t numberOfElements,
		const wchar_t *varname
	);
	int _wputenv_s(const wchar_t *varname, const wchar_t *value_string);
	int _wchdir(const wchar_t *dirname);
	wchar_t *_wgetcwd(wchar_t *buffer, int maxlen);
]])

local winapi = {}

-- https://docs.microsoft.com/en-us/windows/win32/api/stringapiset/nf-stringapiset-multibytetowidechar
function winapi.to_wchar_t(s)
	local size = ffi.C.MultiByteToWideChar(65001, 0x8, s, #s, nil, 0)
	assert(size > 0, "conversion error")

	local buf = ffi.new("wchar_t[?]", size + 1)
	assert(ffi.C.MultiByteToWideChar(65001, 0x8, s, #s, buf, size) ~= 0, "conversion error")

	return buf
end

-- https://docs.microsoft.com/en-us/windows/win32/api/stringapiset/nf-stringapiset-widechartomultibyte
function winapi.to_string(w)
	local size = ffi.C.WideCharToMultiByte(65001, 0x80, w, -1, nil, 0, nil, nil)
	assert(size > 0, "conversion error")

	local buf = ffi.new("char[?]", size)
	assert(ffi.C.WideCharToMultiByte(65001, 0x80, w, -1, buf, size, nil, nil) ~= 0, "conversion error")

	return ffi.string(buf, size - 1)
end

-- https://docs.microsoft.com/en-us/cpp/c-runtime-library/reference/getenv-s-wgetenv-s?view=msvc-170
function winapi.getenv(name)
	name = winapi.to_wchar_t(name)

	local size_ptr = ffi.new("size_t[1]")

	assert(ffi.C._wgetenv_s(size_ptr, nil, 0, name) == 0)
	if size_ptr[0] == 0 then
		return
	end

	local buf = ffi.new("wchar_t[?]", size_ptr[0])
	assert(ffi.C._wgetenv_s(size_ptr, buf, size_ptr[0], name) == 0)

	return winapi.to_string(buf)
end

-- https://docs.microsoft.com/en-us/cpp/c-runtime-library/reference/putenv-s-wputenv-s?view=msvc-170
function winapi.putenv(name, value)
	assert(ffi.C._wputenv_s(winapi.to_wchar_t(name), winapi.to_wchar_t(value)) == 0)
end

-- https://docs.microsoft.com/en-us/cpp/c-runtime-library/reference/chdir-wchdir?view=msvc-170
function winapi.chdir(dir)
	assert(ffi.C._wchdir(winapi.to_wchar_t(dir)) == 0)
end

-- https://docs.microsoft.com/en-us/cpp/c-runtime-library/reference/getcwd-wgetcwd?view=msvc-170
function winapi.getcwd()
	local buf = ffi.C._wgetcwd(nil, 0)
	assert(buf ~= 0)
	return winapi.to_string(buf)
end

return winapi
