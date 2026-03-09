local View = require("yi.views.View")
local Label = require("yi.views.Label")
local Image = require("yi.views.Image")
local Colors = require("yi.Colors")
local h = require("yi.h")

---@class yi.Player : yi.View
---@operator call: yi.Player
local Player = View + {}

function Player:load()
	View.load(self)
	self:setArrange("flow_row")
	self:setChildGap(20)
	self:setAlignItems("center")

	local res = self:getResources()
	local avatar_frame = love.graphics.newImage("resources/yi/avatar_frame.png")
	local player_info_h = 64

	self:addArray({
		h(View(), {arrange = "flow_col"}, {
			h(Label(res:getFont("black", 24), "Guest"), {align = "right"}),
			h(Label(res:getFont("bold", 16), "#5 • 93.56%"), {align = "right"})
		}),
		h(Label(res:getFont("black", 46), "6.769pp"), {color = Colors.accent, align = "right"}),
		h(Image(avatar_frame), {w = player_info_h, h = player_info_h}),
	})
end

return Player
