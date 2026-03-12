local Screen = require("yi.views.Screen")
local View = require("yi.views.View")
local Label = require("yi.views.Label")
local Textbox = require("yi.views.components.Textbox")
local SelectButton = require("yi.views.select.SelectButton")
local Button = require("yi.views.components.Button")
local ScrollList = require("yi.views.scroll_list.ScrollList")
local RemoteImage = require("yi.views.components.RemoteImage")
local Colors = require("yi.Colors")
local h = require("yi.h")
local table_util = require("table_util")
local LayoutBox = require("ui.layout.LayoutBox")

---@class yi.views.dlc.DlcResultList : yi.ScrollList
---@overload fun(screen: yi.views.dlc.DlcScreen): yi.views.dlc.DlcResultList
local DlcResultList = ScrollList + {}

function DlcResultList:new(screen)
	ScrollList.new(self)
	self.screen = screen
	self.item_height = 120
	self.thumbs = {} ---@type {[string|number]: yi.components.RemoteImage}
end

function DlcResultList:getItemCount()
	return #self.screen.results
end

function DlcResultList:getSelectedIndex()
	return self.screen.selected_index
end

function DlcResultList:setSelectedIndex(index)
	self.screen.selected_index = index
end

function DlcResultList:drawItem(index, y, is_selected)
	local result = self.screen.results[index]
	if not result then return end

	local w = self:getCalculatedWidth()
	local h_item = self.item_height
	local padding = 10

	-- Background
	if is_selected then
		love.graphics.setColor(Colors.accent[1], Colors.accent[2], Colors.accent[3], 0.2)
		love.graphics.rectangle("fill", 0, y, w, h_item)
	end

	-- Thumbnail
	local thumb_w = 160
	local thumb_h = 60
	local thumb_x = padding
	local thumb_y = y + padding
	
	local thumb_url = result.thumbnail_url
	if thumb_url then
		local thumb = self.thumbs[result.id]
		if not thumb then
			thumb = RemoteImage(thumb_url)
			thumb:mount(self.ctx)
			self.thumbs[result.id] = thumb
		end
		thumb.layout_box.x.size = thumb_w
		thumb.layout_box.y.size = thumb_h
		thumb:updateTransforms()
		
		love.graphics.push()
		love.graphics.translate(thumb_x, thumb_y)
		thumb:draw()
		love.graphics.pop()
	else
		love.graphics.setColor(Colors.outline)
		love.graphics.rectangle("fill", thumb_x, thumb_y, thumb_w, thumb_h, 4, 4)
	end

	local content_x = thumb_x + thumb_w + 15
	love.graphics.setColor(Colors.text)
	local font_title = self.screen.res:getFont("bold", 20)
	local font_sub = self.screen.res:getFont("regular", 14)

	local title = result.title or result.name or "Unknown"
	local subtitle = (result.artist or result.author or "Unknown") .. " // " .. (result.creator or "")
	
	love.graphics.setFont(font_title)
	love.graphics.print(title, content_x, y + padding)
	
	love.graphics.setFont(font_sub)
	love.graphics.print(subtitle, content_x, y + padding + 30)

	-- Difficulties
	local diff_y = y + padding + 60
	local diff_x = content_x
	local diff_size = 12
	local diff_gap = 5
	
	if result.difficulties then
		for i, diff in ipairs(result.difficulties) do
			if i > 15 then break end -- Limit display
			
			local sr = 0
			if type(diff) == "table" then
				sr = diff.difficulty_rating or diff.sr or 0
			elseif type(diff) == "string" then
				-- Extract star from [2.39⭐] format if present
				sr = tonumber(diff:match("%[(%d+%.%d+)⭐%]")) or 0
			end
			
			-- Draw star/dot
			love.graphics.setColor(Colors.accent)
			love.graphics.circle("fill", diff_x + diff_size/2, diff_y + diff_size/2, diff_size/2)
			
			diff_x = diff_x + diff_size + diff_gap
		end
	end

	-- Download Button
	local btn_w, btn_h = 100, 40
	local btn_x = w - btn_w - 20
	local btn_y = y + (h_item - btn_h) / 2
	
	love.graphics.setColor(Colors.accent)
	love.graphics.rectangle("line", btn_x, btn_y, btn_w, btn_h, 4, 4)
	love.graphics.printf("Download", btn_x, btn_y + 10, btn_w, "center")
end

function DlcResultList:onMouseClick(e)
	local lx, imy = self.transform:inverseTransformPoint(e.x, e.y)
	local clicked_index = math.floor(self:yToIndex(imy))

	local count = self:getItemCount()
	if clicked_index >= 1 and clicked_index <= count then
		self:setSelectedIndex(clicked_index)
		
		local w = self:getCalculatedWidth()
		if lx > w - 120 and lx < w - 20 then
			self.screen:downloadResult(clicked_index)
		end
	end
end

---@class yi.views.dlc.DlcTaskList : yi.ScrollList
---@overload fun(screen: yi.views.dlc.DlcScreen): yi.views.dlc.DlcTaskList
local DlcTaskList = ScrollList + {}

function DlcTaskList:new(screen)
	ScrollList.new(self)
	self.screen = screen
	self.item_height = 60
end

function DlcTaskList:getItemCount()
	return #self.screen.task_ids
end

function DlcTaskList:getSelectedIndex() return 1 end

function DlcTaskList:drawItem(index, y, is_selected)
	local task_id = self.screen.task_ids[index]
	local task = self.screen.dlc_manager.tasks[task_id]
	if not task then return end

	local w = self:getCalculatedWidth()
	local h_item = self.item_height
	local padding = 5

	love.graphics.setColor(Colors.text)
	local font = self.screen.res:getFont("regular", 14)
	love.graphics.setFont(font)
	
	local title = task.metadata and (task.metadata.title or task.metadata.name) or tostring(task.id)
	love.graphics.print(title, padding, y + padding)
	
	-- Progress bar
	local bar_w = w - padding * 2
	local bar_h = 10
	love.graphics.setColor(Colors.outline)
	love.graphics.rectangle("fill", padding, y + 35, bar_w, bar_h, 2, 2)
	
	love.graphics.setColor(Colors.accent)
	love.graphics.rectangle("fill", padding, y + 35, bar_w * (task.progress or 0), bar_h, 2, 2)
	
	local status_text = string.format("%s (%.1f%%)", task.status, (task.progress or 0) * 100)
	love.graphics.printf(status_text, padding, y + padding, bar_w, "right")
end

---@class yi.views.dlc.DlcScreen : yi.Screen
---@overload fun(): yi.views.dlc.DlcScreen
local DlcScreen = Screen + {}

function DlcScreen:new()
	Screen.new(self)
	self.results = {}
	self.selected_index = 1
	self.current_tab = "mino" -- "mino", "beatconnect", "etterna", "direct"
	self.current_provider = "mino"
	self.current_type = "set"
	self.current_page = 1
	self.current_status = "ranked"
	self.current_mirror = "provider" -- "provider", "mino", "beatconnect"
	self.search_timer = 0
	self.search_delay = 0.5
	self.pending_query = nil
	self.task_ids = {}
end

function DlcScreen:load()
	Screen.load(self)
	local game = self:getGame()
	self.dlc_manager = game.dlcManager
	self.res = self:getResources()

	self:setup({
		id = "dlc",
		w = "100%",
		h = "100%",
		keyboard = true,
		background_color = Colors.background,
		arrange = "stack",
	})

	self.title_font = self.res:getFont("black", 32)
	
	self:rebuild()
end

function DlcScreen:destroyChildren()
	for i = #self.children, 1, -1 do
		local child = self.children[i]
		child.parent = nil
		child:destroy()
	end
	table_util.clear(self.children)
	self.layout_box:markDirty(bit.bor(LayoutBox.Axis.X, LayoutBox.Axis.Y))
end

function DlcScreen:rebuild()
	self:destroyChildren()
	
	local res = self.res
	
	self.result_list = DlcResultList(self)
	self.task_list = DlcTaskList(self)
	self.loading_label = Label(res:getFont("regular", 16), "Loading...")

	local is_osu = (self.current_tab == "mino" or self.current_tab == "beatconnect" or self.current_tab == "direct")
	local header_h = is_osu and 240 or 140

	self:addArray({
		-- Content Area
		h(View(), {w = "100%", h = "100%", margin = {header_h, 0, 0, 0}, arrange = "flow_row"}, {
			-- Results (Left)
			h(View(), {w = "70%", h = "100%", padding = {0, 20, 0, 20}}, {
				h(self.result_list, {w = "100%", h = "100%", stencil = true})
			}),
			-- Separator
			h(View(), {w = 2, h = "100%", background_color = Colors.outline}),
			-- Tasks (Right)
			h(View(), {w = "fill", h = "100%", padding = {0, 20, 0, 20}, arrange = "stack"}, {
				h(Label(res:getFont("bold", 18), "Active Tasks"), {align_self = "start", margin = {0, 0, 10, 10}}),
				h(self.task_list, {w = "100%", h = "100%", margin = {40, 0, 0, 0}, stencil = true})
			})
		}),

		-- Header
		h(View(), {w = "100%", h = header_h, background_color = Colors.header_footer, arrange = "flow_col", padding = {10, 20, 10, 20}}, {
			-- Row 1: Title, Tabs, Exit
			h(View(), {w = "100%", h = 55, arrange = "flow_row", align_items = "center", justify_content = "space_between"}, {
				h(View(), {arrange = "flow_row", align_items = "center", gap = 20}, {
					h(Label(self.title_font, "DLC")),
					h(View(), {arrange = "flow_row", gap = 5}, {
						h(Button("Mino", function() self:setTab("mino") end), {w = 80, h = 40, active = self.current_tab == "mino"}),
						h(Button("Beatconnect", function() self:setTab("beatconnect") end), {w = 120, h = 40, active = self.current_tab == "beatconnect"}),
						h(Button("osu!direct", function() self:setTab("direct") end), {w = 100, h = 40, active = self.current_tab == "direct"}),
						h(Button("Etterna", function() self:setTab("etterna") end), {w = 100, h = 40, active = self.current_tab == "etterna"}),
					})
				}),
				h(SelectButton(), {w = 45, h = 45, icon = "", callback = function() self.parent:set("select") end})
			}),
			
			-- Row 2: Search, Mirror Select, Pagination
			h(View(), {w = "100%", h = 55, arrange = "flow_row", align_items = "center", justify_content = "space_between"}, {
				h(View(), {arrange = "flow_row", align_items = "center", gap = 20}, {
					h(Textbox(self.query or "", "Search...", function(text) self:onSearch(text) end), {w = 300}),
					h(self.loading_label, {enabled = false}),
					
					-- Mirror Select (osu only)
					h(View(), {arrange = "flow_row", align_items = "center", gap = 10, enabled = is_osu}, {
						h(Label(res:getFont("regular", 14), "Mirror:")),
						h(Button("Provider", function() self:setMirror("provider") end), {w = 100, h = 32, active = self.current_mirror == "provider"}),
						h(Button("Mino", function() self:setMirror("mino") end), {w = 100, h = 32, active = self.current_mirror == "mino"}),
						h(Button("Beatconnect", function() self:setMirror("beatconnect") end), {w = 110, h = 32, active = self.current_mirror == "beatconnect"}),
					}),
				}),

				-- Pagination
				h(View(), {arrange = "flow_row", align_items = "center", gap = 10}, {
					h(Label(res:getFont("regular", 16), "Page " .. self.current_page)),
					h(Button("<", function() self:setPage(self.current_page - 1) end), {w = 40, h = 32}),
					h(Button(">", function() self:setPage(self.current_page + 1) end), {w = 40, h = 32}),
				})
			}),

			-- Row 3: Status Select (osu only)
			h(View(), {w = "100%", h = 50, arrange = "flow_row", align_items = "center", gap = 10, enabled = is_osu}, {
				h(Label(res:getFont("regular", 14), "Status:")),
				h(Button("All", function() self:setStatus("all") end), {w = 60, h = 32, active = self.current_status == "all"}),
				h(Button("Ranked", function() self:setStatus("ranked") end), {w = 80, h = 32, active = self.current_status == "ranked"}),
				h(Button("Qualified", function() self:setStatus("qualified") end), {w = 90, h = 32, active = self.current_status == "qualified"}),
				h(Button("Loved", function() self:setStatus("loved") end), {w = 70, h = 32, active = self.current_status == "loved"}),
				h(Button("Pending", function() self:setStatus("pending") end), {w = 80, h = 32, active = self.current_status == "pending"}),
				h(Button("Graveyard", function() self:setStatus("graveyard") end), {w = 100, h = 32, active = self.current_status == "graveyard"}),
			}),

			-- Row 4: Server Select (direct only)
			h(View(), {w = "100%", h = 50, arrange = "flow_row", align_items = "center", gap = 10, enabled = self.current_tab == "direct"}, {
				h(Label(res:getFont("regular", 14), "Server:")),
				h(Button("Akatsuki", function() self:setProvider("akatsuki") end), {w = 100, h = 32, active = self.current_provider == "akatsuki"}),
				h(Button("Ripple", function() self:setProvider("ripple") end), {w = 100, h = 32, active = self.current_provider == "ripple"}),
			}),
		}),
	})
end

function DlcScreen:setTab(tab)
	self.current_tab = tab
	self.current_page = 1
	if tab == "mino" then
		self.current_provider = "mino"
		self.current_type = "set"
	elseif tab == "beatconnect" then
		self.current_provider = "beatconnect"
		self.current_type = "set"
	elseif tab == "etterna" then
		self.current_provider = "etterna"
		self.current_type = "pack"
	elseif tab == "direct" then
		self.current_provider = "akatsuki"
		self.current_type = "set"
	end
	self:triggerSearch(self.query or "")
	self:rebuild()
end

function DlcScreen:setProvider(name)
	self.current_provider = name
	self.current_page = 1
	self:triggerSearch(self.query or "")
	self:rebuild()
end

function DlcScreen:setStatus(status)
	self.current_status = status
	self.current_page = 1
	self:triggerSearch(self.query or "")
	self:rebuild()
end

function DlcScreen:setMirror(mirror)
	self.current_mirror = mirror
	self:rebuild()
end

function DlcScreen:setPage(page)
	if page < 1 then return end
	self.current_page = page
	self:triggerSearch(self.query or "")
	self:rebuild()
end

function DlcScreen:onSearch(text)
	self.query = text
	self.pending_query = text
	self.search_timer = self.search_delay
	self.current_page = 1
end

function DlcScreen:enter()
	self.taskObserver = self.taskObserver or {
		receive = function()
			-- Force task list update
			local task_ids = {}
			for id, _ in pairs(self.dlc_manager.tasks) do
				table.insert(task_ids, id)
			end
			table.sort(task_ids)
			self.task_ids = task_ids
		end
	}
	self.dlc_manager.onTaskUpdated:add(self.taskObserver)
	-- Initial update
	self.taskObserver:receive()
end

function DlcScreen:exit()
	if self.taskObserver then
		self.dlc_manager.onTaskUpdated:remove(self.taskObserver)
	end
end

function DlcScreen:update(dt)
	if self.search_timer > 0 then
		self.search_timer = self.search_timer - dt
		if self.search_timer <= 0 and self.pending_query ~= nil then
			self:triggerSearch(self.pending_query)
			self.pending_query = nil
		end
	end
end

function DlcScreen:triggerSearch(text)
	if text == "" and self.current_provider ~= "etterna" then
		self.results = {}
		return
	end
	
	if self.loading_label then self.loading_label:setEnabled(true) end

	coroutine.wrap(function()
		local filters = { 
			page = self.current_page,
			status = self.current_status,
		}
		local results, err = self.dlc_manager:search(text, filters, self.current_provider)
		if self.loading_label then self.loading_label:setEnabled(false) end

		if results then
			self.results = results
			self.selected_index = 1
		else
			print("Search error:", err)
		end
	end)()
end

function DlcScreen:downloadResult(index)
	local result = self.results[index]
	if not result then return end
	
	print("Downloading:", result.title or result.name, "via", self.current_mirror)
	
	local metadata = table_util.copy(result)
	metadata.mirror = self.current_mirror
	
	self.dlc_manager:download(result.id, self.current_type, self.current_provider, metadata)
end

function DlcScreen:onKeyDown(e)
	if e.key == "escape" then
		self.parent:set("select")
		return true
	end
end

return DlcScreen
