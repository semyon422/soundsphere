local class = require("class")
local ComputeDataLoader = require("sea.compute.ComputeDataLoader")

---@class sea.ChartplaySubmission
---@operator call: sea.ChartplaySubmission
local ChartplaySubmission = class()

---@param chartplays sea.Chartplays
---@param leaderboards sea.Leaderboards
---@param users sea.Users
---@param dans sea.Dans
function ChartplaySubmission:new(chartplays, leaderboards, users, dans)
	self.chartplays = chartplays
	self.leaderboards = leaderboards
	self.users = users
	self.dans = dans
end

---@param user sea.User
---@param time integer
---@param remote sea.ClientRemote
---@param chartplay_values sea.Chartplay
---@param chartdiff_values sea.Chartdiff
---@return sea.Chartplay?
---@return string?
function ChartplaySubmission:submitChartplay(user, time, remote, chartplay_values, chartdiff_values)
	local compute_data_loader = ComputeDataLoader(remote.compute_data_provider)

	local chartplay, err = self.chartplays:submit(user, time, compute_data_loader, chartplay_values, chartdiff_values)
	if not chartplay then
		return nil, err
	end

	if not chartplay.custom then
		self.leaderboards:addChartplay(chartplay)
	end

	user = self.users:getUser(user.id)

	user.latest_activity = time
	user.play_time = user.play_time + chartdiff_values.duration
	user.chartplays_upload_size = user.chartplays_upload_size + compute_data_loader.replays_size
	user.chartfiles_upload_size = user.chartfiles_upload_size + compute_data_loader.charts_size
	user.chartplays_count = self.chartplays.charts_repo:getUserChartplaysCount(user.id)
	user.chartmetas_count = self.chartplays.charts_repo:getUserChartmetasCount(user.id)
	user.chartdiffs_count = self.chartplays.charts_repo:getUserChartdiffsCount(user.id)

	self.users.users_repo:updateUser(user)

	if self.dans:isDan(chartdiff_values) then
		local dan_clear, err = self.dans:submit(user, chartplay, chartdiff_values, time)
		remote:print(dan_clear and "dan cleared" or err)
	end

	local leaderboard_users = self.leaderboards:getUserLeaderboardUsers(user)
	if leaderboard_users then
		remote.client:setLeaderboardUsers(leaderboard_users)
	end

	return chartplay
end

return ChartplaySubmission
