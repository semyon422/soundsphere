local just = require("just")
local imgui = require("imgui")
local time_util = require("time_util")
local math_util = require("math_util")
local gfx_util = require("gfx_util")
local theme = require("imgui.theme")

local function getPosition(w, h)
	local x, y = love.graphics.inverseTransformPoint(love.mouse.getPosition())
	local value = math_util.map(x, h / 2, w - h / 2, 0, 1)
	return math.min(math.max(value, 0), 1)
end

return function(self, w, h)
	love.graphics.setColor(0, 0, 0, 0.8)
	theme.rectangle(w, h)
	love.graphics.setColor(1, 1, 1, 1)

	local editorModel = self.game.editorModel
	local editorTimePoint = editorModel.timePoint

	local fullLength = editorModel.lastTime - editorModel.firstTime
	local value = (editorTimePoint.absoluteTime - editorModel.firstTime) / fullLength

	local densityPoints = self.game.editorModel.densityGraph
	local intervalPoints = self.game.editorModel.intervalDatasGraph
	local displayValue = time_util.format(editorTimePoint.absoluteTime, 3)

	local over = just.is_over(w, h)
	local pos = getPosition(w, h)

	local new_value, active, hovered = just.slider("time slider", over, pos, value)

	theme.setColor(active, hovered)
	theme.rectangle(w, h)
	local pad = h * (1 - theme.size) / 2
	local _h = h - 2 * pad

	love.graphics.setColor(1, 1, 0.1, 1)
	for i = 0, intervalPoints.n do
		if intervalPoints[i] then
			local x = math_util.map(i, 0, intervalPoints.n, h / 2, w - h / 2)
			love.graphics.line(x, pad, x, _h + pad)
		end
	end

	love.graphics.setColor(0.66, 0.66, 0.66, 1)
	for i = 0, #densityPoints - 1 do
		local x = math_util.map(i, 0, #densityPoints, h / 2, w - h / 2)
		local x2 = math_util.map(i + 1, 0, #densityPoints, h / 2, w - h / 2)
		love.graphics.line(x, (1 - densityPoints[i]) * _h + pad, x2, (1 - densityPoints[i + 1]) * _h + pad)
	end

	local x = math_util.map(math.min(math.max(value, 0), 1), 0, 1, h / 2, w - h / 2)
	love.graphics.setColor(1, 1, 1, 1)
	theme.circle(h, x, h / 2)

	if displayValue then
		local width = love.graphics.getFont():getWidth(displayValue)
		local tx = (w - width) / 2
		if x >= w / 2 then
			tx = math.min(tx, x - h / 2 - width)
		else
			tx = math.max(tx, x + h / 2)
		end
		gfx_util.printFrame(displayValue, tx, 0, width, h, "left", "center")
	end

	just.next(w, h)

	if just.active_id == "time slider" then
		if new_value then
			editorModel:scrollSeconds(new_value * fullLength + editorModel.firstTime)
		end
		if editorModel.timer.isPlaying then
			editorModel:pause()
			editorModel.dragging = true
		end
	elseif editorModel.dragging then
		editorModel:play()
		editorModel.dragging = false
	end
end
