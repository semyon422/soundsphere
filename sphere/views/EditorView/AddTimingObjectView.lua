local ModalImView = require("sphere.imviews.ModalImView")
local ContainerImView = require("sphere.imviews.ContainerImView")
local TextButtonImView = require("sphere.imviews.TextButtonImView")
local imgui = require("sphere.imgui")
local spherefonts = require("sphere.assets.fonts")
local _transform = require("gfx_util").transform
local just = require("just")

local transform = {{1 / 2, -16 / 9 / 2}, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}

local scrollY = 0
local w, h = 400, 1080 / 2
local _w, _h = w / 2, 55
local r = 8
local window_id = "AddTimingObjectView"

local tempo = 60
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
	ContainerImView(window_id, w, h, _h * 2, scrollY)

	local dtp = editorModel:getDynamicTimePoint()

	tempo = imgui.slider1("add tempo slider", tempo, "%d bpm", 10, 1000, 10, "tempo")
	if imgui.button("add tempo button", "add tempo") then
		ld:getTempoData(dtp.measureTime, tempo)
	end

	if dtp._tempoData then
		just.text("Tempo: " .. dtp._tempoData.tempo)
		if imgui.button("remove tempo button", "remove tempo") then
			ld:removeTempoData(dtp.measureTime)
		end
	end

	scrollY = ContainerImView()
	just.pop()

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle("line", 0, 0, w, h, r)
end)
