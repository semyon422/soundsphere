local OsuDirectProvider = require("rizu.dlc.providers.OsuDirectProvider")

local test = {}

---@param t testing.T
function test.initialization(t)
	local provider = OsuDirectProvider({
		baseUrl = "https://example.com",
		downloadUrl = "https://example.com/d/%s"
	})
	t:eq(provider.baseUrl, "https://example.com")
	t:eq(provider.downloadUrl, "https://example.com/d/%s")
end

---@param t testing.T
function test.getDownloadUrl(t)
	local provider = OsuDirectProvider({
		baseUrl = "https://example.com",
		downloadUrl = "https://example.com/d/%s"
	})
	t:eq(provider:getDownloadUrl(12345), "https://example.com/d/12345")
end

return test
