local function newInputModeScoreFilter(name, inputMode)
	return {
		name = name,
		check = function(score)
			return score.inputmode == inputMode
		end
	}
end

return {
	notechart = {
		{
			name = "original input mode",
			{name = "4K", conds = {inputmode__startswith = "4key"}},
			{name = "5K", conds = {inputmode__startswith = "5key"}},
			{name = "6K", conds = {inputmode__startswith = "6key"}},
			{name = "7K", conds = {inputmode__startswith = "7key"}},
			{name = "8K", conds = {inputmode__startswith = "8key"}},
			{name = "9K", conds = {inputmode__startswith = "9key"}},
			{name = "10K", conds = {inputmode__startswith = "10key"}},
		},
		{
			name = "actual input mode",
			{name = "4K", conds = {chartdiff_inputmode__startswith = "4key"}},
			{name = "5K", conds = {chartdiff_inputmode__startswith = "5key"}},
			{name = "6K", conds = {chartdiff_inputmode__startswith = "6key"}},
			{name = "7K", conds = {chartdiff_inputmode__startswith = "7key"}},
			{name = "8K", conds = {chartdiff_inputmode__startswith = "8key"}},
			{name = "9K", conds = {chartdiff_inputmode__startswith = "9key"}},
			{name = "10K", conds = {chartdiff_inputmode__startswith = "10key"}},
		},
		{
			name = "(not) played",
			{name = "played", conds = {accuracy__isnotnull = true}},
			{name = "not played", conds = {accuracy__isnull = true}},
		},
		{
			name = "scratch",
			{name = "has scratch", conds = {inputmode__contains = "scratch"}},
			{name = "has not scratch", conds = {inputmode__notcontains = "scratch"}},
		},
	},
	score = {
		{name = "No filter"},
		{name = "FC", check = function(score)
			return score.missCount == 0
		end},
		newInputModeScoreFilter("4K", "4key"),
		newInputModeScoreFilter("5K", "5key"),
		newInputModeScoreFilter("6K", "6key"),
		newInputModeScoreFilter("7K", "7key"),
		newInputModeScoreFilter("8K", "8key"),
		newInputModeScoreFilter("9K", "9key"),
		newInputModeScoreFilter("10K", "10key"),
	}
}
