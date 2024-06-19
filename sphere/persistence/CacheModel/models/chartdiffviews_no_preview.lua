local chartdiffviews = require("sphere.persistence.CacheModel.models.chartdiffviews")

local chartdiffviews_no_preview = {}

chartdiffviews_no_preview.table_name = "chartdiffviews_no_preview"
chartdiffviews_no_preview.types = chartdiffviews.types
chartdiffviews_no_preview.relations = chartdiffviews.relations
chartdiffviews_no_preview.from_db = chartdiffviews.from_db

return chartdiffviews_no_preview
