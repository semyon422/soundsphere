return function(url, savePath)
	local request = require("luajit-request")
	local response, code, err = request.send(url)
	if not response then
		return
	end

	require("love.filesystem")
	return love.filesystem.write(savePath, response.body)
end
