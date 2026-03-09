local View = require("yi.views.View")
local Colors = require("yi.Colors")
local Label = require("yi.views.Label")

---@class yi.ArtistTitle : yi.View
---@operator call: yi.ArtistTitle
local ArtistTitle = View + {}

function ArtistTitle:load()
	View.load(self)
	self.id = "artist_title"
	self:setArrange("flow_col")

	local res = self:getResources()
	local large = res:getFont("black", 58)
	local small = res:getFont("bold", 24)
	self.title = self:add(Label(large, "Loading..."))
	self.artist = self:add(Label(small, "Loading..."))
	self.name = self:add(Label(small, "Loading..."))
	self.name:setColor(Colors.lines)
end

---@param chartview rizu.library.LocatedChartview
function ArtistTitle:setChartview(chartview)
	self.title:setText(chartview.title or "Nil Title")
	self.artist:setText(chartview.artist or "Nil Artist")
	self.name:setText(chartview.name or "Nil Name")
end

return ArtistTitle
