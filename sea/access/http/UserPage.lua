local class = require("class")
local time_util = require("time_util")
local ModifierModel = require("sphere.models.ModifierModel")

---@class sea.UserPage
---@operator call: sea.UserPage
local UserPage = class()

UserPage.activityWeeks = 53

---@param users_access sea.UsersAccess
---@param session_user sea.User
---@param target_user sea.User
---@param leaderboards sea.Leaderboards
function UserPage:new(users_access, session_user, target_user, leaderboards)
	self.usersAccess = users_access
	self.sessionUser = session_user
	self.targetUser = target_user
	self.leaderboards = leaderboards
end

---@return boolean
function UserPage:canUpdate()
	return self.usersAccess:canUpdateSelf(self.sessionUser, self.targetUser, os.time())
end

---@param activity {[string]: number} activity key should have %d-%m-%Y format
function UserPage:setActivity(activity)
	self.activity = activity

	self.currentDate = os.date("*t", os.time())
	self.currentDateStartTime = os.time({
		year = self.currentDate.year,
		month = self.currentDate.month,
		day = self.currentDate.day
	})
	self.currentWeekDay = self.currentDate.wday -- Sunday is 1 | Saturday is 7
	self.maxDays = self.activityWeeks * 7 - (7 - self.currentWeekDay)
end

---@return { name: string, span: number }[]
function UserPage:getActivityWeekLabels()
	local t = {}
	local current_month_name
	local span = 0

	for week = 1, self.activityWeeks do
		local delta = (((week - 1) * 7) + 1) - self.maxDays
		local month = os.date("%b", self.currentDateStartTime + (delta * 60 * 60 * 24))

		if not current_month_name then
			current_month_name = month
			span = span + 1
		elseif month ~= current_month_name then
			table.insert(t, { name = current_month_name, span = span })
			current_month_name = month
			span = 1
		else
			span = span + 1
		end
	end

	table.insert(t, { name = current_month_name, span = span })
	return t
end

---@param week_num number
---@return string?
function UserPage:getActivityWeekDayLabel(week_num)
	if week_num == 2 then
		return "Mon"
	elseif week_num == 4 then
		return "Wed"
	elseif week_num == 6 then
		return "Fri"
	end
end

---@return { date: string, activity: integer }[]
--- Returns a table of rows. Row is a day of the week.
--- Activity is a number from 0 to 4.
function UserPage:getActivityRectangles()
	local rows = {}

	for week_day = 1, 7 do
		local rectangles = self.currentWeekDay >= week_day and self.activityWeeks or (self.activityWeeks - 1)
		local row = {}

		for week = 1, rectangles do
			local delta = (((week - 1) * 7) + week_day) - self.maxDays
			local date = os.date("%d-%m-%Y", self.currentDateStartTime + (delta * 60 * 60 * 24))
			local activity = math.min(4, math.ceil((self.activity[date] or 0) / 10))
			table.insert(row, { date = date, activity = activity })
		end

		table.insert(rows, row)
	 end

	return rows
end

---@return string
function UserPage:formatLastSeen()
	return time_util.time_ago_in_words(self.targetUser.latest_activity)
end

---@return string
function UserPage:formatPlayTime()
	local play_time = self.targetUser.play_time
	local hours = math.floor(play_time / 3600)
	local minutes = math.floor(play_time % 3600 / 60)

	if minutes < 1 then
		return ("No play time")
	elseif hours < 1 then
		return ("%i minutes"):format(minutes)
	end

	return ("%i hours"):format(hours)
end

---@return string
function UserPage:formatRole()
	if self.targetUser:hasRole("owner", os.time(), true) then
		return "Project leader"
	elseif self.targetUser:hasRole("admin", os.time(), true) then
		return "Admin"
	elseif self.targetUser:hasRole("moderator", os.time(), true) then
		return "Moderator"
	end

	return ""
end

---@return {label: string, value: string}[]
function UserPage:getGeneralStats()
	local cells = {}
	-- TODO: Get these values from the main leaderboard.
	-- TODO: People have their preferences in rating calculators, let them choose one or two options in the settings. This is a personal option.
	table.insert(cells, { label = "PP", value = "15028" })
	table.insert(cells, { label = "MSD", value = "33.42" })

	-- Accuracy should always be displayed
	table.insert(cells, { label = "Accuracy", value = "90.81%" })

	-- The owner of the profile decides which dans to display
	table.insert(cells, { label = "4K Regular dan", value = "Delta" })
	table.insert(cells, { label = "Satellite", value = "Lv.6" })

	return cells
end

---@param lb sea.Leaderboard
---@param user_id integer
---@return table
function UserPage:getScores(lb, user_id)
	local chartplayviews = self.leaderboards:getBestChartplaysFull(lb, user_id)

	local scores = {}

	for i, cpv in ipairs(chartplayviews) do
		local chartmeta = cpv.chartmeta
		local chartdiff = cpv.chartdiff
		scores[i] = {
			artist = chartmeta and chartmeta.artist or "?",
			title = chartmeta and chartmeta.title or "?",
			name = chartmeta and chartmeta.name or "?",
			creator = chartmeta and chartmeta.creator or "?",
			timeRate = chartdiff and chartdiff.rate or "?",
			mods = ModifierModel:getString(cpv.modifiers),
			accuracy = cpv.accuracy,
			norm_accuracy = cpv:getNormAccuracy(),
			exscore = cpv:getExScore(),
			timeSince = time_util.time_ago_in_words(cpv.created_at),
			grade = cpv:getGrade(),
			rating = cpv.rating,
			ratingPostfix = "ENPS",
		}
	end

	return scores
end

return UserPage
