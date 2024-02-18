local path_util = require("path_util")

local chartviews = {}

chartviews.table_name = "chartviews"

chartviews.types = {
	lamp = "boolean",
	set_is_file = "boolean",
}

chartviews.relations = {}

function chartviews:from_db()
	local dir = self.set_dir
	if not self.set_is_file then
		dir = path_util.join(dir, self.set_name)
	end
	self.dir = dir
	self.path = path_util.join(dir, self.chartfile_name)
end

return chartviews
