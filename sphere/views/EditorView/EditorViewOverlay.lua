local just = require("just")
local spherefonts = require("sphere.assets.fonts")
local imgui = require("imgui")
local Fraction = require("ncdk.Fraction")
local gfx_util = require("gfx_util")

local Layout = require("sphere.views.EditorView.Layout")

local tabs = {}

local function to_ms(t)
	return math.floor(t * 1000) .. "ms"
end

function tabs.info(self)
	local md = self.game.noteChartModel.noteChart.metaData

	imgui.setSize(400, 1080, 400, 55)
	imgui.text("Chart info")
	md.title = imgui.input("title input", md.title, "title")
	md.artist = imgui.input("artist input", md.artist, "artist")
	md.source = imgui.input("source input", md.source, "source")
	md.tags = imgui.input("tags input", md.tags, "tags")
	md.name = imgui.input("name input", md.name, "name")
	md.creator = imgui.input("creator input", md.creator, "creator")
	md.level = imgui.input("level input", md.level, "level")
	md.audioPath = imgui.input("audioPath input", md.audioPath, "audioPath")
	md.stagePath = imgui.input("stagePath input", md.stagePath, "stagePath")
	md.previewTime = imgui.input("previewTime input", md.previewTime, "previewTime")
	md.bpm = imgui.input("bpm input", md.bpm, "bpm")
	md.inputMode = imgui.input("inputMode input", md.inputMode, "inputMode")

	imgui.separator()

	if imgui.button("save btn", "save") then
		self.game.editorController:save()
	end
	just.sameline()
	if imgui.button("save to osu btn", "save to osu") then
		self.game.editorController:saveToOsu()
	end

	love.graphics.push("all")
	love.graphics.setColor(1, 1, 1, 0.75)
	love.graphics.setFont(spherefonts.get("Noto Sans", 36))
	imgui.text("The editor")
	imgui.text("is in development")
	love.graphics.pop()
end

function tabs.audio(self)
	local editorModel = self.game.editorModel

	local playing = 0
	for _ in pairs(self.game.editorModel.audioManager.sources) do
		playing = playing + 1
	end
	imgui.text("playing sounds: " .. playing)
	imgui.text("offsync: " .. to_ms(editorModel.timer:getAudioOffsync() or 0))

	local settings = self.game.configModel.configs.settings
	local a = settings.audio
	local v = a.volume
	v.master = imgui.slider1("v.master", v.master, "%0.2f", 0, 1, 0.01, "master volume")
	v.music = imgui.slider1("v.music", v.music, "%0.2f", 0, 1, 0.01, "music volume")
	v.effects = imgui.slider1("v.effects", v.effects, "%0.2f", 0, 1, 0.01, "effects volume")
	v.metronome = imgui.slider1("v.metronome", v.metronome, "%0.2f", 0, 1, 0.01, "metronome volume")

	imgui.separator()
	local mode = a.mode
	imgui.text("audio modes")
	imgui.text("primary: " .. mode.primary)
	imgui.text("secondary: " .. mode.secondary)

	imgui.separator()
	imgui.text("waveform")
	local wf = self.game.configModel.configs.settings.editor.waveform
	wf.opacity = imgui.slider1("wf.opacity", wf.opacity, "%0.2f", 0, 1, 0.01, "opacity")
	wf.scale = imgui.slider1("wf.scale", wf.scale, "%0.2f", 0, 1, 0.01, "scale")

	imgui.separator()
	local md = self.game.noteChartModel.noteChart.metaData
	if imgui.button("set as preview", "set this moment as a preview") then
		md.previewTime = editorModel.timePoint.absoluteTime
	end
end

local velocity = "1"
local expand = {"0", "1"}

function tabs.timings(self)
	local editorModel = self.game.editorModel
	local editor = self.game.configModel.configs.settings.editor
	local ld = editorModel.layerData

	local dtp = editorModel.timePoint

	if imgui.button("prev tp", "<") and dtp.prev then
		editorModel.scroller:scrollTimePoint(dtp.prev)
	end
	just.sameline()
	if imgui.button("next tp", ">") and dtp.next then
		editorModel.scroller:scrollTimePoint(dtp.next)
	end
	just.sameline()
	imgui.label("dtp label", tostring(dtp))

	editor.showTimings = imgui.checkbox("show timings", editor.showTimings, "show timings")

	if imgui.button("ncbt", "detect tempo and offset") then
		editorModel:detectTempoOffset()
	end
	if editorModel.ncbtContext.tempo then
		just.sameline()
		if imgui.button("ncbt apply", "apply") then
			editorModel:applyTempoOffset()
		end
	end

	local intervalData = dtp._intervalData
	local intervalManager = editorModel.intervalManager
	if not intervalManager:isGrabbed() then
		if not intervalData then
			if imgui.button("split button", "split") then
				intervalManager:split(dtp)
			end
		elseif imgui.button("grab interval button", "grab") then
			intervalManager:grab(intervalData)
		end
	else
		if imgui.button("drop interval button", "drop") then
			intervalManager:drop()
		end
	end
	if intervalData and not intervalManager:isGrabbed() then
		just.sameline()
		if imgui.button("merge interval button", "merge") then
			intervalManager:merge(intervalData.timePoint)
			editorModel.scroller:scrollSecondsDelta(0)
		end
		local beats = intervalData.beats
		local newBeats = imgui.intButtons("update interval", beats, 1, "beats")
		if beats ~= newBeats then
			intervalManager:update(intervalData, newBeats)
		end
		imgui.text("Tempo: " .. intervalData:getTempo() .. " bpm")
	end

	imgui.separator()

	local totalBeats, avgBeatDuration = editorModel:getTotalBeats()
	imgui.text("Total beats: " .. totalBeats .. "")
	imgui.text("Average tempo: " .. 60 / avgBeatDuration .. " bpm")

	imgui.separator()

	do return end

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
end

local qwerty = "qwerty"
function tabs.notes(self)
	local editorModel = self.game.editorModel
	local editor = self.game.configModel.configs.settings.editor

	local logSpeed = imgui.slider1("editor speed", editorModel:getLogSpeed(), "%d", -30, 50, 1, "speed")
	if logSpeed ~= editorModel:getLogSpeed() then
		editorModel:setLogSpeed(logSpeed)
		editorModel.scroller:updateRange()
	end
	editor.snap = imgui.slider1("snap select", editor.snap, "%d", 1, 16, 1, "snap")
	editor.lockSnap = imgui.checkbox("lock snap", editor.lockSnap, "lock snap")
	editor.tool = imgui.combo("tool select", editor.tool, editorModel.tools, nil, "tool")
	imgui.text("Use qwer to select tool")

	for i = 1, #editorModel.tools do
		if just.keypressed(qwerty:sub(i, i)) then
			editor.tool = editorModel.tools[i]
		end
	end
end

return function(self)
	local editorModel = self.game.editorModel
	local w, h = Layout:move("base")

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setFont(spherefonts.get("Noto Sans", 24))
	love.graphics.setLineStyle("smooth")

	local lineHeight = 55
	imgui.setSize(400, h, 200, lineHeight)
	love.graphics.setColor(1, 1, 1, 1)

	editorModel.state = imgui.tabs("editor overlay tabs", editorModel.state, editorModel.states)
	love.graphics.setColor(1, 1, 1, 1)
	imgui.setSize(400, h, 200, lineHeight)
	tabs[editorModel.state](self)

	if not editorModel.resourcesLoaded then
		w, h = Layout:move("base")
		love.graphics.setColor(1, 1, 1, 0.5)
		love.graphics.setFont(spherefonts.get("Noto Sans", 160))
		gfx_util.printFrame("loading", 0, 0, w, h, "center", "center")
	end
end
