return {
	notechart = {
		{name = "No filter"},
		{name = "4K", string = "4key"},
		{name = "5K", string = "5key"},
		{name = "6K", string = "6key"},
		{name = "7K", string = "7key"},
		{name = "8K", string = "8key"},
		{name = "9K", string = "9key"},
		{name = "10K", string = "10key"},
		-- {
		-- 	name = "4K+10K",
		-- 	condition = 'noteChartDatas.inputMode = "4key" OR noteChartDatas.inputMode = "10key"',
		-- },
	},
	score = {
		{
			name = "No filter",
		},
		{
			name = "4K",
			check = function(score)
				return score.inputMode == "4key"
			end
		},
		{
			name = "10K",
			check = function(score)
				return score.inputMode == "10key"
			end
		},
	}
}
