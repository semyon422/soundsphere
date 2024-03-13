local just = require("just")
local imgui = require("imgui")
local ModalImView = require("sphere.imviews.ModalImView")
local _transform = require("gfx_util").transform
local spherefonts = require("sphere.assets.fonts")

local transform = {{1 / 2, -16 / 9 / 2}, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}

local scrollY = 0

local w, h = 768, 768
local _w, _h = w / 2, 55
local r = 8
local window_id = "FiltersView"

return ModalImView(function(self, quit)
	local filterModel = self.game.selectModel.filterModel

	if quit then
		filterModel:apply()
		self.game.selectModel:noDebouncePullNoteChartSet()
		return true
	end

	imgui.setSize(w, h, _w, _h)

	love.graphics.setFont(spherefonts.get("Noto Sans", 24))

	love.graphics.replaceTransform(_transform(transform))
	love.graphics.translate((1920 - w) / 2, (1080 - h) / 2)

	love.graphics.setColor(0, 0, 0, 0.8)
	love.graphics.rectangle("fill", 0, 0, w, h, r)
	love.graphics.setColor(1, 1, 1, 1)

	just.push()

	imgui.Container(window_id, w, h, _h / 3, _h * 2, scrollY)

	local filters = self.game.configModel.configs.filters.notechart

	for _, group in ipairs(filters) do
		imgui.text(group.name)
		just.row(true)
		for _, filter in ipairs(group) do
			local is_active = filterModel:isActive(group.name, filter.name)
			local new_is_active = imgui.textcheckbox(filter, is_active, filter.name)
			if new_is_active ~= is_active then
				filterModel:setFilter(group.name, filter.name, new_is_active)
			end
		end
		just.row()
	end

	scrollY = imgui.Container()
	just.pop()

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle("line", 0, 0, w, h, r)
end)
