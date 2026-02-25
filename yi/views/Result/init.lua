local Screen = require("yi.views.Screen")
local Label = require("yi.views.Label")

---@class yi.Result : yi.Screen
---@operator call: yi.Result
local Result = Screen + {}

function Result:load()
	self:setup({
		id = "result",
		w = "100%",
		h = "100%",
		justify_content = "center",
		align_items = "center",
		keyboard = true
	})

	local res = self:getResources()
	local game = self:getGame()
	local score_item = game.selectModel.scoreItem

	if not score_item then
		self:add(Label(res:getFont("black", 72), "No score"))
		return
	end

	local score_engine = game.rhythm_engine.score_engine
	local acc_string = score_engine.accuracySource:getAccuracyString()
	self:add(Label(res:getFont("black", 58), acc_string))
end

function Result:loadComplete()
	local config = self:getConfig()
	local bg = self:getContext().background
	bg:setDim(config.settings.graphics.dim.result)
end

function Result:onKeyDown(e)
	local k = e.key

	if k == "escape" then
		self.parent:set("select")
	end
end

return Result
