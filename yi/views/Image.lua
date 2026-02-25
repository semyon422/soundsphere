local View = require("yi.views.View")
local LayoutEnums = require("ui.layout.Enums")

---@class yi.Image : yi.View
---@operator call: yi.Image
local Image = View + {}

---@param img love.Image
function Image:new(img)
	View.new(self)
	self.img = img
	self.img_scale_x = 1
	self.img_scale_y = 1
	self.preserve_aspect_ratio = true
end

function Image:draw()
	love.graphics.draw(self.img, 0, 0, 0, self.img_scale_x, self.img_scale_y)
end

function Image:updateTransforms()
	View.updateTransforms(self)
	local w, h = self:getCalculatedWidth(), self:getCalculatedHeight()
	local iw, ih = self.img:getDimensions()
	self.img_scale_x, self.img_scale_y = w / iw, h / ih
end

---@param axis_idx ui.Axis
---@param constraint number?
function Image:getIntrinsicSize(axis_idx, constraint)
	if axis_idx == LayoutEnums.Axis.X then
		return self.img:getWidth()
	else
		if self.preserve_aspect_ratio then
			local s = constraint / self.img:getWidth()
			return self.img:getHeight() * s
		else
			return self.img:getHeight()
		end
	end
end

return Image
