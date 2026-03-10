local ImageAtlasPacker = require("yi.packer.ImageAtlasPacker")

local test = {}

local old_love = love

---@class yi.packer._FakeImageData
---@field width integer
---@field height integer
---@field format string?
---@field pastes table[]
local FakeImageData = {}
FakeImageData.__index = FakeImageData

---@param width integer
---@param height integer
---@param format string?
---@return yi.packer._FakeImageData
function FakeImageData:new(width, height, format)
	return setmetatable({
		width = width,
		height = height,
		format = format,
		pastes = {},
	}, self)
end

function FakeImageData:getDimensions()
	return self.width, self.height
end

function FakeImageData:getFormat()
	return self.format
end

function FakeImageData:paste(source, dx, dy, sx, sy, sw, sh)
	self.pastes[#self.pastes + 1] = {
		source = source,
		dx = dx,
		dy = dy,
		sx = sx,
		sy = sy,
		sw = sw,
		sh = sh,
	}
end

local function stubLove()
	love = {
		image = {
			newImageData = function(width, height, format)
				return FakeImageData:new(width, height, format)
			end,
		},
		graphics = {
			newQuad = function(x, y, w, h, tw, th)
				return {
					x = x,
					y = y,
					w = w,
					h = h,
					tw = tw,
					th = th,
				}
			end,
		},
	}
end

local function restoreLove()
	love = old_love
end

---@param t testing.T
function test.pack_builds_atlas_and_named_quads(t)
	stubLove()

	local packer = ImageAtlasPacker()
	local hero = FakeImageData:new(4, 4, "rgba8")
	local coin = FakeImageData:new(2, 3, "rgba8")
	local cursor = FakeImageData:new(3, 2, "rgba8")

	local atlas, quads = packer:pack({
		hero = hero,
		coin = coin,
		cursor = cursor,
	})

	restoreLove()

	t:eq(atlas.width, 4)
	t:eq(atlas.height, 11)
	t:eq(atlas.format, "rgba8")
	t:eq(#atlas.pastes, 3)

	t:eq(quads.hero.x, 0)
	t:eq(quads.hero.y, 0)
	t:eq(quads.hero.w, 4)
	t:eq(quads.hero.h, 4)
	t:eq(quads.hero.tw, 4)
	t:eq(quads.hero.th, 11)

	t:eq(quads.coin.x, 0)
	t:eq(quads.coin.y, 5)
	t:eq(quads.coin.w, 2)
	t:eq(quads.coin.h, 3)

	t:eq(quads.cursor.x, 0)
	t:eq(quads.cursor.y, 9)
	t:eq(quads.cursor.w, 3)
	t:eq(quads.cursor.h, 2)
end

---@param t testing.T
function test.pack_returns_minimal_empty_atlas_for_empty_input(t)
	stubLove()

	local packer = ImageAtlasPacker()
	local atlas, quads = packer:pack({})

	restoreLove()

	t:eq(atlas.width, 1)
	t:eq(atlas.height, 1)
	t:eq(#atlas.pastes, 0)
	t:eq(next(quads), nil)
end

---@param t testing.T
function test.pack_rejects_mixed_formats(t)
	stubLove()

	local packer = ImageAtlasPacker()
	local ok, err = pcall(function()
		packer:pack({
			a = FakeImageData:new(4, 4, "rgba8"),
			b = FakeImageData:new(2, 2, "r8"),
		})
	end)

	restoreLove()

	t:assert(not ok)
	t:assert(tostring(err):match("same ImageData format"))
end

return test
