local lapis = require("lapis")
local util = require("lapis.util")
local respond_to = require("lapis.application").respond_to
local json_params = require("lapis.application").json_params
local app = lapis.Application()

local ext = jit.os == "Windows" and "dll" or "so"
local function package_add(path)
	package.path = package.path .. (";path/?.lua;path/?/init.lua"):gsub("path", path)
	package.cpath = package.cpath .. (";path/?." .. ext):gsub("path", path)
end

package_add("aqua")
package_add("ncdk")
package_add("chartbase")
package_add("libchart")
package_add("md5")
package_add("luajit-request")
package_add("json")
package_add("tinyyaml")
package_add("tween")
package_add("s3dc")
package_add("inspect")
package_add("lua-crc32")
package_add("serpent/src")

require("preloaders.preloadall")
require("aqua.string")

local WebReplayController = require("sphere.controllers.WebReplayController")
local WebNoteChartController = require("sphere.controllers.WebNoteChartController")

app:match("/replay", json_params(respond_to(WebReplayController)))
app:match("/notechart", json_params(respond_to(WebNoteChartController)))

function app:handle_error(err, trace)
	return {status = 500, json = {
		err = err,
		trace = trace,
	}}
end

return app
