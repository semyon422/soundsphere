local just = require("just")
local imgui = require("imgui")
local ModalImView = require("sphere.imviews.ModalImView")
local _transform = require("gfx_util").transform
local spherefonts = require("sphere.assets.fonts")
local theme = require("imgui.theme")
local ModifierModel = require("sphere.models.ModifierModel")

local transform = {{1 / 2, -16 / 9 / 2}, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}

local scrollY = 0
local scrollYlist = 0

local w, h = 1024, 1080 / 2
local _w, _h = w / 2, 55
local r = 8
local window_id = "MountsView"

local sections = {
	"locations",
	"database",
}
local section = sections[1]

local section_draw = {}

local modal

modal = ModalImView(function(self, quit)
	if quit then
		return true
	end

	imgui.setSize(w, h, w, _h)

	love.graphics.setFont(spherefonts.get("Noto Sans", 24))

	love.graphics.replaceTransform(_transform(transform))
	love.graphics.translate((1920 - w) / 2, (1080 - h) / 2)

	love.graphics.setColor(0, 0, 0, 0.8)
	love.graphics.rectangle("fill", 0, 0, w, h, r)
	love.graphics.setColor(1, 1, 1, 1)

	just.push()
	just.push()
	local tabsw
	section, tabsw = imgui.vtabs("settings tabs", section, sections)
	just.pop()
	love.graphics.translate(tabsw, 0)

	local inner_w = w - tabsw
	imgui.setSize(inner_w, h, inner_w / 2, _h)

	imgui.Container(window_id, inner_w, h, _h / 3, _h * 2, scrollY)

	love.graphics.setColor(1, 1, 1, 1)
	section_draw[section](self, inner_w)
	just.emptyline(8)

	scrollY = imgui.Container()
	just.pop()

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle("line", 0, 0, w, h, r)
end)

function section_draw.locations(self, inner_w)
	local locationsRepo = self.game.cacheModel.locationsRepo
	local locationManager = self.game.cacheModel.locationManager
	local locations = locationManager.locations

	local list_w = inner_w / 3

	local selected_loc_id = locationManager.selected_id

	just.push()
	imgui.List("mount points", list_w, h - _h, _h / 2, _h, scrollYlist)
	for i, item in ipairs(locations) do
		local name = item.name
		if selected_loc_id == item.id then
			name = "> " .. name
		end
		if imgui.TextOnlyButton("mount item" .. i, name, w, _h * theme.size, "left") or not selected_loc_id then
			locationManager:selectLocation(item.id)
		end
	end
	scrollYlist = imgui.List()

	if imgui.TextButton("create loc", "create location", list_w, _h) then
		local location = locationsRepo:insertLocation({
			name = "unnamed",
			is_relative = false,
			is_internal = false,
		})
		locationManager:selectLocations()
		locationManager:selectLocation(location.id)
	end

	just.pop()

	love.graphics.translate(list_w, 0)

	local selected_loc = locationManager.selected_loc
	if not selected_loc then
		return
	end

	local location_info = locationManager.location_info

	local path = selected_loc.path
	if selected_loc.is_internal then
		just.indent(8)
		just.text("Internal")
	end
	just.indent(8)
	just.text("Status: " .. (selected_loc.status or "unknown"))
	just.indent(8)
	just.text("Real path: ")
	just.indent(8)
	if path then
		imgui.url("open dir", path, path)
	else
		just.text("not specified")
	end

	if not selected_loc.is_internal then
		local loc_name = imgui.input("loc name", selected_loc.name, "name")
		if loc_name ~= selected_loc.name then
			locationsRepo:updateLocation({
				id = selected_loc.id,
				name = loc_name,
			})
			locationManager:selectLocations()
			locationManager:selectLocation(selected_loc.id)
		end
	end

	imgui.text("chartfile_sets: " .. location_info.chartfile_sets)
	imgui.text(("chartfiles: %s/%s"):format(
		location_info.hashed_chartfiles,
		location_info.chartfiles
	))

	if imgui.button("cache_button", "update") then
		self.game.selectController:updateCacheLocation(selected_loc.id)
	end

	imgui.separator()

	local inactive = not love.keyboard.isDown("lshift")
	imgui.text("Hold left shift to make buttons below active")

	if imgui.button("reset dir", "delete charts cache", inactive) then
		locationManager:deleteCharts(selected_loc.id)
		self.game.selectModel:noDebouncePullNoteChartSet()
	end

	if not selected_loc.is_internal and imgui.button("delete dir", "delete location", inactive) then
		locationManager:deleteLocation(selected_loc.id)
		locationManager:selectLocations()
		locationManager:selectLocation(1)
		self.game.selectModel:noDebouncePullNoteChartSet()
	end
end

local formats = {"bms", "ksh", "mid", "ojn", "osu", "qua", "sph", "sm"}
function section_draw.database(self)
	local cacheStatus = self.game.cacheModel.cacheStatus
	imgui.text("chartmetas: " .. cacheStatus.chartmetas)
	imgui.text("chartdiffs: " .. cacheStatus.chartdiffs)

	if imgui.button("cacheStatus update", "update status") then
		cacheStatus:update()
	end

	local inactive = not love.keyboard.isDown("lshift")
	imgui.text("Hold left shift to make inactive buttons active")

	imgui.separator()
	imgui.text("chartdiffs")

	local cacheModel = self.game.cacheModel
	if imgui.button("compute cds", "compute missing") then
		cacheModel:computeChartdiffs()
	end
	if imgui.button("compute incomplete cds", "compute incomplete") then
		cacheModel:computeIncompleteChartdiffs()
	end
	if imgui.button("compute incomplete cds pp", "compute incomplete, use preview when possible") then
		cacheModel:computeIncompleteChartdiffs(true)
	end

	imgui.text("reset")
	for _, field in ipairs(self.game.difficultyModel.registry.fields) do
		if imgui.button("reset diffcalc " .. field, field, inactive) then
			self.game.cacheModel.chartdiffsRepo:resetDiffcalcField(field)
		end
		just.sameline()
	end
	just.next()

	if imgui.button("delete chartdiffs", "delete all chartdiffs", inactive) then
		self.game.cacheModel.chartdiffsRepo:deleteChartdiffs()
	end

	if imgui.button("delete modified chartdiffs", "delete modified chartdiffs", inactive) then
		self.game.cacheModel.chartdiffsRepo:deleteModifiedChartdiffs()
	end

	if imgui.button("delete selected chartdiff", "delete selected chartdiff", inactive) then
		local chartview = self.game.selectModel.chartview
		self.game.cacheModel.chartdiffsRepo:deleteChartdiffs({id = assert(chartview.chartdiff_id)})
	end

	if imgui.button("delete chartdiff selected", "delete chartdiff of selected chart") then
		local chartview = self.game.selectModel.chartview
		self.game.cacheModel.chartdiffsRepo:deleteChartdiffs({id = assert(chartview.chartdiff_id)})
	end

	if imgui.button("delete all chartdiff selected", "delete all chartdiffs of selected chart") then
		local chartview = self.game.selectModel.chartview
		self.game.cacheModel.chartdiffsRepo:deleteChartdiffs({
			hash = assert(chartview.hash),
			index = assert(chartview.index),
		})
	end

	imgui.separator()

	if imgui.button("reset chartfiles", "reset chartfiles.hash", inactive) then
		self.game.cacheModel.chartfilesRepo:resetChartfileHash()
	end

	imgui.separator()
	imgui.text("chartmetas deletion")
	if imgui.button("delete chartmetas", "delete all chartmetas", inactive) then
		self.game.cacheModel.chartmetasRepo:deleteChartmetas()
	end
	for _, format in ipairs(formats) do
		if imgui.button("delete chartmetas " .. format, format, inactive) then
			self.game.cacheModel.chartmetasRepo:deleteChartmetas({format = format})
		end
		just.sameline()
	end
	just.next()

	imgui.separator()
	imgui.text("debug")


	if imgui.button("compute diff", "compute diff") then
		local chartdiff = self.game.selectModel.chartview
		local chart = self.game.selectModel:loadChartAbsolute()
		ModifierModel:apply(chartdiff.modifiers, chart)
		self.game.difficultyModel:compute({}, chart, 1)
	end
end

return modal
