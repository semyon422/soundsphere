return function(url)
	local request = require("luajit-request")
	local response, code, err = request.send(url)
	if not response then
		return
	end
	return response.body, response.code
end
