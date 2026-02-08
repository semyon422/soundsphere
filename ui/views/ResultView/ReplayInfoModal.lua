local just = require("just")
local imgui = require("imgui")
local ModalImView = require("ui.imviews.ModalImView")
local _transform = require("gfx_util").transform
local spherefonts = require("sphere.assets.fonts")
local stbl = require("stbl")

local transform = {{1 / 2, -16 / 9 / 2}, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}

local scrollY = 0

local w, h = 792, 792
local _w, _h = w / 2, 55
local r = 8
local window_id = "ReplayInfoModal"

return ModalImView(function(self, quit)
	---@type sphere.GameController
	local game = self.game

	if quit then
		return true
	end

	imgui.setSize(w, h, _w, _h)

	love.graphics.setFont(spherefonts.get("Noto Sans", 20))

	love.graphics.replaceTransform(_transform(transform))
	love.graphics.translate((1920 - w) / 2, (1080 - h) / 2)

	love.graphics.setColor(0, 0, 0, 0.8)
	love.graphics.rectangle("fill", 0, 0, w, h, r)
	love.graphics.setColor(1, 1, 1, 1)

	just.push()

	imgui.Container(window_id, w, h, _h / 3, _h * 2, scrollY)

	local replay = game.resultController.replay
	if replay then
		imgui.text("hash: " .. tostring(replay.hash))
		imgui.text("index: " .. tostring(replay.index))
		imgui.text("modifiers: " .. stbl.encode(replay.modifiers))
		imgui.text("rate: " .. tostring(replay.rate))
		imgui.text("mode: " .. tostring(replay.mode))
		imgui.separator()
		imgui.text("version: " .. tostring(replay.version))
		imgui.text("#events: " .. #tostring(replay.events))
		imgui.text("pause_count: " .. tostring(replay.pause_count))
		imgui.text("created_at: " .. tostring(replay.created_at) .. " " .. os.date("%c", replay.created_at))
		imgui.separator()
		imgui.text("nearest: " .. tostring(replay.nearest))
		imgui.text("tap_only: " .. tostring(replay.tap_only))
		imgui.text("timings: " .. tostring(replay.timings))
		imgui.text("subtimings: " .. tostring(replay.subtimings))
		imgui.text("healths: " .. tostring(replay.healths))
		imgui.text("columns_order: " .. stbl.encode(replay.columns_order))
		imgui.separator()
		imgui.text("custom: " .. tostring(replay.custom))
		imgui.text("const: " .. tostring(replay.const))
		imgui.text("rate_type: " .. tostring(replay.rate_type))
		imgui.separator()
		imgui.text("timings_values: " .. stbl.encode(replay.timing_values))
	end

	scrollY = imgui.Container()
	just.pop()

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle("line", 0, 0, w, h, r)
end)
