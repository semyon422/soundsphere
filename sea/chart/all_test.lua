local Chartplay = require("sea.chart.Chartplay")
local Chartplays = require("sea.chart.Chartplays")
local Leaderboards = require("sea.chart.Leaderboards")
local FakeChartplayComputer = require("sea.chart.FakeChartplayComputer")
local FakeYieldingRemote = require("sea.remotes.FakeYieldingRemote")
local FakeChartplaysRepo = require("sea.chart.repos.FakeChartplaysRepo")
local FakeChartfilesRepo = require("sea.chart.repos.FakeChartfilesRepo")
local FakeChartdiffsRepo = require("sea.chart.repos.FakeChartdiffsRepo")
local User = require("sea.access.User")

local test = {}

---@param t testing.T
function test.submit_score(t)
	local chartplaysRepo = FakeChartplaysRepo()
	local chartfilesRepo = FakeChartfilesRepo()
	local chartdiffsRepo = FakeChartdiffsRepo()
	local fakeChartplayComputer = FakeChartplayComputer()
	local leaderboards = Leaderboards()

	---@type sea.ISubmissionClientRemote
	local remote = FakeYieldingRemote()

	local cps = Chartplays(
		chartplaysRepo,
		chartfilesRepo,
		chartdiffsRepo,
		fakeChartplayComputer,
		leaderboards
	)

	local chartplay_values = Chartplay()
	chartplay_values.hash = "hash"
	chartplay_values.events_hash = "events_hash"
	chartplay_values.notes_hash = "notes_hash"

	local user = User()
	user.id = 1

	---@type sea.Chartplay, string?
	local chartplay, err
	local done = false
	local resume = coroutine.wrap(function()
		chartplay, err = cps:submit(user, remote, chartplay_values)
		t:assert(chartplay, err)
		t:assert(chartplay.user_id)
		t:assert(chartplay.compute_state == "valid")
		done = true
	end)

	t:eq(resume(), "hash")
	local chartfile = chartfilesRepo:getChartfileByHash("hash")
	chartfile.submitted_at = 0
	t:eq(resume(true), "events_hash")
	local chartplay = chartplaysRepo:getChartplayByEventsHash("events_hash")
	chartplay.submitted_at = 0
	t:eq(resume(true))

	t:assert(done)
end

return test
