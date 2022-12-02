local just = require("just")
local LabelImView = require("sphere.imviews.LabelImView")
local TextButtonImView = require("sphere.imviews.TextButtonImView")
local TextButtonImView2 = require("sphere.imviews.TextButtonImView2")
local TextInputImView = require("sphere.imviews.TextInputImView")
local SpoilerImView = require("sphere.imviews.SpoilerImView")
local SliderImView = require("sphere.imviews.SliderImView")
local CheckboxImView = require("sphere.imviews.CheckboxImView")
local HotkeyImView = require("sphere.imviews.HotkeyImView")
local ContainerImView = require("sphere.imviews.ContainerImView")
local ListImView = require("sphere.imviews.ListImView")
local math_util = require("math_util")

local imgui = {}

local w, h, _w, _h
function imgui.setSize(...)
	w, h, _w, _h = ...
end

function imgui.separator()
	just.emptyline(8)
	love.graphics.line(0, 0, w, 0)
	just.emptyline(8)
end

function imgui.indent(size)
	just.indent(size or 8)
end

function imgui.unindent(size)
	just.indent(-(size or 8))
end

function imgui.label(id, label)
	if not label then
		just.next()
		return
	end
	imgui.indent()
	LabelImView(id, label, _h)
end

function imgui.text(text)
	imgui.indent()
	just.text(text)
end

function imgui.button(id, text)
	local width = love.graphics.getFont():getWidth(text)
	return TextButtonImView2(id, text, width + _h, _h)
end

function imgui.slider(id, v, a, b, displayValue, label)
	local _v = math_util.map(v, a, b, 0, 1)
	_v = SliderImView(id, _v, _w, _h, displayValue) or _v
	just.sameline()
	imgui.label(id .. "label", label)
	return math_util.map(_v, 0, 1, a, b)
end

function imgui.slider1(id, v, format, a, b, c, label)
	local delta = just.wheel_over(id, just.is_over(_w, _h))
	if delta then
		v = math.min(math.max(v + c * delta, a), b)
	end

	local _v = math_util.map(v, a, b, 0, 1)
	_v = SliderImView(id, _v, _w, _h, format:format(v)) or _v
	just.sameline()
	imgui.label(id .. "label", label)

	v = math_util.map(_v, 0, 1, a, b)
	v = math_util.round(v, c)

	return v
end

function imgui.checkbox(id, v, label)
	local isNumber = type(v) == "number"
	if isNumber then
		v = v == 1
	end
	if CheckboxImView(id, v, _h) then
		v = not v
	end
	just.sameline()
	imgui.label(id, label)
	if isNumber then
		v = v and 1 or 0
	end
	return v
end

function imgui.combo(id, v, values, format, label)
	local fv = v
	if type(format) == "function" then
		fv = format(v)
	elseif type(format) == "string" then
		fv = format:format(v)
	end
	if SpoilerImView(id, _w, _h, fv) then
		for i, _v in ipairs(values) do
			local dv = format and format(_v) or _v
			if TextButtonImView(id .. i, dv, _w - _h * 0.25, _h * 0.75) then
				v = _v
				just.focus()
			end
		end
		SpoilerImView()
	end
	just.sameline()
	imgui.label(id .. "label", label)
	return v
end

local scrolls = {}
function imgui.list(id, v, values, height, format, label)
	scrolls[id] = scrolls[id] or 0
	ListImView(id, _w, height, _h, scrolls[id])
	for i, _v in ipairs(values) do
		local dv = format and format(_v) or _v
		if TextButtonImView(id .. i, dv, _w - _h * 0.25, _h * 0.75) then
			v = _v
		end
	end
	scrolls[id] = ListImView()
	just.sameline()
	imgui.label(id .. "label", label)
	return v
end

function imgui.intButtons(id, v, s, label)
	just.row(true)
	local bw = _w / (s + 2)
	local button = TextButtonImView2(nil, v, bw, _h)
	for i = 0, s do
		local d = 10 ^ i
		button = TextButtonImView2(id .. d, "±" .. d, bw, _h)
		if button then
			v = v + (button == 1 and 1 or -1) * d
		end
	end
	imgui.label(id .. "label", label)
	just.row()
	return math.floor(v)
end

function imgui.intButtonsMs(id, v, label)
	return imgui.intButtons(id, v * 1000, 1, label) / 1000
end

function imgui.hotkey(id, key, label)
	local _
	_, key = HotkeyImView(id, "keyboard", key, _w, _h)
	just.sameline()
	imgui.label(id .. "label", label)
	return key
end

function imgui.input(id, text, label)
	local _
	_, text = TextInputImView(id, text, nil, _w, _h)
	just.sameline()
	imgui.label(id .. "label", label)
	return text
end

return imgui
