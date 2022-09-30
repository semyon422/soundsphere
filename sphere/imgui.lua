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
local map = require("aqua.math").map

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

function imgui.label(id, label)
	just.indent(8)
	LabelImView(id .. "label", label, _h)
end

function imgui.button(id, text)
	local width = love.graphics.getFont():getWidth(text)
	return TextButtonImView2(id, text, width + _h, _h)
end

function imgui.slider(id, v, a, b, displayValue, label)
	local _v = map(v, a, b, 0, 1)
	_v = SliderImView(id, _v, _w, _h, displayValue) or _v
	just.sameline()
	just.indent(8)
	LabelImView(id .. "label", label, _h)
	return map(_v, 0, 1, a, b)
end

function imgui.checkbox(id, v, label)
	if CheckboxImView(id, v, _h) then
		v = not v
	end
	just.sameline()
	just.indent(8)
	LabelImView(id, label, _h)
	return v
end

function imgui.combo(id, v, values, format, label)
	local fv = format and format(v) or v
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
	just.indent(8)
	LabelImView(id .. "label", label, _h)
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
	just.indent(8)
	LabelImView(id .. "label", label, _h)
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
	just.indent(8)
	LabelImView(id .. "label", label, _h)
	just.row(false)
	return math.floor(v)
end

function imgui.intButtonsMs(id, v, label)
	return imgui.intButtons(id, v * 1000, 1, label) / 1000
end

function imgui.hotkey(id, key, label)
	local _
	_, key = HotkeyImView(id, "keyboard", key, _w, _h)
	just.sameline()
	just.indent(8)
	LabelImView(id .. "label", label, _h)
	return key
end

function imgui.input(id, text, label)
	local _
	_, text = TextInputImView(id, text, nil, _w, _h)
	just.sameline()
	LabelImView(id .. "label", label, _h)
	return text
end

return imgui
