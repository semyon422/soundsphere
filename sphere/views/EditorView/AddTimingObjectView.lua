local imgui = require("imgui")
local spherefonts = require("sphere.assets.fonts")
local _transform = require("gfx_util").transform
local just = require("just")
local Fraction = require("ncdk.Fraction")
local ModalImView = require("sphere.imviews.ModalImView")

local transform = {{1 / 2, -16 / 9 / 2}, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}

local scrollY = 0
local w, h = 512, 1080 / 2
local _w, _h = w / 2, 55
local r = 8
local window_id = "AddTimingObjectView"

local tempo = "60"
local stop = {"0", "1"}
local velocity = "1"
local expand = {"0", "1"}
return ModalImView(function(self)
	if not self then
		return true
	end

	local editorModel = self.game.editorModel
	local ld = editorModel.layerData

	love.graphics.setFont(spherefonts.get("Noto Sans", 24))

	love.graphics.replaceTransform(_transform(transform))
	love.graphics.translate((1920 - w) / 2, (1080 - h) / 2)

	love.graphics.setColor(0, 0, 0, 0.8)
	love.graphics.rectangle("fill", 0, 0, w, h, r)
	love.graphics.setColor(1, 1, 1, 1)

	just.push()
	imgui.Container(window_id, w, h, _h / 3, _h * 2, scrollY)

	local dtp = editorModel:getDynamicTimePoint()

	imgui.setSize(w, h, 110, 55)

	just.row(true)
	tempo = imgui.input("tempo input", tempo, "tempo")
	if imgui.button("add tempo button", "add") then
		ld:getTempoData(dtp.measureTime, tonumber(tempo))
	end

	just.row(true)
	stop[1] = imgui.input("stop n input", stop[1])
	imgui.unindent()
	imgui.label("/ label", "/")
	stop[2] = imgui.input("stop d input", stop[2], "stop")
	if imgui.button("add stop button", "add") then
		ld:getStopData(dtp.measureTime, Fraction(tonumber(stop[1]), tonumber(stop[2])))
	end

	just.row(true)
	velocity = imgui.input("velocity input", velocity, "velocity")
	if imgui.button("add velocity button", "add") then
		ld:getVelocityData(dtp.measureTime, dtp.side, tonumber(velocity))
	end

	just.row(true)
	expand[1] = imgui.input("expand n input", expand[1])
	imgui.unindent()
	imgui.label("/ label", "/")
	expand[2] = imgui.input("expand d input", expand[2], "expand")
	if imgui.button("add expand button", "add") then
		ld:getExpandData(dtp.measureTime, dtp.side, Fraction(tonumber(expand[1]), tonumber(expand[2])))
	end

	just.row()
	imgui.setSize(w, h, w / 2, 55)

	if dtp._tempoData then
		imgui.label("tempo label", "Tempo: " .. dtp._tempoData.tempo .. " bpm")
		just.sameline()
		if imgui.button("remove tempo button", "remove") then
			ld:removeTempoData(dtp.measureTime)
		end
	end
	if dtp._stopData then
		imgui.label("stop label", "Stop: " .. dtp._stopData.duration .. " beats")
		just.sameline()
		if imgui.button("remove stop button", "remove") then
			ld:removeStopData(dtp.measureTime)
		end
	end
	if dtp._velocityData then
		imgui.label("velocity label", "Velocity: " .. dtp._velocityData.currentSpeed .. " x")
		just.sameline()
		if imgui.button("remove velocity button", "remove") then
			ld:removeVelocityData(dtp.measureTime, dtp.side)
		end
	end
	if dtp._expandData then
		imgui.label("expand label", "Expand: " .. dtp._expandData.duration .. " beats")
		just.sameline()
		if imgui.button("remove expand button", "remove") then
			ld:removeExpandData(dtp.measureTime, dtp.side)
		end
	end

	scrollY = imgui.Container()
	just.pop()

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle("line", 0, 0, w, h, r)
end)
