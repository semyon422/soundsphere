local xsys_preloader = {}

xsys_preloader.name = "xsys"

---@param mod string
---@return table
function xsys_preloader.preload(mod)
	return {
		string = require("aqua.string")
	}
end

return xsys_preloader
