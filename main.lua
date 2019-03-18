local aquapackage = require("aqua.aqua.package")
aquapackage.add("aqua")
aquapackage.add("ncdk")
aquapackage.add("chartbase")

require("aqua")

require("aqua.io"):init()


require("sphere.SphereGame"):run()
