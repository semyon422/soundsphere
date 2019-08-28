local Modifier = require("sphere.screen.gameplay.ModifierManager.Modifier")

local SequentialModifier = Modifier:new()

SequentialModifier.sequential = true

return SequentialModifier
