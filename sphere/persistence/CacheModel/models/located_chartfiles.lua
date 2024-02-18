local path_util = require("path_util")

local located_chartfiles = {}

located_chartfiles.table_name = "located_chartfiles"

located_chartfiles.types = {
	set_is_file = "boolean",
}

located_chartfiles.relations = {}

function located_chartfiles:from_db()
	local dir = self.set_dir
	if not self.set_is_file then
		dir = path_util.join(dir, self.set_name)
	end
	self.dir = dir
	self.path = path_util.join(dir, self.chartfile_name)
end

return located_chartfiles
