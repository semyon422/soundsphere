local class = require("class")
local LjsqliteDatabase = require("rdb.LjsqliteDatabase")
local TableOrm = require("rdb.TableOrm")
local ModifierEncoder = require("sphere.models.ModifierEncoder")

---@class sphere.OldScoresMigrator
---@operator call: sphere.OldScoresMigrator
local OldScoresMigrator = class()

---@param chartRepo sphere.ChartRepo
function OldScoresMigrator:new(chartRepo)
	self.chartRepo = chartRepo
end

function OldScoresMigrator:migrate()
	local chartRepo = self.chartRepo

	local db = LjsqliteDatabase()
	local orm = TableOrm(db)

	db:open("userdata/scores.db")

	local scores = orm:select("scores")
	print("total scores: " .. #scores)

	local new_scores = {}
	for _, old_score in ipairs(scores) do
		local score = self:convertScore(old_score)
		table.insert(new_scores, score)
	end
	orm:begin()
	print("begin")
	chartRepo.models.scores:insert(new_scores)
	print("commit")
	orm:commit()

	db:close()
end

function OldScoresMigrator:convertScore(old_score)
	local score = {
		hash = old_score.chart_hash,
		index = old_score.chart_index,
		modifiers = {},
		rate = old_score.rate,

		const = false,
		timings = "",
		single = false,

		time = old_score.time,
		accuracy = old_score.accuracy,
		max_combo = old_score.max_combo,
		replay_hash = old_score.replay_hash,
		ratio = old_score.ratio,
		perfect = old_score.perfect,
		not_perfect = old_score.not_perfect,
		miss = old_score.miss,
		mean = old_score.mean,
		earlylate = old_score.earlylate,
		pauses = old_score.pauses,
	}

	local modifiers, rate, const = ModifierEncoder:decodeOld(old_score)
	score.modifiers = modifiers
	score.rate = rate
	score.const = const

	return score
end

return OldScoresMigrator
