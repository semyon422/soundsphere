local View = require("yi.views.View")
local Colors = require("yi.Colors")

---@class yi.ArtistTitle : yi.View
---@operator call: yi.ArtistTitle
local ArtistTitle = View + {}

function ArtistTitle:load()
	View.load(self)
	self.id = "artist_title"

	local res = self:getResources()
	local large = res:getFont("black", 58)
	local small = res:getFont("bold", 46)
	self.title = love.graphics.newText(large, "Loading...")
	self.artist = love.graphics.newText(small, "Loading...")
	self.artist_y = large:getHeight()
	self:setWidth(math.max(self.artist:getWidth(), self.title:getWidth()))
	self:setHeight(large:getHeight() + small:getHeight())
end

---@param chartview {[string]: any}
function ArtistTitle:setChartview(chartview)
	self.title:set(chartview.title or "Nil Title")
	self.artist:set(chartview.artist or "Nil Artist")
	self:setWidth(math.max(self.artist:getWidth(), self.title:getWidth()))
end

local lg = love.graphics

function ArtistTitle:draw()
	lg.draw(self.title)
	lg.setColor(Colors.lines)
	lg.draw(self.artist, 0, self.artist_y)
end

return ArtistTitle
