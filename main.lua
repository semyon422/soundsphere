local aquapackage = require("aqua.aqua.package")
aquapackage.add("aqua")
aquapackage.add("ncdk")
aquapackage.add("chartbase")

require("aqua")
package.loaded["xsys"] = {
	string = require("aqua.string")
}

require("aqua.io"):init()


require("sphere.SphereGame"):run()
