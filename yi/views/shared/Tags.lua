local View = require("yi.views.View")
local Tag = require("yi.views.shared.Tag")
local Colors = require("yi.Colors")

---@class yi.Tags : yi.View
---@operator call: yi.Tags
local Tags = View + {}

function Tags:load()
	View.load(self)
	self:setArrange("flow_row")
	self:setChildGap(10)
	self.id = "tags"
	self.status = self:add(Tag())
	self.format = self:add(Tag())
end

---@param chartview rizu.library.LocatedChartview
function Tags:setChartview(chartview)
	local is_ranked = chartview.difftable_chartmetas and #chartview.difftable_chartmetas > 0

	if is_ranked then
		self.status:setText("RANKED")
		self.status:setBackgroundColor(Colors.accent)
		self.status:setTextColor({0, 0, 0, 1})
	else
		self.status:setText("UNRANKED")
		self.status:setBackgroundColor(Colors.lines)
		self.status:setTextColor({0, 0, 0, 1})
	end

	self.format:setText((chartview.format or "unknown"):upper())
end

return Tags
