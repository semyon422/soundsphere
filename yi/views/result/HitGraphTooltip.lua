local View = require("yi.views.View")
local Colors = require("yi.Colors")
local Label = require("yi.views.Label")
local math_util = require("math_util")

---@class yi.HitGraphTooltip : yi.View
---@operator call: yi.HitGraphTooltip
local HitGraphTooltip = View + {}

function HitGraphTooltip:load()
	local res = self:getResources()
	local c = Colors.panels
	self:setAlignSelf("start")
	self:setPaddings({5, 5, 5, 5})
	self:setBackgroundColor({c[1], c[2], c[3], 0.6})
	self:setEnabled(false)
	self.label = self:add(Label(res:getFont("bold", 16), ""))
end

function HitGraphTooltip:update()
	local parent = self.parent
	local imx, imy = parent.transform:inverseTransformPoint(love.mouse.getPosition())
	local pw, ph = parent:getCalculatedWidth(), parent:getCalculatedHeight()
	local tw, th = self:getCalculatedWidth(), self:getCalculatedHeight()
	local ox = imx + tw <= pw and 0 or 1
	local oy = imy + th <= ph and 0 or 1
	local left = math_util.clamp(imx - tw * ox, 0, math.max(0, pw - tw))
	local top = math_util.clamp(imy - th * oy, 0, math.max(0, ph - th))

	self.transform:setOrigin(ox, oy)
	self:setX(left + tw * ox)
	self:setY(top + th * oy)
end

---@param v string
function HitGraphTooltip:setText(v)
	self.label:setText(v)
end

return HitGraphTooltip
