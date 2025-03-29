local class = require("class")

---@class sea.UserPage
---@operator call: sea.UserPage
local UserPage = class()

UserPage.activityWeeks = 53

---@param users_access sea.UsersAccess
---@param session_user sea.User
---@param target_user sea.User
function UserPage:new(users_access, session_user, target_user)
	self.usersAccess = users_access
	self.sessionUser = session_user
	self.targetUser = target_user
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

return UserPage
