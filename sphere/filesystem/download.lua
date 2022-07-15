return function(url, saveDir, fallbackName)
	local request = require("luajit-request")
	local response, code, err = request.send(url)
	if not response then
		return
	end

	local name = fallbackName or url:match("^.+/(.-)$")
	for header, value in pairs(response.headers) do
		if header:lower() == "content-disposition" then
			local filename = value:match("filename=\"(.-)\"$")
			if filename then
				name = filename
				break
			end
		end
	end

	require("love.filesystem")
	return love.filesystem.write(saveDir .. "/" .. name, response.body), name
end
