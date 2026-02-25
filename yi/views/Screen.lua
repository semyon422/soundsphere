local View = require("yi.views.View")

---@class yi.Screen : yi.View
---@overload fun(): yi.Screen
---@field parent yi.Screens
local Screen = View + {}

function Screen:enter() end
function Screen:exit() end

---@param event table
function Screen:receive(event) end

return Screen
