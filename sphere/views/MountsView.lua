local just = require("just")
local imgui = require("imgui")
local ModalImView = require("sphere.imviews.ModalImView")
local _transform = require("gfx_util").transform
local spherefonts = require("sphere.assets.fonts")
local theme = require("imgui.theme")

local transform = {{1 / 2, -16 / 9 / 2}, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}

local scrollY = 0
local scrollYlist = 0

local w, h = 1024, 1080 / 2
local _w, _h = w / 2, 55
local r = 8
local window_id = "MountsView"
local selected_loc
local location_info

local sections = {
	"locations",
	"database",
}
local section = sections[1]

local section_draw = {}

local function get_cache_text(self)
	local cacheModel = self.game.cacheModel
	local shared = cacheModel.shared
	local state = shared.state

	local text = ""
	if state == 1 then
		text = ("searching for charts: %d"):format(shared.chartfiles_count)
	elseif state == 2 then
		local pos = (shared.chartfiles_current - 1) / (shared.chartfiles_count - 1)
		text = ("creating cache: %0.2f%%"):format(pos * 100)
	elseif state == 0 then
		text = "update"
	end

	return text
end

local function get_location_info(self, location_id)
	local chartfilesRepo = self.game.cacheModel.chartfilesRepo

	return {
		chartfile_sets = chartfilesRepo:countChartfileSets({location_id = location_id}),
		chartfiles = chartfilesRepo:countChartfiles({location_id = location_id}),
		hashed_chartfiles = chartfilesRepo:countChartfiles({
			location_id = location_id,
			hash__isnotnull = true,
		}),
	}
end

local modal = ModalImView(function(self)
	if not self then
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
	imgui.Container(window_id, w, h, _h / 3, _h * 2, scrollY)

	just.push()
	local tabsw
	section, tabsw = imgui.vtabs("settings tabs", section, sections)
	just.pop()

	local inner_w = w - tabsw
	imgui.setSize(inner_w, h, inner_w / 2, _h)
	love.graphics.translate(tabsw, 0)

	love.graphics.setColor(1, 1, 1, 1)
	section_draw[section](self, inner_w)
	just.emptyline(8)

	scrollY = imgui.Container()
	just.pop()

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle("line", 0, 0, w, h, r)
end)

function section_draw.locations(self, inner_w)
	local locationManager = self.game.cacheModel.locationManager
	local locations = locationManager.locations

	local list_w = inner_w / 3

	just.push()
	imgui.List("mount points", list_w, h, _h / 2, _h, scrollYlist)
	local has_selected
	for i, item in ipairs(locations) do
		local location = item.name
		if selected_loc == item then
			location = "> " .. location
			has_selected = true
		end
		if imgui.TextOnlyButton("mount item" .. i, location, w, _h * theme.size, "left") or not selected_loc then
			selected_loc = item
			location_info = get_location_info(self, item.id)
			has_selected = true
		end
	end
	if not has_selected then
		selected_loc = nil
	end
	scrollYlist = imgui.List()
	just.pop()

	love.graphics.translate(list_w, 0)

	if not selected_loc then
		return
	end

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
	imgui.url("open dir", path, path)

	local cache_text = get_cache_text(self)
	if imgui.button("cache_button", cache_text) then
		self.game.selectController:updateCacheLocation(selected_loc.id)
	end

	imgui.text("chartfile_sets: " .. location_info.chartfile_sets)
	imgui.text(("chartfiles: %s/%s"):format(
		location_info.hashed_chartfiles,
		location_info.chartfiles
	))

	if imgui.button("reset dir", "delete charts cache") then
		locationManager:deleteCharts(selected_loc.id)
		location_info = get_location_info(self, selected_loc.id)
		self.game.selectModel:noDebouncePullNoteChartSet()
	end
	if not selected_loc.is_internal and imgui.button("delete dir", "delete location") then
		locationManager:deleteLocation(selected_loc.id)
		locationManager:load()
		self.game.selectModel:noDebouncePullNoteChartSet()
	end
end

function section_draw.database(self)
	local cacheStatus = self.game.cacheModel.cacheStatus
	imgui.text("chartmetas: " .. cacheStatus.chartmetas)
	imgui.text("chartdiffs: " .. cacheStatus.chartdiffs)

	if imgui.button("cacheStatus update", "update status") then
		cacheStatus:update()
	end
	if imgui.button("reset chartfiles", "reset chartfiles.hash") then
		self.game.cacheModel.chartfilesRepo:resetChartfileHash()
	end
	if imgui.button("delete chartmetas", "delete chartmetas") then
		self.game.cacheModel.chartmetasRepo:deleteChartmetas()
	end
	if imgui.button("delete chartdiffs", "delete chartdiffs") then
		self.game.cacheModel.chartdiffsRepo:deleteChartdiffs()
	end

	local cacheModel = self.game.cacheModel
	local state = cacheModel.shared.state
	if state == 0 or state == 3 then
		if imgui.button("computeScores", "compute chartdiffs") then
			cacheModel:computeChartdiffs()
		end
	else
		local count = cacheModel.shared.chartfiles_count
		local current = cacheModel.shared.chartfiles_current

		local progress = ("%0.2f%% %s/%s"):format(current / count * 100, current, count)

		if imgui.button("stopTask", progress) then
			cacheModel:stopTask()
		end
	end
end

return modal
