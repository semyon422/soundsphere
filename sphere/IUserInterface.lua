local class = require("class")

---@class sphere.IUserInterface
---@operator call: sphere.IUserInterface
local IUserInterface = class()

function IUserInterface:load() end
function IUserInterface:unload() end

---@param dt number
function IUserInterface:update(dt) end
function IUserInterface:draw() end

---@param event table
function IUserInterface:receive(event) end

return IUserInterface