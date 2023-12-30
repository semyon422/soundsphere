local physfs = require("physfs")

local ModLoader = {}
local modsDirectoryPath = "moddedgame"

---@return sphere.Mod[] 
function ModLoader:getMods()
    local modsScriptFiles = {}

    for _, file in ipairs(love.filesystem.getDirectoryItems(modsDirectoryPath)) do
        if file:match(".lua$") then
            local name = file:gsub(".lua$", "")
            table.insert(modsScriptFiles, name)
        end
    end

    local mods = {}

    for _, scriptFile in pairs(modsScriptFiles) do
        local mod = require(modsDirectoryPath .. "/".. scriptFile)
        table.insert(mods, mod)
    end

    return mods
end

---@param mods sphere.Mod[] 
---@return boolean
---@return string[]
function ModLoader:checkForConflicts(mods)
    local conflictFound = false
    local conflicts = {}

    local file_map = {}

    ---@param modPath string
    ---@param filePath string
    local function checkDirectory(modPath, filePath)
        local path = modPath .. filePath
        for _, file in ipairs(love.filesystem.getDirectoryItems(path)) do
            local full_path = filePath .. "/" .. file

            if love.filesystem.getInfo(modPath .. full_path, "directory") then
                checkDirectory(modPath, full_path)
            else
                if file_map[full_path] ~= nil then
                    conflictFound = true
                    table.insert(conflicts, full_path)
                end

                file_map[full_path] = true
            end
        end
    end

    for _, mod in pairs(mods) do
        if mod.mount then
            checkDirectory(modsDirectoryPath .. "/" .. mod.mountPath, "")
        end
    end

    return conflictFound, conflicts
end

---@param mod sphere.Mod[] 
function ModLoader:mount(mod)
    assert(physfs.mount(self.root .. "/" .. modsDirectoryPath .."/" .. mod.mountPath, "/", false))
    print(mod.name .. " mounted")
end

---@param path string
function ModLoader:setRoot(path)
    self.root = path
end

---@return sphere.Mod[]
function ModLoader:load()
    local mods = self:getMods()

    local conflictFound, conflicts_path = self:checkForConflicts(mods)

    if conflictFound then
        for _, file in pairs(conflicts_path) do
            print("Conflict: " .. file)
        end

        error("Two or more mods are modifying the same file. Check the console for details.")
    end

    physfs.setWriteDir(self.root)

    for _, mod in ipairs(mods) do
        if mod.mount then
            self:mount(mod)
        end
    end

    return mods
end

return ModLoader