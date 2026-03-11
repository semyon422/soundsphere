local class = require("class")
local imgui = require("imgui")
local just = require("just")
local ModalImView = require("ui.imviews.ModalImView")
local spherefonts = require("sphere.assets.fonts")
local _transform = require("gfx_util").transform

local DlcModalViewInstance = class()

local transform = {{1 / 2, -16 / 9 / 2}, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}
local w, h = 1400, 800
local _h = 50
local r = 12

function DlcModalViewInstance:new(game)
	self.game = game
	self.dlcManager = game.dlcManager
	self.query = ""
	self.results = {}
	self.searching = false
	self.error = nil
	self.selectedType = "chart"
	self.selectedStatus = "ranked"
	self.scrollY = 0
	self.taskScrollY = 0
	self.page = 1
	
	self.dlcManager.onTaskUpdated:add({
		receive = function()
			-- Progress update redraw
		end
	})

	self:search(1)
end

function DlcModalViewInstance:search(page)
	if self.searching then return end
	self.page = page or 1
	self.searching = true
	self.error = nil
	self.results = {}
	
	coroutine.wrap(function()
		pprint({
			page = self.page,
			status = self.selectedStatus
		})
		local results, err = self.dlcManager:search(self.query, self.selectedType, {
			page = self.page,
			status = self.selectedStatus
		})
		self.searching = false
		if results then
			self.results = results
		else
			self.error = err
		end
	end)()
end

function DlcModalViewInstance:draw(quit)
	if quit then return true end

	imgui.setSize(w, h, w / 4, _h)
	love.graphics.setFont(spherefonts.get("Noto Sans", 24))
	love.graphics.replaceTransform(_transform(transform))
	love.graphics.translate((1920 - w) / 2, (1080 - h) / 2)

	-- Background
	love.graphics.setColor(0, 0, 0, 0.9)
	love.graphics.rectangle("fill", 0, 0, w, h, r)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle("line", 0, 0, w, h, r)

	just.push()
	
	-- Header / Search
	just.indent(20)
	just.next(0, 20)

	local search_w = w * 0.4
	local changed, new_query = imgui.TextInput("dlc_search", {self.query, "Search DLC..."}, nil, search_w, _h)
	if changed == "text" then
		self.query = new_query
	end
	
	just.sameline()
	if imgui.TextButton("dlc_search_btn", "Search", 100, _h) or (just.focused_id == "dlc_search" and just.keypressed("return")) then
		self:search(1)
	end
	
	just.sameline()
	local type_w = 120
	local i_type = imgui.SpoilerList("dlc_type", type_w, _h, {"chart", "skin", "hitsound"}, self.selectedType)
	if i_type then
		self.selectedType = ({"chart", "skin", "hitsound"})[i_type]
		self:search(1)
	end

	just.sameline()
	local status_w = 150
	local statuses = {"any", "ranked", "qualified", "loved", "pending", "wip", "graveyard"}
	local i_status = imgui.SpoilerList("dlc_status", status_w, _h, statuses, self.selectedStatus)
	if i_status then
		self.selectedStatus = statuses[i_status]
		self:search(1)
	end

	just.sameline()
	-- Pagination buttons
	if imgui.TextButton("dlc_prev_page", "<", 40, _h) then
		if self.page > 1 then
			self:search(self.page - 1)
		end
	end
	
	just.sameline()
	love.graphics.setFont(spherefonts.get("Noto Sans", 20))
	just.text(tostring(self.page))
	love.graphics.setFont(spherefonts.get("Noto Sans", 24))

	just.sameline()
	if imgui.TextButton("dlc_next_page", ">", 40, _h) then
		self:search(self.page + 1)
	end

	just.next(0, 20)
	
	-- Main Content Area
	local results_w = w * 0.65
	local tasks_w = w - results_w - 60
	
	-- Results Column
	just.push()
	just.text("Results" .. (self.searching and " (Searching...)" or ""))
	if self.error then
		love.graphics.setColor(1, 0, 0, 1)
		just.text("Error: " .. self.error)
		love.graphics.setColor(1, 1, 1, 1)
	end
	
	imgui.Container("dlc_results_cont", results_w, h - 180, 12, 40, self.scrollY)
	for _, res in ipairs(self.results) do
		local id = res.id
		local task = self.dlcManager.tasks[id]
		
		just.push()
		love.graphics.rectangle("line", 0, 0, results_w - 20, 80, 4)
		just.indent(10)
		just.next(0, 5)
		love.graphics.setFont(spherefonts.get("Noto Sans", 20))
		just.text(res.artist .. " - " .. res.title)
		love.graphics.setFont(spherefonts.get("Noto Sans", 16))
		just.text("By: " .. (res.creator or "Unknown"))
		
		just.sameline()
		love.graphics.translate(results_w - 160, -25)
		if task then
			imgui.Label("dlc_res_status_" .. id, task.status, 40)
		else
			if imgui.TextButton("dlc_dl_btn_" .. id, "Download", 120, 40) then
				self.dlcManager:download(id, self.selectedType, "mino", res)
			end
		end
		
		just.pop()
		just.next(0, 90)
	end
	self.scrollY = imgui.Container()
	just.pop()
	
	-- Tasks Column
	just.push()
	love.graphics.translate(results_w + 20, 0)
	just.text("Active Tasks")
	
	imgui.Container("dlc_tasks_cont", tasks_w, h - 180, 12, 40, self.taskScrollY)
	for id, task in pairs(self.dlcManager.tasks) do
		just.push()
		love.graphics.rectangle("line", 0, 0, tasks_w - 20, 100, 4)
		just.indent(10)
		just.next(0, 5)
		love.graphics.setFont(spherefonts.get("Noto Sans", 16))
		local title = task.metadata and task.metadata.title or tostring(id)
		just.text(title)
		
		local pb_w = tasks_w - 40
		local pb_h = 10
		love.graphics.rectangle("line", 0, 25, pb_w, pb_h)
		love.graphics.rectangle("fill", 0, 25, pb_w * (task.progress or 0), pb_h)
		
		just.next(0, 45)
		local speed_kb = (task.speed or 0) / 1024
		local speed_text = speed_kb > 1024 and ("%.2f MB/s"):format(speed_kb / 1024) or ("%.2f KB/s"):format(speed_kb)
		just.text(task.status .. " " .. speed_text)
		
		just.pop()
		just.next(0, 110)
	end
	self.taskScrollY = imgui.Container()
	just.pop()
	
	just.pop()
	
	love.graphics.translate(0, h - 60)
	if imgui.TextButton("dlc_close", "Close", 120, 40) or just.keypressed("escape") then
		return true
	end
end

local dlcModal
return ModalImView(function(gv, quit)
	if not dlcModal then
		dlcModal = DlcModalViewInstance(gv.game)
	end
	return dlcModal:draw(quit)
end)
