local class = require("class")

local ModifierModel = require("sphere.models.ModifierModel")

---@class sea.ChartPage
---@operator call: sea.ChartPage
local ChartPage = class()

---@param user sea.User
---@param chartmeta sea.Chartmeta
---@param chartplays sea.Chartplay[]
function ChartPage:new(user, chartmeta, chartplays)
	self.user = user
	self.chartmeta = chartmeta
	self.chartplays = chartplays
	self.rating_calc = self:getPreferredRatingCalc()
end

---@return string
function ChartPage:getPreferredRatingCalc()
	return self.user.preferred_rating_calc or "pp"
end

---@param time number
function ChartPage:formatTimeAgo(time)
	local time_ago = os.time() - time
	local days = math.floor(time_ago / (60 * 60 * 24))
	local hours = math.floor(time_ago / (60 * 60))
	local minutes = math.floor(time_ago / 60)

	if minutes < 60 then
		return ("%imin"):format(minutes)
	elseif hours < 24 then
		return ("%ih"):format(hours)
	else
		return ("%id"):format(days)
	end
end

---@param cpv sea.Chartplay
---@return string
function ChartPage:formatModifiers(cpv)
	local modifiers = ""

	if #cpv.modifiers ~= 0 then
		modifiers = ModifierModel:getString(cpv.modifiers)
		modifiers = modifiers .. " "
	end

	if cpv.const then
		modifiers = modifiers .. "CONST "
	end

	if cpv.tap_only then
		modifiers = modifiers .. "TAP "
	end

	if modifiers == "" then
		modifiers = "-"
	end

	return modifiers
end

---@param cpv sea.Chartplay
---@return number
function ChartPage:getRating(cpv)
	if self.rating_calc == "pp" then
		return cpv.rating_pp
	elseif self.rating_calc == "msd" then
		return cpv.rating_msd
	end

	return cpv.rating
end

function ChartPage:getScores()
	local scores = {}

	for rank, cpv in ipairs(self.chartplays) do
		table.insert(scores, {
			rank = rank,
			username = "Username",
			flag = "gb",
			grade = cpv:getGrade(),
			accuracy = cpv.accuracy,
			norm_accuracy = cpv:getNormAccuracy(),
			perfect_count = cpv.judges[1],
			not_perfect_count = cpv.not_perfect_count,
			miss_count = cpv.miss_count,
			modifiers = self:formatModifiers(cpv),
			rate = cpv.rate,
			rating = self:getRating(cpv),
			time_ago = self:formatTimeAgo(cpv.submitted_at)
		})
	end

	return scores
end

return ChartPage
