local just = require("just")
local spherefonts = require("sphere.assets.fonts")
local imgui = require("imgui")
local Fraction = require("ncdk.Fraction")

local Layout = require("sphere.views.EditorView.Layout")

local tabsList = {
	"info",
	"timings",
	"notes",
}
local currentTab = tabsList[1]

local tabs = {}

function tabs.info(self)
	local playing = 0
	for _ in pairs(self.game.editorModel.audioManager.sources) do
		playing = playing + 1
	end
	imgui.text("playing sounds: " .. playing)

	if imgui.button("save btn", "save") then
		self.game.editorController:save()
	end
end

local tempo = "60"
local stop = {"0", "1"}
local velocity = "1"
local expand = {"0", "1"}
local signature = {"0", "1"}

local primaryTempo = "60"
local defaultSignature = {"4", "1"}

function tabs.timings(self)
	local editorModel = self.game.editorModel
	local ld = editorModel.layerData

	local dtp = editorModel:getDynamicTimePoint()

	imgui.text(tostring(dtp))
	imgui.text("at: " .. dtp.absoluteTime)
	imgui.text("vt: " .. dtp.visualTime)
	imgui.text("vs: " .. dtp.visualSide)

	if imgui.button("prev tp", "<") and dtp.prev then
		editorModel:scrollTimePoint(dtp.prev)
	end
	just.sameline()
	if imgui.button("next tp", ">") and dtp.next then
		editorModel:scrollTimePoint(dtp.next)
	end

	local intervalData = dtp._intervalData
	local grabbedIntervalData = editorModel.grabbedIntervalData
	if not grabbedIntervalData then
		if not intervalData and imgui.button("split interval button", "split interval") then
			ld:splitInterval(dtp)
		end
		if intervalData then
			if imgui.button("merge interval button", "merge") then
				ld:mergeInterval(dtp)
			end
			local inc = imgui.intButtons("update interval", nil, 1)
			if inc ~= 0 then
				ld:updateInterval(intervalData, intervalData.beats + inc)
			end
		end
		if intervalData and imgui.button("grab interval button", "grab") then
			editorModel:grabIntervalData(intervalData)
		end
	else
		if imgui.button("drop interval button", "drop") then
			editorModel:dropIntervalData()
		end
	end

	if ld.mode == "measure" then
		just.row(true)
		primaryTempo = imgui.input("primaryTempo input", primaryTempo, "primary tempo")
		if imgui.button("set primaryTempo button", "set") then
			ld:setPrimaryTempo(tonumber(primaryTempo))
		end
		if imgui.button("unset primaryTempo button", "unset") then
			ld:setPrimaryTempo(0)
		end
		just.row()

		just.row(true)
		imgui.label("set signature mode", "signature mode")
		if imgui.button("set short signature button", "short") then
			ld:setSignatureMode("short")
		end
		if imgui.button("set long signature button", "long") then
			ld:setSignatureMode("long")
		end
		just.row()

		just.row(true)
		defaultSignature[1] = imgui.input("defsig n input", defaultSignature[1])
		imgui.unindent()
		imgui.label("/ label", "/")
		defaultSignature[2] = imgui.input("defsig d input", defaultSignature[2], "default signature")
		if imgui.button("set defsig button", "set") then
			ld:setDefaultSignature(Fraction(tonumber(defaultSignature[1]), tonumber(defaultSignature[2])))
		end
		just.row(false)

		just.text("primary tempo: " .. ld.primaryTempo)
		just.text("signature mode: " .. ld.signatureMode)
		just.text("default signature: " .. ld.defaultSignature)

		local measureOffset = dtp.measureTime:floor()
		local _signature = ld:getSignature(measureOffset)
		local snap = editorModel.snap

		local beatTime = (dtp.measureTime - measureOffset) * _signature
		local snapTime = (beatTime - beatTime:floor()) * snap

		just.text("beat: " .. tostring(beatTime))
		just.text("snap: " .. tostring(snapTime))

		just.row(true)
		tempo = imgui.input("tempo input", tempo, "tempo")
		if imgui.button("add tempo button", "add") then
			ld:getTempoData(dtp:getTime(), tonumber(tempo))
		end

		imgui.separator()

		just.row(true)
		stop[1] = imgui.input("stop n input", stop[1])
		imgui.unindent()
		imgui.label("/ label", "/")
		stop[2] = imgui.input("stop d input", stop[2], "stop")
		if imgui.button("add stop button", "add") then
			ld:getStopData(dtp:getTime(), Fraction(tonumber(stop[1]), tonumber(stop[2])))
		end

		just.row(true)
		signature[1] = imgui.input("signature n input", signature[1])
		imgui.unindent()
		imgui.label("/ label", "/")
		signature[2] = imgui.input("signature d input", signature[2], "signature")
		if imgui.button("add signature button", "add") then
			ld:getSignatureData(dtp.measureTime:floor(), Fraction(tonumber(signature[1]), tonumber(signature[2])))
		end
	end

	imgui.separator()

	just.row(true)
	velocity = imgui.input("velocity input", velocity, "velocity")
	if imgui.button("add velocity button", "add") then
		ld:getVelocityData(dtp, tonumber(velocity))
	end

	just.row(true)
	expand[1] = imgui.input("expand n input", expand[1])
	imgui.unindent()
	imgui.label("/ label", "/")
	expand[2] = imgui.input("expand d input", expand[2], "expand")
	if imgui.button("add expand button", "add") then
		ld:getExpandData(dtp, Fraction(tonumber(expand[1]), tonumber(expand[2])))
	end

	just.row()

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
			ld:removeVelocityData(dtp)
		end
	end
	if dtp._expandData then
		imgui.label("expand label", "Expand: " .. dtp._expandData.duration .. " beats")
		just.sameline()
		if imgui.button("remove expand button", "remove") then
			ld:removeExpandData(dtp)
		end
	end

	if dtp._signatureData then
		imgui.label("signature label", "Signature: " .. dtp._signatureData.signature .. " beats")
		just.sameline()
		if imgui.button("remove signature button", "remove") then
			ld:removeSignatureData(dtp.measureTime:floor())
		end
	end
end

function tabs.notes(self)
	local editorModel = self.game.editorModel

	local logSpeed = imgui.slider1("editor speed", editorModel:getLogSpeed(), "%d", -30, 50, 1, "speed")
	if logSpeed ~= editorModel:getLogSpeed() then
		editorModel:setLogSpeed(logSpeed)
		editorModel:updateRange()
	end
	editorModel.snap = imgui.slider1("snap select", editorModel.snap, "%d", 1, 16, 1, "snap")
	editorModel.lockSnap = imgui.checkbox("lock snap", editorModel.lockSnap, "lock snap")

	editorModel.tool = imgui.list("tool select", editorModel.tool, editorModel.tools, 200, nil, "tool")
end

return function(self)
	local w, h = Layout:move("base")

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setFont(spherefonts.get("Noto Sans", 24))
	love.graphics.setLineStyle("smooth")

	local lineHeight = 55
	imgui.setSize(400, h, 200, lineHeight)
	love.graphics.setColor(1, 1, 1, 1)

	currentTab = imgui.tabs("editor overlay tabs", currentTab, tabsList)
	love.graphics.setColor(1, 1, 1, 1)
	tabs[currentTab](self)
end
