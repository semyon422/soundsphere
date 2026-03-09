local ElasticList = require("yi.views.select.ElasticList")

---@class yi.ChartGrid : yi.ElasticList
---@operator call: yi.ChartGrid
local ChartGrid = ElasticList + {}

ChartGrid.id = "ChartGrid"
ChartGrid.FadeDuration = 0.25

function ChartGrid:load()
	ElasticList.load(self)
	self.chart_selector = self:getGame().chartSelector
	self.chart_store = self.chart_selector.stores[2]
	self.chart_store.onChanged:add(self)
	self.grid_alpha = 1
	self:reloadItems()

	local res = self:getResources()
	self.font = res:getFont("bold", 36)
	self.font_small = res:getFont("bold", 16)
end

function ChartGrid:destroy()
	if self.chart_store then
		self.chart_store.onChanged:remove(self)
		self.chart_store = nil
	end
	ElasticList.destroy(self)
end

---@param event table
function ChartGrid:receive(event)
	if event.count ~= nil then
		self:reloadItems()
		self.grid_alpha = 0
	end
end

---@param dt number
function ChartGrid:update(dt)
	ElasticList.update(self, dt)

	if self.grid_alpha < 1 then
		self.grid_alpha = math.min(1, self.grid_alpha + dt / self.FadeDuration)
	end
end

---@return rizu.library.LocatedChartview[]
function ChartGrid:getItems()
	local store = self.chart_selector.stores[2]

	local items = {} ---@type rizu.library.LocatedChartview[]
	for i = 1, store:count() do
		items[i] = store:get(i)
	end

	return items
end

---@return integer
function ChartGrid:getSelectedIndex()
	return self.chart_selector.state.levels[2].index
end

---@param index integer
function ChartGrid:selectItem(index)
	self.chart_selector:scrollLevel(2, nil, index)
end

local NOOB = {0.78, 0.95, 1, 1}
local ROOKIE = {0.66, 1, 0.51, 1}
local CASUAL = {0.98, 1, 0.41, 1}
local GROOVER = {1, 0.88, 0.5, 1}
local SKILLED = {1, 0.7, 0.54, 1}
local VETERAN = {1, 0.55, 0.54, 1}
local EXPERT = {1, 0.51, 0.63, 1}
local MASTER = {1, 0.53, 0.84, 1}
local DEMI_GOD = {0.89, 0.45, 1, 1}
local DEITY = {0.78, 0.23, 1, 1}

---@param d number Difficulty normalized
local function getDiffColor(d)
	if d <= 0.1 then
		return NOOB
	elseif d <= 0.2 then
		return ROOKIE
	elseif d <= 0.3 then
		return CASUAL
	elseif d <= 0.4 then
		return GROOVER
	elseif d <= 0.5 then
		return SKILLED
	elseif d <= 0.6 then
		return VETERAN
	elseif d <= 0.7 then
		return EXPERT
	elseif d <= 0.8 then
		return MASTER
	elseif d <= 0.9 then
		return DEMI_GOD
	end

	return DEITY
end

local c = {1, 1, 1, 1}

---@param item table
---@param w number
---@param h number
---@param is_selected boolean
function ChartGrid:drawItem(item, w, h, is_selected)
	local alpha = self.grid_alpha or 1
	local d = math.sqrt(w / self.SelectedWidth)
	local diff_n = math.min((item.difficulty or 0) / 30, 30)
	local color = getDiffColor(diff_n)
	c[1] = color[1] * d
	c[2] = color[2] * d
	c[3] = color[3] * d
	c[4] = alpha
	love.graphics.setColor(c)

	love.graphics.rectangle("fill", 0, 0, w, h)

	local difficulty = ("%0.01f"):format(item.difficulty or 0)
	local mode = (item.inputmode or ""):gsub("key", "K"):gsub("scratch", "S")
	d = w / self.SelectedWidth
	local font = self.font
	love.graphics.setFont(font)
	love.graphics.setColor(0, 0, 0, alpha)

	love.graphics.print(
		difficulty,
		w / 2, h / 2 - 2,
		0,
		d, d,
		font:getWidth(difficulty) / 2,
		font:getHeight() - 15
	)

	local font_small = self.font_small
	love.graphics.setFont(font_small)
	love.graphics.setColor(0, 0, 0, alpha)
	love.graphics.print(
		mode,
		w / 2, h / 2 + 6,
		0,
		1, 1,
		font_small:getWidth(mode) / 2,
		0
	)
end

return ChartGrid
