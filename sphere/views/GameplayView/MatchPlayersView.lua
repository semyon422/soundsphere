local Class = require("aqua.util.Class")
local transform = require("aqua.graphics.transform")
local spherefonts = require("sphere.assets.fonts")
local inside = require("aqua.util.inside")
local erfunc = require("libchart.erfunc")

local MatchPlayersView = Class:new()

MatchPlayersView.load = function(self)
	local config = self.config
	local state = self.state
end

MatchPlayersView.draw = function(self)
	local config = self.config
	local state = self.state

	local tf = transform(config.transform)
	love.graphics.replaceTransform(tf)

	love.graphics.setColor(1, 1, 1, 1)

	local font = spherefonts.get(config.font)
	love.graphics.setFont(font)

	local users = inside(self, config.key)

	local window = self.gameController.configModel.configs.settings.gameplay.ratingHitTimingWindow

	local scores = {}
	for i, user in ipairs(users) do
		local accuracy = user.score.accuracy or math.huge
		scores[i] = {
			name = user.name or "?",
			score = erfunc.erf(window / (accuracy * math.sqrt(2))) * 10000,
			failed = user.score.failed,
		}
	end
	table.sort(scores, function(a, b)
		return a.score > b.score
	end)

	local rows = {}
	for i, score in ipairs(scores) do
		rows[i] = ("#%d: %d, %s"):format(i, score.score, score.name)
		if score.failed then
			rows[i] = rows[i] .. " (failed)"
		end
	end

	love.graphics.printf(table.concat(rows, "\n"), config.x, config.y, math.huge, config.align or "left")
end

return MatchPlayersView
