local View = require("yi.views.View")
local Colors = require("yi.Colors")

---@class yi.PreviewSeekBar : yi.View
---@overload fun(previewModel: rizu.preview.PreviewModel): yi.PreviewSeekBar
---@field previewModel rizu.preview.PreviewModel
local PreviewSeekBar = View + {}

---@param previewModel rizu.preview.PreviewModel
function PreviewSeekBar:new(previewModel)
	View.new(self)
	self.previewModel = previewModel
	self.dragging = false
	self.hovered = false

	self:setup({
		w = 320,
		h = 20,
		mouse = true,
	})
end

---@return number
function PreviewSeekBar:getProgress()
	return self.previewModel:getRelativePosition()
end

---@param gx number
---@param gy number
function PreviewSeekBar:seekFromMouse(gx, gy)
	local duration = self.previewModel:getDuration()
	if duration <= 0 then
		return
	end

	local lx, _ = self.transform:inverseTransformPoint(gx, gy)
	local width = self:getCalculatedWidth()
	if width <= 0 then
		return
	end

	local progress = math.max(0, math.min(1, lx / width))
	self.previewModel:setRelativePosition(progress)
end

function PreviewSeekBar:onHover()
	self.hovered = true
end

function PreviewSeekBar:onHoverLost()
	self.hovered = false
	if not love.mouse.isDown(1) then
		self.dragging = false
	end
end

function PreviewSeekBar:onMouseDown(e)
	self.dragging = true
	self:seekFromMouse(e.x, e.y)
	return true
end

function PreviewSeekBar:onMouseUp()
	self.dragging = false
end

function PreviewSeekBar:onDragStart(e)
	self.dragging = true
	self:seekFromMouse(e.x, e.y)
end

function PreviewSeekBar:onDrag(e)
	if self.dragging then
		self:seekFromMouse(e.x, e.y)
	end
end

function PreviewSeekBar:onDragEnd()
	self.dragging = false
end

local dragging = {1, 1, 1, 0.95}
local hovered = {Colors.accent[1], Colors.accent[2], Colors.accent[3], 0.9}
local idle = {Colors.accent[1], Colors.accent[2], Colors.accent[3], 0.75}

function PreviewSeekBar:draw()
	local w, h = self:getCalculatedWidth(), self:getCalculatedHeight()
	if w <= 0 or h <= 0 then
		return
	end

	local border = (self.hovered or self.dragging) and 2 or 1
	local pad = 3
	local fill_w = math.max(0, math.min(w - pad * 2, (w - pad * 2) * self:getProgress()))

	love.graphics.setLineWidth(border)
	love.graphics.setColor(Colors.outline)
	love.graphics.rectangle("line", 0.5, 0.5, w - 1, h - 1)

	if fill_w > 0 then
		local fill_color = self.dragging and dragging
			or self.hovered and hovered
			or idle
		love.graphics.setColor(fill_color)
		love.graphics.rectangle("fill", pad, pad, fill_w, h - pad * 2)
	end
end

return PreviewSeekBar
