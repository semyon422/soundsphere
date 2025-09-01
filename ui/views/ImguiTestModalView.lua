local just = require("just")
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
		return true
	end

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

local mx, my = 0, 0

local windowOpened = true
local win_x = 100
local win_y = -400

local counter = 0
local sliderValue = 0
local cbValue = false
local cmbValue = "a"
local listValue = "a"
local hotkeyValue = "a"
local textValue = ""
local scrollY = 0
local scrollY2 = 0

function drawSection:test1()
	local _mx, _my = love.graphics.inverseTransformPoint(love.mouse.getPosition())
	local dmx, dmy = _mx - mx, _my - my

	imgui.setSize(w, h, w / 4, _h)

	if imgui.button("btn1", "add 1") then
		counter = counter + 1
	end
	just.sameline()
	imgui.label("lbl1", "Count: " .. counter)

	sliderValue = imgui.slider1("sld1", sliderValue, "%s", 0, 1000, 10, "slider")
	cbValue = imgui.checkbox("cb1", cbValue, "checkbox")
	cmbValue = imgui.combo("cmb1", cmbValue, {"a", "b", "c"}, nil, "combo")
	listValue = imgui.list("list1", listValue, {"a", "b", "c", "d", "e"}, _h * 2, nil, "list - " .. listValue)
	hotkeyValue = imgui.hotkey("htk1", hotkeyValue, "hotkey")
	textValue = imgui.input("txt1", textValue, "text input")

	local scroll_w, scroll_step = 11, 32
	do
		just.text("Container")
		local cw, ch = 200, 200
		just.push()
		imgui.Container("cont1", cw, ch, scroll_w, scroll_step, scrollY)

		for i = 1, 20 do
			imgui.button("cont1-" .. i, "button " .. i)
		end

		scrollY = imgui.Container()
		just.pop()
		love.graphics.rectangle("line", 0, 0, cw, ch)
		just.next(cw, ch)
	end

	if imgui.button("openw", "open window") then
		windowOpened = not windowOpened
	end

	if windowOpened then
		love.graphics.translate(win_x, win_y)

		just.text("Window")
		local cw, ch = 700, 700
		just.push()
		love.graphics.setColor(0, 0, 0, 0.8)
		love.graphics.rectangle("fill", 0, 0, cw, ch)
		love.graphics.setColor(1, 1, 1, 1)

		imgui.setSize(cw, ch, cw / 2, _h)

		imgui.Container("cont2", cw, ch, scroll_w, scroll_step, scrollY2)

		just.text("drag to move")
		just.button("cont2", true)
		if just.active_id == "cont2" then
			win_x, win_y = win_x + dmx, win_y + dmy
		end

		hotkeyValue = imgui.hotkey("htk2", hotkeyValue, "hotkey")
		if just.keypressed("escape") then
			windowOpened = false
		end
		if imgui.button("cls2", "close") then
			windowOpened = false
		end
		just.sameline()
		imgui.label("lblcls", "or press escape")

		local kp_text = 'just.keypressed("q") == '
		local pressed = just.keypressed("q")
		imgui.checkbox("rcb1", pressed, kp_text .. tostring(pressed))

		imgui.List("c list1", 400, _h * 1.2, scroll_w, scroll_step, 0)
		do
			pressed = just.keypressed("q")
			imgui.checkbox("rcb2", pressed, kp_text .. tostring(pressed))
		end
		imgui.List()

		imgui.List("c list2", 400, 300, scroll_w, scroll_step, 0)
		do
			pressed = just.keypressed("q")
			imgui.checkbox("rcb3", pressed, kp_text .. tostring(pressed))
			imgui.List("c list3", 300, _h * 1.2, scroll_w, scroll_step, 0)
			do
				pressed = just.keypressed("q")
				imgui.checkbox("rcb33", pressed, kp_text .. tostring(pressed))
			end
			imgui.List()
			imgui.List("c list4", 300, _h * 1.2, scroll_w, scroll_step, 0)
			do
				pressed = just.keypressed("q")
				imgui.checkbox("rcb4", pressed, kp_text .. tostring(pressed))
			end
			imgui.List()
		end
		imgui.List()

		scrollY2 = imgui.Container()
		just.pop()
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.rectangle("line", 0, 0, cw, ch)
		just.next(cw, ch)
	end

	mx, my = _mx, _my
end

return ModalImView(draw)
