local App = require("sea.app.App")

local app = App()

app:load()

---@param req web.IRequest
---@param res web.IResponse
local function handler(req, res)
	app:handle(req, res)
end

return handler
