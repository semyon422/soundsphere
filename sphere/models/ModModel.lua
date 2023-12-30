local class = require("class")

---@class sphere.Mod
---@operator call: sphere.Mod
---@field public name string
---@field public mount boolean
---@field public mountPath? string
---@field public load? fun(self: self, game: sphere.GameController)
---@field public update? fun(self: self, game: sphere.GameController, dt: number)
local Mod = class()

---@param name string
---@param mount boolean
---@param mountPath? string
---@param load? fun(self: self, game: sphere.GameController)
---@param update? fun(self: self, game: sphere.GameController, dt: number)
function Mod:new(name, mount, mountPath, load, update)
    self.name = name
    self.mount = mount
    self.mountPath = mountPath
    self.load = load
    self.update = update
end

return Mod