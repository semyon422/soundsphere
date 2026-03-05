local just = require("just")
local imgui = require("imgui")
local ModalImView = require("ui.imviews.ModalImView")
local _transform = require("gfx_util").transform
local spherefonts = require("sphere.assets.fonts")
local theme = require("imgui.theme")
local ModifierModel = require("sphere.models.ModifierModel")
local table_util = require("table_util")

local transform = {{1 / 2, -16 / 9 / 2}, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}

local scrollY = 0
local scrollYlist = 0
local selected_id = 1

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
	---@type sphere.GameController
	local game = self.game

	local locationsRepo = game.library.locationsRepo
	local locations = game.library.locations
	local _locations = locations.locations

	local list_w = inner_w / 3

	local selected_loc = table_util.find(_locations, function(loc)
		return loc.id == selected_id
	end)

	if not selected_loc and #_locations > 0 then
		selected_loc = _locations[1]
		selected_id = selected_loc.id
	end

	just.push()
	imgui.List("mount points", list_w, h - _h, _h / 2, _h, scrollYlist)
	for i, item in ipairs(_locations) do
		local name = item.name
		if selected_id == item.id then
			name = "> " .. name
		end
		if imgui.TextOnlyButton("mount item" .. i, name, w, _h * theme.size, "left") then
			selected_id = item.id
		end
	end
	scrollYlist = imgui.List()

	if imgui.TextButton("create loc", "create location", list_w, _h) then
		local location = locationsRepo:insertLocation({
			name = "unnamed",
			is_relative = false,
			is_internal = false,
		})
		locations:selectLocations()
		selected_id = location.id
	end

	just.pop()

	love.graphics.translate(list_w, 0)

	if not selected_loc then
		return
	end

	local location_info = locations.info[selected_id]

	local path = selected_loc.path
	if selected_loc.is_internal then
		just.indent(8)
		just.text("Internal")
	end
	just.indent(8)
	just.text("Status: " .. (locations.status[selected_id] or "unknown"))
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
			locations:selectLocations()
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
		locations:deleteCharts(selected_loc.id)
		self.game.chartSelector:noDebouncePullNoteChartSet()
	end

	if not selected_loc.is_internal and imgui.button("delete dir", "delete location", inactive) then
		locations:deleteLocation(selected_id)
		locations:selectLocations()
		selected_id = 1
		self.game.chartSelector:noDebouncePullNoteChartSet()
	end
end

local formats = {"bms", "ksh", "mid", "ojn", "osu", "qua", "sph", "sm"}
function section_draw.database(self)
	---@type sphere.GameController
	local game = self.game
	local library = game.library

	local cacheStatus = library.statusUpdate
	imgui.text("metas: " .. cacheStatus.chartmetas)
	imgui.text("diffs: " .. cacheStatus.chartdiffs)
	imgui.text("plays: " .. cacheStatus.chartplays)

	if imgui.button("cacheStatus update", "update status") then
		cacheStatus:update()
	end

	local inactive = not love.keyboard.isDown("lshift")
	imgui.text("Hold left shift to make inactive buttons active")

	imgui.separator()
	imgui.text("chartdiffs")

	if imgui.button("compute cds", "compute missing") then
		library:computeChartdiffs()
	end
	if imgui.button("compute incomplete cds", "compute incomplete") then
		library:computeIncompleteChartdiffs(false)
	end
	if imgui.button("compute incomplete cds pp", "compute incomplete, use preview when possible") then
		library:computeIncompleteChartdiffs(true)
	end
	if imgui.button("compute chartplays", "compute chartplays") then
		library:computeChartplays()
	end

	imgui.separator()
	imgui.text("reset")
	for _, field in ipairs(self.game.difficultyModel.registry.fields) do
		if imgui.button("reset diffcalc " .. field, field, inactive) then
			library.chartsRepo:resetDiffcalcField(field)
		end
		just.sameline()
	end
	just.next()

	imgui.separator()
	imgui.text("delete")
	if imgui.button("delete charts cache", "delete all chart-files/sets/metas/diffs", inactive) then
		library.chartfilesRepo:deleteChartfiles()
		library.chartfilesRepo:deleteChartfileSets()
		library.chartsRepo:deleteChartmetas()
		library.chartsRepo:deleteChartdiffs()
	end

	if imgui.button("delete chartdiffs", "delete all chartdiffs", inactive) then
		library.chartsRepo:deleteChartdiffs()
	end

	if imgui.button("delete modified chartdiffs", "delete modified chartdiffs", inactive) then
		library.chartsRepo:deleteModifiedChartdiffs()
	end

	if imgui.button("delete selected chartdiff", "delete selected chartdiff", inactive) then
		local chartview = self.game.chartSelector.chartview
		library.chartsRepo:deleteChartdiff(chartview.chartdiff_id)
	end

	if imgui.button("delete chartdiff selected", "delete chartdiff of selected chart") then
		local chartview = self.game.chartSelector.chartview
		library.chartsRepo:deleteChartdiff(chartview.chartdiff_id)
	end

	if imgui.button("delete all chartdiff selected", "delete all chartdiffs of selected chart") then
		local chartview = self.game.chartSelector.chartview
		library.chartsRepo:deleteChartdiffsByHashIndex(chartview.hash, chartview.index)
	end

	imgui.separator()

	if imgui.button("reset chartfiles", "reset chartfiles.hash", inactive) then
		library.chartfilesRepo:resetChartfileHash()
	end

	imgui.separator()
	imgui.text("chartmetas deletion")
	if imgui.button("delete chartmetas", "delete all chartmetas", inactive) then
		library.chartsRepo:deleteChartmetas()
	end
	for _, format in ipairs(formats) do
		if imgui.button("delete chartmetas " .. format, format, inactive) then
			library.chartsRepo:deleteChartmetasByFormat(format)
		end
		just.sameline()
	end
	just.next()

	imgui.separator()
	imgui.text("debug")


	if imgui.button("compute diff", "compute diff") then
		local chartdiff = self.game.chartSelector.chartview
		local chart = self.game.chartSelector:loadChartAbsolute()
		ModifierModel:apply(chartdiff.modifiers, chart)
		self.game.difficultyModel:compute({}, chart, 1)
	end

	if imgui.button("vacuum", "vacuum") then
		library.gdb.db:exec("VACUUM;")
	end
end

return modal
