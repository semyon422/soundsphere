local UserConnections = require("sea.app.UserConnections")
local UserConnectionsRepo = require("sea.app.repos.UserConnectionsRepo")
local FakeSharedDict = require("web.nginx.FakeSharedDict")
local Message = require("icc.Message")
local User = require("sea.access.User")

local test = {}

---@param t testing.T
function test.full_call(t)
	local dict = FakeSharedDict()
	local repo = UserConnectionsRepo(dict)
	local users_repo = {
		getUser = function(self, id)
			local u = User()
			u.id = id
			u.name = "user" .. id
			return u
		end
	}
	local uc = UserConnections(repo, users_repo)

	-- Setup handlers
	local tbl = {
		getRandomNumber = function(self)
			return 42
		end
	}
	local whitelist = {getRandomNumber = true}
	uc:setup(tbl, whitelist, whitelist)

	local ip1, port1 = "1.1.1.1", 1
	local sid1 = ip1 .. ":" .. port1
	local ip2, port2 = "2.2.2.2", 2
	local sid2 = ip2 .. ":" .. port2

	uc:onConnect(sid1, 1)
	uc:onConnect(sid2, 2)

	-- Connection 1 wants to call Connection 2
	local peer2_from_1 = uc:getPeer(sid2, sid1)
	---@cast peer2_from_1 -?

	---@type integer?
	local result
	local done = false
	coroutine.wrap(function()
		result = peer2_from_1.remote:getRandomNumber()
		done = true
	end)()

	-- Verify and handle call in connection 2
	-- In reality, connection 2's background loop would call processQueue
	local th2 = uc:createClientTaskHandler(tbl)
	uc:processQueue(sid2, th2)

	-- Verify and handle return in connection 1
	local th1 = uc:createClientTaskHandler(tbl)
	uc:processQueue(sid1, th1)

	t:assert(done)
	t:eq(result, 42)
end

return test
