local View = require("yi.views.View")
local Label = require("yi.views.Label")
local Image = require("yi.views.Image")
local Colors = require("yi.Colors")
local h = require("yi.h")

local ModifierEncoder = require("sphere.models.ModifierEncoder")
local ModifierModel = require("sphere.models.ModifierModel")

---@class yi.ChartInfo : yi.View
---@operator call: yi.ChartInfo
local ChartInfo = View + {}

local cell = {
	min_w = 180,
	arrange = "flow_row",
	gap = 10,
	align_items = "center"
}

function ChartInfo:load()
	View.load(self)
	self:setArrange("flow_col")
	self:setChildGap(20)

	local res = self:getResources()
	self.patterns = Label(res:getFont("bold", 24), "Loading...\nLoading...")
	self.rate_const = Label(res:getFont("bold", 24), "1.00x")
	self.difficulty_calc = Label(res:getFont("regular", 16), "Loading...")
	self.difficulty = Label(res:getFont("black", 72), "??.?")
	self.mods = Label(res:getFont("black", 36), "Loading...")
	self.score_system = Label(res:getFont("bold", 24), "Loading...")
	self.gamemode = Label(res:getFont("bold", 24), "Loading...")
	self.bpm = Label(res:getFont("bold", 24), "Loading...")
	self.duration = Label(res:getFont("bold", 24), "Loading...")
	self.notes = Label(res:getFont("bold", 24), "Loading...")
	self.ln_percent = Label(res:getFont("bold", 24), "Loading...")

	self:addArray({
		h(View(), {arrange = "flow_row", gap = 20, line_gap = 20}, {
			h(View(), {w = 180, arrange = "flow_col"}, {
				h(self.difficulty_calc, {color = Colors.lines}),
				h(self.difficulty, {color = Colors.text}),
			}),
			h(self.patterns, {w = 180, align = "right", align_self = "end", y = -12}),
			h(View(), {w = 2, height = 80, background_color = Colors.br, align_self = "end", y = -12}),
			h(View(), {arrange = "flow_col", justify_content = "end"}, {
				h(Label(res:getFont("regular", 16), "MODIFIERS"), {color = Colors.lines, y = -8}),
				h(View(), {arrange = "flow_row", gap = 10, align_items = "end"}, {
					h(self.mods, {y = -8}),
					h(self.rate_const, {y = -12, color = Colors.accent}),
					h(self.score_system, {y = -12, color = Colors.lines}),
				})
			})
		}),

		h(View(), {w = 900, h = 2, background_color = Colors.br}),

		h(View(), {arrange = "flow_row", gap = 20}, {
			h(View(), cell, {
				h(Label(res:getFont("regular", 16), "DURATION"), {color = Colors.lines}),
				self.duration,
			}),
			h(View(), cell, {
				h(Label(res:getFont("regular", 16), "NOTES"), {color = Colors.lines}),
				self.notes,
			}),
			h(View(), cell, {
				h(Label(res:getFont("regular", 16), "MODE"), {color = Colors.lines}),
				self.gamemode,
			}),
			h(View(), cell, {
				h(Label(res:getFont("regular", 16), "TEMPO"), {color = Colors.lines}),
				self.bpm,
			}),
			h(View(), cell, {
				h(Label(res:getFont("regular", 16), "LN"), {color = Colors.lines}),
				self.ln_percent,
			}),
		})
	})
end

local format_difficulty_calc = {
	enps_diff = "ENPS",
	osu_diff = "Star Rating",
	msd_diff = "MSD",
	user_diff = "USER"
}

---@param data {[string]: number}
---@return string
---@return string?
local function getTopSkills(data)
	local max_v = -math.huge
	local max_k ---@type string

	for k, v in pairs(data) do
		if k ~= "overall" then
			if v > max_v then
				max_v = v
				max_k = k
			end
		end
	end

	local second_v = -math.huge
	local second_k ---@type string?

	for k, v in pairs(data) do
		if k ~= "overall" and k ~= max_k then
			if v > max_v * 0.93 and v > second_v then
				second_v = v
				second_k = k
			end
		end
	end

	return max_k, second_k
end

---@param mods sea.Modifier[] | string
---@return string
local function getModifierString(mods)
	if type(mods) == "string" then
		mods = ModifierEncoder:decode(mods)
	end

	local results = {}
	for _, mod in pairs(mods) do
		local modifier = ModifierModel:getModifier(mod.id)

		if modifier then
			local modifierString, modifierSubString = modifier:getString(mod)
			local fullMod = modifierString .. (modifierSubString or "")
			table.insert(results, fullMod)
		end
	end

	return table.concat(results, " ")
end


---@param chartview rizu.library.LocatedChartview
function ChartInfo:setChartview(chartview)
	local rate = self:getGame().timeRateModel:get()
	local input_mode = chartview.inputmode:gsub("key", "K"):gsub("scratch", "S")
	self.gamemode:setText(input_mode)
	self.bpm:setText(("%i"):format(chartview.tempo * rate))

	local duration = chartview.duration * rate
	local minutes = duration / 60
	local seconds = duration % 60
	self.duration:setText(("%i:%02i"):format(minutes, seconds))

	self.notes:setText(tostring(chartview.notes_count))

	local config = self:getConfig()
	local diff_column = config.settings.select.diff_column
	local difficulty = 0
	local hue = 0

	if diff_column == "msd_diff" then
		difficulty = chartview.msd_diff
		hue = Colors.convertDiffToHue((math.min(difficulty, 40) / 40) / 1.3)
	elseif diff_column == "osu_diff" then
		difficulty = chartview.osu_diff
		hue = Colors.convertDiffToHue((math.min(difficulty, 10) / 10))
	elseif diff_column == "enps_diff" then
		difficulty = chartview.enps_diff
		hue = Colors.convertDiffToHue((math.min(difficulty, 30) / 30))
	elseif diff_column == "user_diff" then
		difficulty = chartview.user_diff
		hue = 0
	end

	self.difficulty_calc:setText(format_difficulty_calc[diff_column])
	self.difficulty:setText(("%0.01f"):format(difficulty))
	self.difficulty:setColor(Colors.HSV(hue, 1, 1))

	local pattern_max, pattern_second = getTopSkills(chartview.msd_diff_data)

	if pattern_second then
		self.patterns:setText(("%s\n%s"):format(pattern_max:upper(), pattern_second:upper()))
	else
		self.patterns:setText(("\n%s"):format(pattern_max:upper()))
	end

	local note_count = chartview.notes_count
	local long_notes_count = (chartview.judges_count or 0) - note_count
	local ln_percent = long_notes_count / note_count
	self.ln_percent:setText(("%i%%"):format(ln_percent * 100))
	self.ln_percent:setColor(Colors.HSV(Colors.convertDiffToHue(math.min(ln_percent * 1.3)), ln_percent, 1))

	local game = self:getGame()
	local mods_str = getModifierString(game.replayBase.modifiers)
	self.mods:setText(mods_str == "" and "No mods" or mods_str)

	local const = game.replayBase.const

	if const then
		self.rate_const:setText(("%0.2fx CONST"):format(game.timeRateModel:get()))
	else
		self.rate_const:setText(("%0.2fx"):format(game.timeRateModel:get()))
	end

	self.score_system:setText("osu!mania V1 OD9")
end

return ChartInfo
