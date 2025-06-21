local App = require("sea.app.App")

local app_config = require("app_config")

---@type sea.App
local app

local function init()
	app = App(app_config)
	app:load()
end

---@param req web.IRequest
---@param res web.IResponse
---@param ip string
local function handler(req, res, ip)
	if not app then
		init()
	end
	app:handle(req, res, ip)
end

return handler
