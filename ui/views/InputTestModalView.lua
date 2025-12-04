local just = require("just")
local loop = require("loop")
local stbl = require("stbl")
local imgui = require("imgui")
local thread = require("thread")
local ModalImView = require("ui.imviews.ModalImView")
local _transform = require("gfx_util").transform
local spherefonts = require("sphere.assets.fonts")
local version = require("version")
local audio = require("audio")
local utf8validate = require("utf8validate")

local transform = {{1 / 2, -16 / 9 / 2}, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}

local sections = {
	"test1",
}
local section = sections[1]

local scrollY = {}

local w, h = 1600, 900
local _h = 55
local r = 8

local window_id = "imgui tests window"

local drawSection = {}

---@param self table?
---@return boolean?
local function draw(self, quit)
	if quit then
		loop.input_debug = false
		return true
	end

	loop.input_debug = true

	imgui.setSize(w, h, w / 4, _h)

	love.graphics.setFont(spherefonts.get("Noto Sans", 24))

	love.graphics.replaceTransform(_transform(transform))
	love.graphics.translate((1920 - w) / 2, (1080 - h) / 2)

	love.graphics.setColor(0, 0, 0, 0.8)
	love.graphics.rectangle("fill", 0, 0, w, h, r)
	love.graphics.setColor(1, 1, 1, 1)

	just.push()
	just.push()
	local tabsw
	section, tabsw = imgui.vtabs("imgui tests tabs", section, sections)
	just.pop()
	love.graphics.translate(tabsw, 0)

	local inner_w = w - tabsw
	imgui.setSize(inner_w, h, inner_w / 2, _h)

	scrollY[section] = scrollY[section] or 0
	imgui.Container(window_id, inner_w, h, _h / 3, _h * 2, scrollY[section])

	drawSection[section](self)
	just.emptyline(8)

	scrollY[section] = imgui.Container()
	just.pop()

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle("line", 0, 0, w, h, r)
end

function drawSection:test1()
	love.graphics.setFont(spherefonts.get("Noto Sans", 20))
	local count = #loop.input_events
	for i = count, count - 100, -1 do
		local event = loop.input_events[i]
		if event then
			imgui.text(stbl.encode(event))
		end
	end
end

return ModalImView(draw)
