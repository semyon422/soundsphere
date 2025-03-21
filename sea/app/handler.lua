local App = require("sea.app.App")

local app_config = require("app_config")

local app = App(app_config)

app:load()

---@param req web.IRequest
---@param res web.IResponse
---@param ip string
local function handler(req, res, ip)
	app:handle(req, res, ip)
end

return handler
