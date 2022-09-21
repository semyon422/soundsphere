return function(url)
	local https = require("ssl.https")
	return https.request(url)
end
