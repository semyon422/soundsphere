local ValueView = require("sphere.views.ValueView")

local inspect = require("inspect")
local aquaevent = require("aqua.event")

local transform = {{1 / 2, -16 / 9 / 2}, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}
local transformLeft = {0, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}
local transformRight = {{1, 0}, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}

local Fps = ValueView:new({
	subscreen = "debug",
	transform = transformLeft,
	value = function()
		return ("FPS:  %d\n1/dt: %0.2f"):format(love.timer.getFPS(), 1 / love.timer.getDelta())
	end,
	x = 0,
	baseline = 30,
	limit = 1920,
	color = {1, 1, 1, 1},
	font = {"Noto Sans Mono", 24},
	align = "left",
})

local RendererInfo = ValueView:new({
	subscreen = "debug",
	transform = transformRight,
	value = function()
		return ("%s\n%s\n%s\n%s"):format(love.graphics.getRendererInfo())
	end,
	x = -1920,
	baseline = 30,
	limit = 1920,
	color = {1, 1, 1, 1},
	font = {"Noto Sans Mono", 24},
	align = "right",
})

local Stats = ValueView:new({
	subscreen = "debug",
	transform = transformLeft,
	value = function()
		return inspect(aquaevent.stats)
	end,
	x = 0,
	baseline = 160,
	limit = 1920,
	color = {1, 1, 1, 1},
	font = {"Noto Sans Mono", 24},
	align = "left",
})

local Version = ValueView:new({
	subscreen = "debug",
	transform = transformLeft,
	value = function()
		local version = require("version")
		return version.date .. "\n" .. version.commit
	end,
	x = 0,
	baseline = 1040,
	limit = 1920,
	color = {1, 1, 1, 1},
	font = {"Noto Sans Mono", 24},
	align = "left",
})

return {
	Fps,
	RendererInfo,
	Stats,
	Version,
}
