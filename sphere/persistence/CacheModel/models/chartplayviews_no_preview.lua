local chartplayviews = require("sphere.persistence.CacheModel.models.chartplayviews")

local chartplayviews_no_preview = {}

chartplayviews_no_preview.table_name = "chartplayviews_no_preview"
chartplayviews_no_preview.types = chartplayviews.types
chartplayviews_no_preview.relations = chartplayviews.relations
chartplayviews_no_preview.from_db = chartplayviews.from_db

return chartplayviews_no_preview
