local thread = require("thread")
thread.shared.download = {}

return thread.async(function(url, saveDir, fallbackName)
	local https = require("ssl.https")
	local ltn12 = require("ltn12")
	local thread = require("thread")
	local path_util = require("path_util")

	local one, code, headers, status_line = https.request({
		url = url,
		method = "HEAD",
		sink = ltn12.sink.null(),
	})
	if not one then
		return nil, code
	end
	if code >= 300 then
		return nil, status_line
	end

	local name = fallbackName or url:match("^.+/(.-)$")
	local size
	for header, value in pairs(headers) do
		header = header:lower()
		if header == "content-disposition" then
			local filename = value:match("filename=\"(.-)\"$")
			name = filename or name
		elseif header == "content-length" then
			size = tonumber(value) or size
		end
	end

	if not size then
		return nil, "Unknown file size"
	end

	thread.shared.download[url] = {
		size = size,
		total = 0,
		speed = 0,
	}
	local shared = thread.shared.download[url]

	local total = 0
	local t = {}
	local time
	local function sink(chunk)
		if chunk == nil or chunk == "" then
			return true
		end

		time = time or love.timer.getTime()
		total = total + #chunk
		shared.total = total
		shared.speed = total / (love.timer.getTime() - time)

		table.insert(t, chunk)

		return true
	end

	one, code, _, status_line = https.request({
		url = url,
		method = "GET",
		sink = sink,
	})
	if not one then
		return nil, code
	end
	if code >= 400 then
		return nil, status_line
	end

	name = path_util.fix_illegal(name)

	require("love.filesystem")
	local ok, err = love.filesystem.write(saveDir .. "/" .. name, table.concat(t))
	if not ok then
		return nil, err
	end
	return name
end)
