local MinoProvider = require("rizu.dlc.providers.MinoProvider")

local test = {}

---@param t testing.T
function test.search(t)
	local provider = MinoProvider()
	
	-- We can't easily test real HTTP in a unit test without mocks, 
	-- but we can at least check if it handles non-chart types correctly.
	local results, err = provider:search("test", "skin")
	t:eq(err, nil)
	t:tdeq(results, {})
end

---@param t testing.T
function test.getDownloadUrl(t)
	local provider = MinoProvider()
	local url = provider:getDownloadUrl(12345)
	t:eq(url, "https://catboy.best/d/12345")
end

return test
