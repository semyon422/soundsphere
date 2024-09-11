local json = require("json")
local IHandler = require("web.IHandler")

local ParamsHandler = require("web.handlers.ParamsHandler")
local ErrorHandler = require("web.handlers.ErrorHandler")
local UserHandler = require("web.handlers.UserHandler")
local ProtectedHandler = require("web.handlers.ProtectedHandler")
local ConverterHandler = require("web.handlers.ConverterHandler")
local SequentialHandler = require("web.handlers.SequentialHandler")
local SelectHandler = require("web.handlers.SelectHandler")
local StaticHandler = require("web.handlers.StaticHandler")
local AnonHandler = require("web.handlers.AnonHandler")
local BodyReader = require("web.body.BodyReader")

local Router = require("web.router.Router")
local Views = require("web.page.Views")

local UsecaseHandler = require("web.usecase.UsecaseHandler")
local RouterHandler = require("web.router.RouterHandler")
local PageHandler = require("web.page.PageHandler")
local SessionHandler = require("web.cookie.SessionHandler")

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
	local result = controller.POST({params = params})
	local res_body = json.encode(result.json)

	res.status = result.status or 200
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
