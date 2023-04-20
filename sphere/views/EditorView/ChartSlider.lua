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

local function Slider(id, value, w, h, displayValue, points)
	local over = just.is_over(w, h)
	local pos = getPosition(w, h)

	local new_value, active, hovered = just.slider(id, over, pos, value)

	theme.setColor(active, hovered)
	theme.rectangle(w, h)

	love.graphics.setColor(0.66, 0.66, 0.66, 1)
	local pad = h * (1 - theme.size) / 2
	local _h = h - 2 * pad

	for i = 0, #points - 1 do
		local x = math_util.map(i, 0, #points, h / 2, w - h / 2)
		local x2 = math_util.map(i + 1, 0, #points, h / 2, w - h / 2)
		love.graphics.line(x, (1 - points[i]) * _h + pad, x2, (1 - points[i + 1]) * _h + pad)
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

	return new_value
end

return function(self, w, h)
	love.graphics.setColor(0, 0, 0, 0.8)
	love.graphics.rectangle("fill", 0, 0, w, h)
	love.graphics.setColor(1, 1, 1, 1)

	local editorModel = self.game.editorModel
	local editorTimePoint = editorModel.timePoint

	local fullLength = editorModel.lastTime - editorModel.firstTime
	local pos = (editorTimePoint.absoluteTime - editorModel.firstTime) / fullLength

	local points = self.game.editorModel.densityGraph
	local newPos = Slider("time slider", pos, w, h, time_util.format(editorTimePoint.absoluteTime, 3), points)

	if just.active_id == "time slider" then
		if newPos then
			editorModel:scrollSeconds(newPos * fullLength + editorModel.firstTime)
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
