local class = require("class")

---@class sphere.IUserInterface
---@operator call: sphere.IUserInterface
---@field previewModel sphere.PreviewModel
---@field backgroundModel sphere.BackgroundModel
---@field chartPreviewModel sphere.ChartPreviewModel
---@field notificationModel sphere.NotificationModel
local IUserInterface = class()

function IUserInterface:load() end
function IUserInterface:unload() end

---@param dt number
function IUserInterface:update(dt) end
function IUserInterface:draw() end

---@param event table
function IUserInterface:receive(event) end

return IUserInterface
