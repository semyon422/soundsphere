local chartviews = require("rizu.library.models.chartviews")

local chartviews_no_preview = {}

chartviews_no_preview.table_name = "chartviews_no_preview"
chartviews_no_preview.types = chartviews.types
chartviews_no_preview.relations = chartviews.relations
chartviews_no_preview.from_db = chartviews.from_db

return chartviews_no_preview
