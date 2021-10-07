local NoteSkinVsrg = require("sphere.models.NoteSkinModel.NoteSkinVsrg")
local PlayfieldVsrg = require("sphere.models.NoteSkinModel.PlayfieldVsrg")

local BaseNoteSkin = NoteSkinVsrg:new()

BaseNoteSkin.bgaTransform = {{1 / 2, -16 / 9 / 2}, {0, -7 / 9 / 2}, 0, {0, 16 / 9}, {0, 16 / 9}, 0, 0, 0, 0}

BaseNoteSkin.columnWidth = 48
BaseNoteSkin.noteHeight = 24
BaseNoteSkin.judgementLineHeight = 6

BaseNoteSkin.setInputMode = function(self, inputMode, stringInputMode)
	self.inputMode = inputMode
	self.stringInputMode = stringInputMode
end

BaseNoteSkin.getInputTable = function(self)
	local inputMode = self.inputMode
	local inputs = {}

	for inputType, inputCount in pairs(inputMode.data) do
		inputs[#inputs + 1] = {inputType, inputCount}
	end

	table.sort(inputs, function(a, b)
		if a[2] ~= b[2] then
			return a[2] > b[2]
		else
			return a[1] < b [1]
		end
	end)

	local allInputs = {}
	for _, input in ipairs(inputs) do
		for i = 1, input[2] do
			table.insert(allInputs, input[1] .. i)
		end
	end
	return allInputs
end

BaseNoteSkin.load = function(self, content)
	self.name = self.stringInputMode .. " base skin"
	self.inputMode = self.inputMode
	self.range = {-1, 1}
	self.unit = 480
	self.hitposition = 440

	local inputs = self:getInputTable()
	self:setInput(inputs)

	local width = {}
	local space = {}
	local image = {}
	local keyImage = {}
	local guidelines = {
		y = {},
		w = {},
		h = {},
		image = {},
	}
	local oldInputType
	for i = 1, #inputs do
		width[i] = self.columnWidth
		space[i] = 0
		image[i] = "pixel"
		keyImage[i] = "pixel.png"

		local input = inputs[i]
		local inputType, inputIndex = input:match("^(.-)(%d+)$")
		if not oldInputType then
			oldInputType = inputType
		elseif oldInputType ~= inputType then
			oldInputType = inputType
			guidelines.w[i] = 1
		end
		guidelines.y[i] = 0
		guidelines.w[i] = guidelines.w[i] or 0
		guidelines.h[i] = self.unit
		guidelines.image[i] = "pixel.png"
	end
	space[#inputs + 1] = 0
	guidelines.y[#inputs + 1] = 0
	guidelines.w[#inputs + 1] = 0
	guidelines.h[#inputs + 1] = self.unit
	guidelines.image[#inputs + 1] = "pixel.png"

	self:setColumns({
		offset = 0,
		align = "center",
		width = width,
		space = space,
	})

	self:setTextures({{pixel = "pixel.png"}})
	self:setImages({pixel = {"pixel"}})
	self:setShortNote({
		image = image,
		h = self.noteHeight
	})
	self:setLongNote({
		head = image,
		tail = image,
		body = image,
		h = self.noteHeight
	})
	self:addMeasureLine({
		h = 4,
		color = {1, 1, 1, 0.5},
		image = "pixel"
	})

	self:addBga({
		x = 0,
		y = 0,
		w = 1,
		h = 1,
		color = {0.25, 0.25, 0.25, 1},
	})

	local playfield = PlayfieldVsrg:new({
		noteskin = self
	})

	playfield:addBga({transform = self.bgaTransform})
	playfield:enableCamera()
	playfield:addNotes()
	playfield:addLightings()
	playfield:addKeyImages({
		h = self.judgementLineHeight,
		padding = self.unit - self.hitposition - self.judgementLineHeight,
		pressed = keyImage,
		released = keyImage,
	})
	playfield:addGuidelines(guidelines)
	playfield:disableCamera()
end

return BaseNoteSkin
