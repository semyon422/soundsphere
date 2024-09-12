local json = require("json")
local IHandler = require("web.IHandler")

local ErrorHandler = require("web.handlers.ErrorHandler")
local SequentialHandler = require("web.handlers.SequentialHandler")
local AnonHandler = require("web.handlers.AnonHandler")
local BodyReader = require("web.body.BodyReader")

local Router = require("web.router.Router")

local RouterHandler = require("web.router.RouterHandler")

local WebReplayHandler = require("sphere.web.WebReplayHandler")
local WebChartHandler = require("sphere.web.WebChartHandler")

---@class sphere.ComputeApp: web.IHandler
---@operator call: sphere.ComputeApp
local ComputeApp = IHandler + {}

function ComputeApp:new()
	local router = Router()

	router:route("POST", "/replay", {controller = WebReplayHandler()})
	router:route("POST", "/notechart", {controller = WebChartHandler()})

	self.handler = ErrorHandler(SequentialHandler({
		RouterHandler(router),
		AnonHandler(function(...)
			self:handleController(...)
		end)
	}))
end

--[[
body = to_json({
	notechart = {
		path = Files:get_path(notechart_file),
		extension = notechart_file.name:match("^.+%.(.-)$"),
		index = notechart.index,
	},
	replay = {
		path = Files:get_path(replay_file)
	},
})
]]

---@param req web.IRequest
---@param res web.IResponse
---@param ctx web.HandlerContext
function ComputeApp:handleController(req, res, ctx)
	local reader = BodyReader(req)
	local body = reader:readAll()

	---@type string
	local params = json.decode(body)

	local controller = ctx.controller
	local status, data = controller:handle(params)
	local res_body = json.encode(data)

	res.status = status
	res.headers["Content-Type"] = "application/json"
	res.headers["Content-Length"] = #res_body
	res:write(res_body)
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx web.HandlerContext
function ComputeApp:handle(req, res, ctx)
	self.handler:handle(req, res, ctx)
end

return ComputeApp
