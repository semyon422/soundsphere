local Class = require("aqua.util.Class")
local transform = require("aqua.graphics.transform")
local spherefonts = require("sphere.assets.fonts")
local inside = require("aqua.util.inside")
local erfunc = require("libchart.erfunc")
local just = require("just")
local Format = require("sphere.views.Format")

local MatchPlayersView = Class:new()

MatchPlayersView.draw = function(self)
	local users = inside(self, self.key)

	local window = self.game.configModel.configs.settings.gameplay.ratingHitTimingWindow

	local scores = {}
	for i, user in ipairs(users) do
		local accuracy = user.score.accuracy or math.huge
		scores[i] = {
			name = user.name or "?",
			accuracy = accuracy,
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

	local tf = transform(self.transform)
	love.graphics.replaceTransform(tf)

	love.graphics.setColor(1, 1, 1, 1)
	local font = spherefonts.get(unpack(self.font))
	love.graphics.setFont(font)

	love.graphics.translate(self.x, self.y)
	for i, score in ipairs(scores) do
		local twidth = 300
		local theight = font:getHeight() * 2

		love.graphics.setColor(0, 0, 0, 0.5)
		love.graphics.rectangle("fill", 0, 0, twidth, theight, theight / 6)
		love.graphics.setColor(1, 1, 1, 0.5)
		love.graphics.rectangle("line", 0, 0, twidth, theight, theight / 6)

		love.graphics.setColor(1, 1, 1, 1)
		just.text(("#%d: %s"):format(i, score.name))
		just.text(("%5d, %s"):format(score.score, Format.accuracy(score.accuracy)))
		if score.failed then
			just.sameline()
			just.text(" failed")
		end
		just.emptyline(theight / 4)
	end
end

return MatchPlayersView
