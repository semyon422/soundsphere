local md5 = require("md5")
local Chartplay = require("sea.chart.Chartplay")
local Chartplays = require("sea.chart.Chartplays")
local Leaderboards = require("sea.chart.Leaderboards")
local TableStorage = require("sea.chart.storage.TableStorage")
local FakeChartplayComputer = require("sea.chart.FakeChartplayComputer")
local FakeSubmissionClientRemote = require("sea.remotes.FakeSubmissionClientRemote")
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

	local cps = Chartplays(
		chartplaysRepo,
		chartfilesRepo,
		chartdiffsRepo,
		fakeChartplayComputer,
		TableStorage(),
		TableStorage(),
		leaderboards
	)

	local chartfile_data = "chart"
	local replayfile_data = "replay"

	local remote = FakeSubmissionClientRemote(chartfile_data, replayfile_data)

	local chartplay_values = Chartplay()
	chartplay_values.hash = md5.sumhexa(chartfile_data)
	chartplay_values.events_hash = md5.sumhexa(replayfile_data)
	chartplay_values.notes_hash = "notes_hash"

	local user = User()
	user.id = 1

	local chartplay, err = cps:submit(user, remote, chartplay_values)

	if t:assert(chartplay, err) then
		---@cast chartplay -?
		t:assert(chartplay.user_id)
		t:assert(chartplay.compute_state == "valid")
	end
end

return test
