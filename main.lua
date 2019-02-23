local aquapackage = require("aqua.package")
aquapackage.add("chartbase")

require("byte")
require("aqua")
require("aqua.io"):init()

require("sphere.SphereGame"):run()
