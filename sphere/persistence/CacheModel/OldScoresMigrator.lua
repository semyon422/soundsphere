local class = require("class")
local LjsqliteDatabase = require("rdb.LjsqliteDatabase")
local TableOrm = require("rdb.TableOrm")
local ModifierEncoder = require("sphere.models.ModifierEncoder")

---@class sphere.OldScoresMigrator
---@operator call: sphere.OldScoresMigrator
local OldScoresMigrator = class()

---@param gdb sphere.GameDatabase
function OldScoresMigrator:new(gdb)
	self.gdb = gdb
end

function OldScoresMigrator:migrate()
	local db = LjsqliteDatabase()
	local orm = TableOrm(db)

	db:open("userdata/scores.db")
	local scores = orm:select("scores")
	db:close()

	print("total scores: " .. #scores)

	local new_scores = {}
	for _, old_score in ipairs(scores) do
		local score = self:convertScore(old_score)
		table.insert(new_scores, score)
	end
	self.gdb.models.scores:insert(new_scores)
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

	local info = ModifierEncoder:decodeOld(old_score)
	score.modifiers = info.modifiers
	score.rate = info.rate
	score.const = info.const
	score.is_exp_rate = info.is_exp_rate

	return score
end

return OldScoresMigrator
