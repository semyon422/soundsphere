local viewspackage = (...):match("^(.-%.views%.)")

local Navigator = require(viewspackage .. "Navigator")
local Node = require("aqua.util.Node")

local NoteSkinNavigator = Navigator:new()

NoteSkinNavigator.construct = function(self)
	Navigator.construct(self)

	local noteSkinList = Node:new()
	self.noteSkinList = noteSkinList
	noteSkinList.selected = 1
end

NoteSkinNavigator.scrollNoteSkin = function(self, direction, destination)
	local noteSkinList = self.noteSkinList

    local noteChart = self.view.noteChartModel.noteChart
	local noteSkins = self.view.noteSkinModel:getNoteSkins(noteChart.inputMode)

	direction = direction or destination - noteSkinList.selected
	if not noteSkins[noteSkinList.selected + direction] then
		return
	end

	noteSkinList.selected = noteSkinList.selected + direction
end

NoteSkinNavigator.fixScrollModifier = function(self)
	-- local modifierList = self.modifierList

	-- local modifiers = self.config

	-- if not modifiers[modifierList.selected] then
	-- 	modifierList.selected = #modifiers
	-- end
end

NoteSkinNavigator.load = function(self)
    Navigator.load(self)

	local noteSkinList = self.noteSkinList

	self.node = noteSkinList
	noteSkinList:on("up", function()
		self:scrollNoteSkin(-1)
	end)
	noteSkinList:on("down", function()
		self:scrollNoteSkin(1)
	end)
	noteSkinList:on("return", function(_, itemIndex)
        local noteChart = self.view.noteChartModel.noteChart
        local noteSkins = self.view.noteSkinModel:getNoteSkins(noteChart.inputMode)
        self:send({
            name = "setNoteSkin",
            noteSkin = noteSkins[itemIndex or noteSkinList.selected]
        })
		self:send({
			name = "goSelectScreen"
		})
    end)
	noteSkinList:on("escape", function()
		self:send({
			name = "goSelectScreen"
		})
	end)
end

NoteSkinNavigator.receive = function(self, event)
	if event.name == "keypressed" then
		self:call(event.args[1])
	end
end

return NoteSkinNavigator
