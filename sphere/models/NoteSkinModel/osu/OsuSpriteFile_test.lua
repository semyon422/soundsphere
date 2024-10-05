local OsuSpriteFile = require("sphere.models.NoteSkinModel.osu.OsuSpriteFile")

local test = {}

---@param t testing.T
function test.parse_tostring(t)
	local paths = {
		"q-1@2x.png",

		"q-1@2x.",
		"q-1@2xpng",
		"q-1@2x",

		"q-1@x.png",
		"q-@2x.png",
		"q1@2x.png",
	}

	for _, path in ipairs(paths) do
		t:eq(tostring(OsuSpriteFile(path)), path)
	end
end

return test
