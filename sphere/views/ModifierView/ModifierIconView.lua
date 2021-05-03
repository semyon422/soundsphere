local Class = require("aqua.util.Class")
local CoordinateManager = require("aqua.graphics.CoordinateManager")
local aquafonts			= require("aqua.assets.fonts")
local spherefonts		= require("sphere.assets.fonts")

local ModifierIconView = Class:new()

ModifierIconView.construct = function(self)
    self.cs = CoordinateManager:getCS(0.5, 0, 16 / 9 / 2, 0, "h")
end

ModifierIconView.draw = function(self)
    local config = self.config
    local screen = config.screen
    local cs = self.cs

    love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setLineStyle("smooth")
	love.graphics.setLineWidth(cs:X(config.size / 40 / screen.h))

	local fx = config.x + config.size / 8
	local fy = config.y + config.size / 8
	local fs = config.size * 3 / 4
	local fr = fs / 4
    -- love.graphics.rectangle(
    --     "line",
    --     cs:X(fx / screen.h, true),
    --     cs:Y(fy / screen.h, true),
    --     cs:X(fs / screen.h),
    --     cs:Y(fs / screen.h),
    --     cs:X(fr / screen.h),
    --     cs:Y(fr / screen.h)
    -- )
    love.graphics.arc(
        "line",
		"open",
        cs:X((fx + fr) / screen.h, true),
        cs:Y((fy + fr) / screen.h, true),
        cs:X(fr / screen.h),
		-math.pi,
		-math.pi / 2
    )
    love.graphics.line(
        cs:X((fx + fr) / screen.h, true),
        cs:Y(fy / screen.h, true),
        cs:X((fx + fs - fr) / screen.h, true),
        cs:Y(fy / screen.h, true)
    )
    love.graphics.arc(
        "line",
		"open",
        cs:X((fx + fs - fr) / screen.h, true),
        cs:Y((fy + fr) / screen.h, true),
        cs:X(fr / screen.h),
		-math.pi / 2,
		0
    )
    love.graphics.arc(
        "line",
		"open",
        cs:X((fx + fr) / screen.h, true),
        cs:Y((fy + fs - fr) / screen.h, true),
        cs:X(fr / screen.h),
		math.pi,
		math.pi / 2
    )
    love.graphics.line(
        cs:X((fx + fr) / screen.h, true),
        cs:Y((fy + fs) / screen.h, true),
        cs:X((fx + fs - fr) / screen.h, true),
        cs:Y((fy + fs) / screen.h, true)
    )
    love.graphics.arc(
        "line",
		"open",
        cs:X((fx + fs - fr) / screen.h, true),
        cs:Y((fy + fs -  fr) / screen.h, true),
        cs:X(fr / screen.h),
		math.pi / 2,
		0
    )

    love.graphics.setColor(1, 1, 1, 1)

	local font = aquafonts.getFont(spherefonts.NotoMonoRegular, 28)
	love.graphics.setFont(font)
	love.graphics.printf(
		"MOD",
		cs:X(fx / screen.h, true),
		cs:Y((fy + 10 * fs / 52) / screen.h, true),
		52,
		"center",
		0,
		cs.one / screen.h * fs / 52,
		cs.one / screen.h * fs / 52
	)
end

return ModifierIconView
