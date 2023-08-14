local preloader = {}

local preload = package.preload

---@param name string
function preloader.preload(name)
	local module_preloader = require(name)
	if preload[module_preloader.name] then return end
	preload[module_preloader.name] = module_preloader.preload
end

return preloader
