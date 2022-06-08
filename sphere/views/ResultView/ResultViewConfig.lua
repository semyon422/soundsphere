local inspect = require("inspect")
local rtime = require("aqua.util.rtime")
local transform = {{1 / 2, -16 / 9 / 2}, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}
local transformLeft = {0, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}

local formatScore = function(score)
	score = tonumber(score) or math.huge
	if score >= 0.1 then
		return "100+"
	end
	return ("%2.2f"):format(score * 1000)
end

local formatDifficulty = function(difficulty)
	local format = "%.2f"
	if not difficulty then
		return ""
	elseif difficulty >= 10000 then
		format = "%s"
		difficulty = "????"
	elseif difficulty >= 100 then
		format = "%d"
	elseif difficulty > 9.995 then
		format = "%.1f"
	end
	return format:format(difficulty)
end

local showLoadedScore = function(self)
	if not self.game.rhythmModel.scoreEngine.scoreEntry then
		return
	end
	return self.game.selectModel.scoreItem.id == self.game.rhythmModel.scoreEngine.scoreEntry.id
end

local showLoadedListScore = function(self)
	return self.game.rhythmModel.scoreEngine.scoreEntry.id == self.id
end

local BackgroundBlurSwitch = {
	class = "GaussianBlurView",
	blur = {key = "game.configModel.configs.settings.graphics.blur.result"}
}

local Background = {
	class = "BackgroundView",
	transform = transform,
	x = 0,
	y = 0,
	w = 1920,
	h = 1080,
	parallax = 0.01,
	dim = {key = "game.configModel.configs.settings.graphics.dim.result"},
}

local Rectangle = {
	class = "RectangleView",
	transform = transform,
	rectangles = {
		{
			color = {1, 1, 1, 0.5},
			mode = "line",
			lineStyle = "smooth",
			lineWidth = 1,
			x = 279,
			y = 801,
			w = 1362,
			h = 190,
			rx = 0,
			ry = 0
		},
	}
}

local ComboGraph = {
	class = "PointGraphView",
	transform = transform,
	x = 279,
	y = 801,
	w = 1362,
	h = 190,
	radius = 1.5,
	color = {1, 1, 0.25, 1},
	background = true,
	backgroundColor = {0, 0, 0, 0.2},
	backgroundRadius = 4,
	key = "game.rhythmModel.scoreEngine.scoreSystem.sequence",
	time = "base.currentTime",
	value = "base.combo",
	unit = "base.noteCount",
	point = function(time, startTime, endTime, value, unit)
		local x = (time - startTime) / (endTime - startTime)
		local y = -value / unit + 1
		return x, y
	end,
	show = showLoadedScore
}

local perfectColor = {1, 1, 1, 1}
local notPerfectColor = {1, 0.6, 0.4, 1}
local HitGraph = {
	class = "PointGraphView",
	transform = transform,
	x = 279,
	y = 801,
	w = 1362,
	h = 190,
	radius = 1.5,
	color = function(time, startTime, endTime, value, unit)
		if math.abs(value) <= 0.016 then
			return perfectColor
		end
		return notPerfectColor
	end,
	background = true,
	backgroundColor = {0, 0, 0, 0.2},
	backgroundRadius = 4,
	key = "game.rhythmModel.scoreEngine.scoreSystem.sequence",
	time = "base.currentTime",
	value = "misc.deltaTime",
	unit = 0.16,
	point = function(time, startTime, endTime, value, unit)
		if math.abs(value) > 0.12 then
			return
		end
		local x = (time - startTime) / (endTime - startTime)
		local y = value / unit / 2 + 0.5
		return x, y
	end,
	show = showLoadedScore
}

local EarlyLateMissGraph = {
	class = "PointGraphView",
	transform = transform,
	x = 279,
	y = 801,
	w = 1362,
	h = 190,
	radius = 3,
	color = {1, 0.2, 0.2, 1},
	background = true,
	backgroundColor = {1, 1, 1, 1},
	backgroundRadius = 4,
	key = "game.rhythmModel.scoreEngine.scoreSystem.sequence",
	time = "base.currentTime",
	value = "misc.deltaTime",
	unit = 0.16,
	point = function(time, startTime, endTime, value, unit)
		if math.abs(value) <= 0.12 or math.abs(value) > 0.16 then
			return
		end
		local x = (time - startTime) / (endTime - startTime)
		local y = math.min(math.max(value, -0.16), 0.16) / unit / 2 + 0.5
		return x, y
	end,
	show = showLoadedScore
}

local MissGraph = {
	class = "PointGraphView",
	transform = transform,
	x = 279,
	y = 801,
	w = 1362,
	h = 190,
	radius = 1,
	color = {1, 0.6, 0.6, 1},
	background = true,
	backgroundColor = {1, 1, 1, 0},
	backgroundRadius = 3,
	key = "game.rhythmModel.scoreEngine.scoreSystem.sequence",
	time = "base.currentTime",
	value = "base.isMiss",
	unit = 0.16,
	line = function(time, startTime, endTime, value, unit)
		if not value then
			return
		end
		local x = (time - startTime) / (endTime - startTime)
		return x
	end,
	show = showLoadedScore
}

local HpGraph = {
	class = "PointGraphView",
	transform = transform,
	x = 279,
	y = 801,
	w = 1362,
	h = 190,
	radius = 1.5,
	color = {0.25, 1, 0.5, 1},
	background = true,
	backgroundColor = {0, 0, 0, 0.2},
	backgroundRadius = 4,
	key = "game.rhythmModel.scoreEngine.scoreSystem.sequence",
	time = "base.currentTime",
	value = "hp.hp",
	unit = "hp.allHp",
	point = function(time, startTime, endTime, value, unit)
		local x = (time - startTime) / (endTime - startTime)
		local y = -value / unit + 1
		return x, y
	end,
	show = showLoadedScore
}

local ScoreList = {
	class = "ScoreListView",
	transform = transform,
	x = 1187,
	y = 288,
	w = 454,
	h = 504,
	rows = 7,
	elements = {
		{
			type = "text",
			value = "rank",
			onNew = true,
			x = 22,
			baseline = 19,
			limit = 72,
			align = "right",
			font = {
				filename = "Noto Sans",
				size = 16,
			},
		},
		{
			type = "text",
			key = "rank",
			onNew = false,
			x = 22,
			baseline = 45,
			limit = 72,
			align = "right",
			font = {
				filename = "Noto Sans Mono",
				size = 24,
			},
		},
		{
			type = "text",
			value = "rating",
			onNew = true,
			x = 94,
			baseline = 19,
			limit = 72,
			align = "right",
			font = {
				filename = "Noto Sans",
				size = 16,
			},
		},
		{
			type = "text",
			onNew = false,
			format = formatDifficulty,
			x = 94,
			baseline = 45,
			limit = 72,
			align = "right",
			font = {
				filename = "Noto Sans Mono",
				size = 24,
			},
			value = function(self, item)
				if self.game.rhythmModel.scoreEngine.scoreEntry.id == item.id then
					local erfunc = require("libchart.erfunc")
					local ratingHitTimingWindow = self.game.configModel.configs.settings.gameplay.ratingHitTimingWindow
					local normalscore = self.game.rhythmModel.scoreEngine.scoreSystem.normalscore
					local s = erfunc.erf(ratingHitTimingWindow / (normalscore.accuracyAdjusted * math.sqrt(2)))
					return s * self.game.rhythmModel.scoreEngine.enps
				end
				local rating = item.rating
				if rating ~= rating then
					return "nan"
				end
				return rating
			end,
		},
		{
			type = "text",
			value = "time rate",
			onNew = true,
			x = 166,
			baseline = 19,
			limit = 94,
			align = "right",
			font = {
				filename = "Noto Sans",
				size = 16,
			},
		},
		{
			type = "text",
			key = {
				{"game.rhythmModel.scoreEngine.timeRate", showLoadedListScore},
				"timeRate"
			},
			onNew = false,
			x = 166,
			baseline = 45,
			limit = 94,
			align = "right",
			font = {
				filename = "Noto Sans Mono",
				size = 24,
			},
			format = function(timeRate)
				local exp = 10 * math.log(timeRate) / math.log(2)
				local roundedExp = math.floor(exp + 0.5)
				if math.abs(exp - roundedExp) % 1 < 1e-2 and math.abs(exp) > 1e-2 then
					return ("%dQ"):format(roundedExp)
				end
				return ("%.2f"):format(timeRate)
			end
		},
		{
			type = "text",
			value = "",
			onNew = true,
			x = 162,
			baseline = 19,
			limit = 270,
			align = "right",
			font = {
				filename = "Noto Sans",
				size = 16,
			},
		},
		{
			type = "text",
			key = "time",
			ago = true,
			onNew = false,
			x = 162,
			baseline = 19,
			limit = 270,
			align = "right",
			font = {
				filename = "Noto Sans",
				size = 16,
			},
		},
		{
			type = "text",
			key = {
				{"game.rhythmModel.scoreEngine.inputMode", showLoadedListScore},
				"inputMode"
			},
			x = 162,
			baseline = 45,
			limit = 270,
			align = "right",
			font = {
				filename = "Noto Sans",
				size = 24,
			},
		},
		{
			type = "circle",
			key = "loaded",
			mode = "line",
			onNew = false,
			x = 23,
			y = 36,
			r = 7
		},
		{
			type = "circle",
			key = "isTop",
			mode = "both",
			onNew = false,
			x = 23,
			y = 36,
			r = 7
		},
	},
}

local ScoreScrollBar = {
	class = "ScrollBarView",
	transform = transform,
	list = ScoreList,
	x = 1641,
	y = 288,
	w = 16,
	h = 504,
	rows = 11,
	backgroundColor = {1, 1, 1, 0.33},
	color = {1, 1, 1, 0.66}
}

local SongTitleView = {
	class = "ValueView",
	key = "game.noteChartModel.noteChartDataEntry.title",
	format = "%s",
	color = {1, 1, 1, 1},
	x = 279 + 44,
	baseline = 144 + 45,
	limit = math.huge,
	align = "left",
	font = {
		filename = "Noto Sans",
		size = 24,
	},
	transform = transform
}

local SongArtistView = {
	class = "ValueView",
	key = "game.noteChartModel.noteChartDataEntry.artist",
	format = "%s",
	color = {1, 1, 1, 1},
	x = 279 + 45,
	baseline = 144 + 19,
	limit = math.huge,
	align = "left",
	font = {
		filename = "Noto Sans",
		size = 16,
	},
	transform = transform
}

local ChartNameView = {
	class = "ValueView",
	key = "game.noteChartModel.noteChartDataEntry.name",
	format = "%s",
	color = {1, 1, 1, 1},
	x = 279 + 116 + 29,
	baseline = 216 + 45,
	limit = math.huge,
	align = "left",
	font = {
		filename = "Noto Sans",
		size = 24,
	},
	transform = transform
}

local ChartCreatorView = {
	class = "ValueView",
	key = "game.noteChartModel.noteChartDataEntry.creator",
	format = "%s",
	color = {1, 1, 1, 1},
	x = 279 + 117 + 29,
	baseline = 216 + 19,
	limit = math.huge,
	align = "left",
	font = {
		filename = "Noto Sans",
		size = 16,
	},
	transform = transform
}

local ChartInputModeView = {
	class = "ValueView",
	key = "game.noteChartModel.noteChartDataEntry.inputMode",
	format = "%s",
	color = {1, 1, 1, 1},
	x = 279 + 29 + 17,
	baseline = 216 + 19,
	limit = 500,
	align = "left",
	font = {
		filename = "Noto Sans",
		size = 16,
	},
	transform = transform
}

local ChartDifficultyView = {
	class = "ValueView",
	key = "game.noteChartModel.noteChartDataEntry.difficulty",
	color = {1, 1, 1, 1},
	x = 279 + 29,
	baseline = 216 + 45,
	limit = 72,
	align = "right",
	font = {
		filename = "Noto Sans Mono",
		size = 24,
	},
	transform = transform,
	format = formatDifficulty
}

local StageInfo = {
	class = "StageInfoView",
	transform = transform,
	x = 279,
	y = 279,
	w = 454,
	h = 522,
	smallCell = {
		x = {0, 113, 227, 340, 452, 565, 678, 791},
		y = {0, 50, 101, 152, 319, 370, 421, 472},
		name = {
			x = 22,
			baseline = 18,
			limit = 69,
			align = "right",
			font = {
				filename = "Noto Sans",
				size = 16,
			},
		},
		value = {
			text = {
				x = 22,
				baseline = 44,
				limit = 70,
				align = "right",
				font = {
					filename = "Noto Sans",
					size = 24,
				},
			},
			bar = {
				x = 22,
				y = 26,
				w = 70,
				h = 19
			}
		}
	},
	largeCell = {
		x = {454, 454 + 227},
		y = {225},
		name = {
			x = 22,
			baseline = 15,
			limit = 160,
			align = "right",
			font = {
				filename = "Noto Sans",
				size = 18,
			},
		},
		value = {
			text = {
				x = 22,
				baseline = 49,
				limit = 161,
				align = "right",
				font = {
					filename = "Noto Sans",
					size = 36,
				},
			}
		}
	}
}

StageInfo.cells = {
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = {3, 4}, y = 2,
		name = "bpm",
		value = function(self)
			local show = showLoadedScore(self)
			local baseBpm = self.game.selectModel.noteChartItem.bpm
			local bpm = self.game.rhythmModel.scoreEngine.bpm
			if not show then
				return math.floor(baseBpm)
			end
			if bpm == baseBpm then
				return math.floor(bpm)
			end
			return ("%d→%d"):format(baseBpm, bpm)
		end,
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = {2, 4}, y = 3,
		name = "duration",
		value = function(self)
			local show = showLoadedScore(self)
			local baseLength = self.game.selectModel.noteChartItem.length
			local length = self.game.rhythmModel.scoreEngine.length
			if not show then
				return rtime(baseLength)
			end
			if length == baseLength then
				return rtime(length)
			end
			return ("%s→%s"):format(rtime(baseLength), rtime(length))
		end,
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = 2, y = 3,
		name = "density",
		key = {
			{"game.rhythmModel.scoreEngine.enps", showLoadedListScore},
			"game.selectModel.scoreItem.difficulty"
		},
		format = formatDifficulty,
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = 2, y = 2,
		name = "time rate",
		key = {
			{"game.rhythmModel.scoreEngine.baseTimeRate", showLoadedListScore},
			"game.selectModel.scoreItem.timeRate"
		},
		format = "%0.2f",
	},

	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = 4, y = 4,
		name = "notes",
		key = "game.selectModel.noteChartItem.noteCount"
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = 1, y = 4,
		name = "level",
		key = "game.selectModel.noteChartItem.level"
	},
	{
		type = StageInfo.largeCell,
		valueType = "text",
		x = 1, y = 1,
		name = "accuracy",
		key = {
			{"game.rhythmModel.scoreEngine.scoreSystem.normalscore.accuracyAdjusted", showLoadedScore},
			"game.selectModel.scoreItem.accuracy"
		},
		format = formatScore
	},
	{
		type = StageInfo.largeCell,
		valueType = "text",
		x = 2, y = 1,
		name = "score",
		value = function(self)
			if showLoadedScore(self) then
				local erfunc = require("libchart.erfunc")
				local ratingHitTimingWindow = self.game.configModel.configs.settings.gameplay.ratingHitTimingWindow
				local normalscore = self.game.rhythmModel.scoreEngine.scoreSystem.normalscore
				return ("%d"):format(
					erfunc.erf(ratingHitTimingWindow / (normalscore.accuracyAdjusted * math.sqrt(2))) * 10000
				)
			end
			local score = self.game.selectModel.scoreItem.score
			if score ~= score then
				return "nan"
			end
			return ("%d"):format(score)
		end,
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = 8, y = 3,
		name = "pauses",
		key = "game.selectModel.scoreItem.pausesCount",
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = {7, 8}, y = 4,
		name = "adjust",
		key = "game.rhythmModel.scoreEngine.scoreSystem.normalscore.adjustRatio",
		format = function(adjustRatio)
			if adjustRatio ~= adjustRatio then
				adjustRatio = 1
			end
			return ("%d%%"):format((1 - adjustRatio) * 100)
		end,
		show = showLoadedScore
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = {6, 7}, y = 3,
		name = "new diff.",
		key = "game.rhythmModel.scoreEngine.ratingDifficulty",
		format = "%0.2f",
		show = showLoadedScore
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = {6, 7}, y = 4,
		name = "new rating",
		format = "%0.2f",
		show = showLoadedScore,
		value = function(self)
			local erfunc = require("libchart.erfunc")
			local ratingHitTimingWindow = self.game.configModel.configs.settings.gameplay.ratingHitTimingWindow
			local normalscore = self.game.rhythmModel.scoreEngine.scoreSystem.normalscore
			local s = erfunc.erf(ratingHitTimingWindow / (normalscore.accuracyAdjusted * math.sqrt(2)))
			return s * self.game.rhythmModel.scoreEngine.ratingDifficulty
		end,
	},

	{
		type = StageInfo.smallCell,
		valueType = "bar",
		x = {1, 2}, y = 5,
		name = "perfect/hits",
		key = {
			{"game.rhythmModel.scoreEngine.scoreSystem.misc.ratio", showLoadedScore},
			"game.selectModel.scoreItem.ratio"
		},
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = 3, y = 5,
		name = "perfect",
		key = {
			{"game.rhythmModel.scoreEngine.scoreSystem.judgement.counters.soundsphere.perfect", showLoadedScore},
			"game.selectModel.scoreItem.perfect"
		},
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = {2, 3}, y = 6,
		name = "not perfect",
		key = {
			{"game.rhythmModel.scoreEngine.scoreSystem.judgement.counters.soundsphere.not perfect", showLoadedScore},
			"game.selectModel.scoreItem.notPerfect"
		},
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = 3, y = 7,
		name = "miss",
		key = {
			{"game.rhythmModel.scoreEngine.scoreSystem.base.missCount", showLoadedScore},
			"game.selectModel.scoreItem.missCount"
		},
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = 2, y = 7,
		name = "spam",
		key = "game.rhythmModel.scoreEngine.scoreSystem.base.earlyHitCount",
		show = showLoadedScore,
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = {3, 4}, y = 6,
		name = "early/late",
		key = {
			{"game.rhythmModel.scoreEngine.scoreSystem.misc.earlylate", showLoadedScore},
			"game.selectModel.scoreItem.earlylate"
		},
		format = function(earlylate)
			if earlylate == 0 then
				return "undef"
			elseif earlylate > 1 then
				return ("-%d%%"):format((earlylate - 1) * 100)
			elseif earlylate < 1 then
				return ("%d%%"):format((1 / earlylate - 1) * 100)
			end
			return "0%"
		end
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = 4, y = 5,
		name = "mean",
		multiplier = 1000,
		format = "%0.1f",
		key = {
			{"game.rhythmModel.scoreEngine.scoreSystem.normalscore.normalscore.mean", showLoadedScore},
			"game.selectModel.scoreItem.mean"
		},
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = {3, 4}, y = 7,
		name = "max delta",
		multiplier = 1000,
		format = "%d",
		key = "game.rhythmModel.scoreEngine.scoreSystem.misc.maxDeltaTime",
		show = showLoadedScore
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = 1, y = 7,
		name = "",
		key = "game.rhythmModel.scoreEngine.scoreSystem.hp.failed",
		format = function(failed)
			if failed then
				return "fail"
			end
			return "pass"
		end,
		show = showLoadedScore
	},
}

local ModifierIconGrid = {
	class = "ModifierIconGridView",
	transform = transform,
	x = 755,
	y = 598,
	w = 410,
	h = 136,
	columns = 6,
	rows = 2,
	noModifier = true,
	config = {
		{"game.modifierModel.config", showLoadedScore},
		"game.selectModel.scoreItem.modifiers"
	},
}

local BottomScreenMenu = {
	class = "ScreenMenuView",
	transform = transform,
	x = 279,
	y = 991,
	w = 227,
	h = 89,
	rows = 1,
	columns = 1,
	text = {
		x = 0,
		baseline = 54,
		limit = 227,
		align = "center",
		font = {
			filename = "Noto Sans",
			size = 24,
		},
	},
	items = {
		{
			{
				method = "back",
				displayName = "back"
			}
		}
	}
}

local BottomRightScreenMenu = {
	class = "ScreenMenuView",
	transform = transform,
	x = 1187,
	y = 991,
	w = 454,
	h = 89,
	rows = 1,
	columns = 2,
	text = {
		x = 0,
		baseline = 54,
		limit = 227,
		align = "center",
		font = {
			filename = "Noto Sans",
			size = 24,
		},
	},
	items = {
		{
			{
				method = "play",
				value = "replay",
				displayName = "replay"
			},
			{
				method = "play",
				value = "retry",
				displayName = "retry"
			},
		}
	}
}

local SessionTime = {
	class = "ValueView",
	transform = transform,
	value = function()
		local event = require("aqua.event")
		local rtime = require("aqua.util.rtime")
		return rtime(event.time - event.startTime)
	end,
	x = 301,
	baseline = 279 + 522 - 6,
	limit = 1920,
	color = {1, 1, 1, 1},
	font = {
		filename = "Noto Sans",
		size = 20,
	},
	align = "left",
}

local MatchPlayers = {
	class = "MatchPlayersView",
	transform = transformLeft,
	key = "game.multiplayerModel.roomUsers",
	x = 20,
	y = 540,
	font = {
		filename = "Noto Sans Mono",
		size = 24
	},
}

local InspectScoreSystem = {
	class = "ValueView",
	subscreen = "scoreSystemDebug",
	transform = transformLeft,
	key = "game.rhythmModel.scoreEngine.scoreSystem.slice",
	format = function(...)
		return inspect(...)
	end,
	x = 0,
	baseline = 20,
	limit = 1920,
	font = {
		filename = "Noto Sans Mono",
		size = 14,
	},
	align = "left",
	color = {1, 1, 1, 1}
}

local InspectCounters = {
	class = "ValueView",
	subscreen = "countersDebug",
	transform = transformLeft,
	key = "game.rhythmModel.scoreEngine.scoreSystem.judgement.counters",
	format = function(...)
		return inspect(...)
	end,
	x = 0,
	baseline = 20,
	limit = 1920,
	font = {
		filename = "Noto Sans Mono",
		size = 14,
	},
	align = "left",
	color = {1, 1, 1, 1}
}

local InspectScoreEntry = {
	class = "ValueView",
	subscreen = "scoreEntryDebug",
	transform = transformLeft,
	key = "game.selectModel.scoreItem",
	format = function(...)
		return inspect(...)
	end,
	x = 0,
	baseline = 20,
	limit = 1920,
	font = {
		filename = "Noto Sans Mono",
		size = 14,
	},
	align = "left",
	color = {1, 1, 1, 1}
}

local NoteSkinViewConfig = {
	BackgroundBlurSwitch,
	Background,
	BackgroundBlurSwitch,
	BottomScreenMenu,
	BottomRightScreenMenu,
	Rectangle,
	require("sphere.views.HeaderViewConfig"),
	SongTitleView,
	SongArtistView,
	ChartNameView,
	ChartCreatorView,
	ChartInputModeView,
	ChartDifficultyView,
	StageInfo,
	ModifierIconGrid,
	ScoreList,
	ScoreScrollBar,
	MissGraph,
	HitGraph,
	ComboGraph,
	HpGraph,
	EarlyLateMissGraph,
	SessionTime,
	MatchPlayers,
	InspectScoreSystem,
	InspectCounters,
	InspectScoreEntry,
	require("sphere.views.DebugInfoViewConfig"),
}

return NoteSkinViewConfig
