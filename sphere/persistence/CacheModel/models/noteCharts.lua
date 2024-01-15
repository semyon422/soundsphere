local noteCharts = {}

noteCharts.table_name = "noteCharts"

noteCharts.types = {}

noteCharts.relations = {
	noteChart = {has_many = "noteCharts", key = "setId"},
}

return noteCharts
