local BeatconnectProvider = require("rizu.dlc.providers.BeatconnectProvider")

local test = {}

---@param t testing.T
function test.initialization(t)
	local provider = BeatconnectProvider()
	t:eq(provider.apiUrl, "https://beatconnect.io/api/search/")
	t:eq(provider.downloadUrlPattern, "https://beatconnect.io/b/%s")
end

---@param t testing.T
function test.getDownloadUrl(t)
	local provider = BeatconnectProvider()
	t:eq(provider:getDownloadUrl(12345), "https://beatconnect.io/b/12345")
end

return test
