local noteChartSets = {}

noteChartSets.table_name = "noteChartSets"

noteChartSets.types = {}

noteChartSets.relations = {
	noteChart = {has_many = "noteCharts", key = "setId"},
}

return noteChartSets
