local Class = require("aqua.util.Class")
local json = require("json")
local zlib = require("zlib")
local mime = require("mime")

local ReplayJson = Class:new()

ReplayJson.encode = function(self, events)
	local jsonData = json.encode(events)
	local compressedEvents = zlib.compress(jsonData)
	return mime.b64(compressedEvents), #jsonData
end

ReplayJson.decode = function(self, content, size)
	return json.decode(zlib.uncompress(mime.unb64(content), nil, size))
end

return ReplayJson
