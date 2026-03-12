local Screen = require("yi.views.Screen")
local View = require("yi.views.View")
local Label = require("yi.views.Label")
local Textbox = require("yi.views.components.Textbox")
local SelectButton = require("yi.views.select.SelectButton")
local Button = require("yi.views.components.Button")
local ScrollList = require("yi.views.scroll_list.ScrollList")
local Colors = require("yi.Colors")
local h = require("yi.h")

---@class rizu.select.DlcResultList : yi.ScrollList
---@overload fun(screen: rizu.select.DlcScreen): rizu.select.DlcResultList
local DlcResultList = ScrollList + {}

function DlcResultList:new(screen)
	ScrollList.new(self)
	self.screen = screen
	self.item_height = 100
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

	love.graphics.setColor(Colors.text)
	local font_title = self.screen.res:getFont("bold", 20)
	local font_sub = self.screen.res:getFont("regular", 14)

	local title = result.title or result.name or "Unknown"
	local subtitle = (result.artist or result.author or "Unknown") .. " // " .. (result.creator or "")
	
	love.graphics.setFont(font_title)
	love.graphics.print(title, padding, y + padding)
	
	love.graphics.setFont(font_sub)
	love.graphics.print(subtitle, padding, y + padding + 30)

	-- Download Button (Visual only for now)
	love.graphics.setColor(Colors.accent)
	love.graphics.rectangle("line", w - 120, y + 30, 100, 40, 4, 4)
	love.graphics.printf("Download", w - 120, y + 40, 100, "center")
end

function DlcResultList:onMouseClick(e)
	local _, imy = self.transform:inverseTransformPoint(e.x, e.y)
	local clicked_index = math.floor(self:yToIndex(imy))

	local count = self:getItemCount()
	if clicked_index >= 1 and clicked_index <= count then
		self:setSelectedIndex(clicked_index)
		
		-- Check if click was on download button
		local lx, _ = self.transform:inverseTransformPoint(e.x, e.y)
		local w = self:getCalculatedWidth()
		if lx > w - 120 and lx < w - 20 then
			self.screen:downloadResult(clicked_index)
		end
	end
end

---@class rizu.select.DlcScreen : yi.Screen
---@overload fun(): rizu.select.DlcScreen
local DlcScreen = Screen + {}

function DlcScreen:new()
	Screen.new(self)
	self.results = {}
	self.selected_index = 1
	self.current_provider = "mino"
	self.current_type = "set"
	self.search_timer = 0
	self.search_delay = 0.5 -- seconds
	self.pending_query = nil
	self.is_loading = false
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
	self.result_list = DlcResultList(self)
	self.loading_label = Label(self.res:getFont("regular", 16), "Loading...")

	self:addArray({
		-- Content Area
		h(View(), {w = "100%", h = "100%", margin = {80, 0, 0, 0}, padding = {20, 20, 20, 20}}, {
			h(self.result_list, {w = "100%", h = "100%", stencil = true})
		}),

		-- Header
		h(View(), {w = "100%", h = 80, background_color = Colors.header_footer, padding = {0, 20, 0, 20}, arrange = "flow_row", align_items = "center", justify_content = "space_between"}, {
			h(View(), {arrange = "flow_row", align_items = "center", gap = 20}, {
				h(Label(self.title_font, "DLC")),
				
				-- Provider Toggles
				h(View(), {arrange = "flow_row", gap = 10}, {
					h(Button("Mino", function() self:setProvider("mino", "set") end), {w = 100, h = 40}),
					h(Button("Akatsuki", function() self:setProvider("akatsuki", "set") end), {w = 100, h = 40}),
					h(Button("Ripple", function() self:setProvider("ripple", "set") end), {w = 100, h = 40}),
					h(Button("Etterna", function() self:setProvider("etterna", "pack") end), {w = 100, h = 40}),
				}),
				h(Textbox("", "Search...", function(text) self:onSearch(text) end), {w = 400}),
				h(self.loading_label, {enabled = false}),
			}),
			
			h(SelectButton(), {w = 45, h = 45, icon = "", callback = function() self.parent:set("select") end})
		}),
	})
end

function DlcScreen:setProvider(name, _type)
	self.current_provider = name
	self.current_type = _type
	self:triggerSearch(self.query or "")
end

function DlcScreen:onSearch(text)
	self.query = text
	self.pending_query = text
	self.search_timer = self.search_delay
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
		local results, err = self.dlc_manager:search(text, {}, self.current_provider)
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
	
	print("Downloading:", result.title or result.name)
	self.dlc_manager:download(result.id, self.current_type, self.current_provider, result)
end

function DlcScreen:onKeyDown(e)
	if e.key == "escape" then
		self.parent:set("select")
		return true
	end
end

return DlcScreen
