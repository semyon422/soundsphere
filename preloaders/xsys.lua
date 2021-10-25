local xsys_preloader = {}

xsys_preloader.name = "xsys"

xsys_preloader.preload = function()
	return {
		string = require("aqua.string")
	}
end

return xsys_preloader
