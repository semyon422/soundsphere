local View = require("yi.views.View")
local Label = require("yi.views.Label")
local Colors = require("yi.Colors")

---@class yi.SongSelectTag : yi.View
---@operator call: yi.SongSelectTag
local Tag = View + {}

function Tag:load()
	View.load(self)
	self:setBackgroundColor(Colors.panels)
	self:setPaddings({5, 20, 5, 20})

	local res = self:getResources()
	self.label = self:add(Label(res:getFont("bold", 16), "LOADING..."))
	self.label:setColor(Colors.text)
end

---@param v string
function Tag:setText(v)
	self.label:setText(v)
end

---@param v yi.Color
function Tag:setTextColor(v)
	self.label:setColor(v)
end

function Tag:draw()
	local w, h = self:getCalculatedWidth(), self:getCalculatedHeight()
	love.graphics.setColor(self.background_color)
	love.graphics.rectangle("fill", 0, 0, w, h)
	love.graphics.setColor(Colors.outline)
	love.graphics.setLineWidth(1)
	love.graphics.rectangle("line", 0, 0, w, h)
end

return Tag
