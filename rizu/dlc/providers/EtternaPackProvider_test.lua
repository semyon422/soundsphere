local EtternaPackProvider = require("rizu.dlc.providers.EtternaPackProvider")

local test = {}

---@param t testing.T
function test.getDownloadUrl(t)
	local provider = EtternaPackProvider()
	local url = provider:getDownloadUrl("Test Pack")
	-- It should escape the name
	t:eq(url, "https://downloads.etternaonline.com/ranked/Test%20Pack.zip")
end

---@param t testing.T
function test.search_url_construction(t)
	local provider = EtternaPackProvider()
	-- Since we can't easily mock http_util.request without a framework,
	-- we'll at least verify the provider is initialized correctly.
	t:eq(provider.apiUrl, "https://api.etternaonline.com/api/packs")
end

return test
