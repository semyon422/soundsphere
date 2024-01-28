local physfs = require("physfs")
local package = require("aqua.package")
local class = require("class")

---@class sphere.ModLoader
---@operator call: sphere.ModLoader
local ModLoader = class()

local modsDirectoryPath = "moddedgame"
local mountPath = "mount"

---@param path string
function ModLoader:new(path)
    self.root = path
end

---@param modModule table
---@param mountDir table
---@return boolean
local function isValidMod(modModule, mountDir)
    return (modModule ~= nil) or (mountDir ~= nil)
end

---@param dir string
---@param modModule table
---@param mountDir table
---@return table
local function createMod(dir, modModule, mountDir)
    local mod = {
        scriptFile = nil,
        instance = nil,
        directory = dir,
        mount = mountDir ~= nil
    }

    if modModule then
        local modPath = modsDirectoryPath .. "/" .. dir .. "/mod.lua"
        mod.scriptFile = modPath:gsub(".lua$", "")
    end

    return mod
end

---@return table[]
local function getMods()
    local mods = {}
    local modDirs = love.filesystem.getDirectoryItems(modsDirectoryPath)

    for _, dir in ipairs(modDirs) do
        local modPath = modsDirectoryPath .. "/" .. dir .. "/mod.lua"
        local modModule = love.filesystem.getInfo(modPath)
        local mountDir = love.filesystem.getInfo(modsDirectoryPath .. "/" .. dir .. "/" .. mountPath)

        if isValidMod(modModule, mountDir) then
            local mod = createMod(dir, modModule, mountDir)
            package.add(modsDirectoryPath .. "/" .. dir)
            table.insert(mods, mod)
        end
    end

    return mods
end

---@param modPath string
---@param filePath string
---@param fileMap table
---@param conflicts string[]
---@return boolean
local function hasConflict(modPath, filePath, fileMap, conflicts)
    local conflictFound = false

    local path = modPath .. filePath
    for _, file in ipairs(love.filesystem.getDirectoryItems(path)) do
        local fullPath = filePath .. "/" .. file

        if love.filesystem.getInfo(modPath .. fullPath, "directory") then
            hasConflict(modPath, fullPath, fileMap, conflicts)
        else
            if fileMap[fullPath] ~= nil then
                conflictFound = true
                table.insert(conflicts, fullPath)
            end

            fileMap[fullPath] = true
        end
    end

    return conflictFound
end

---@param mods table[]
---@return boolean
---@return string[]
local function checkForConflicts(mods)
    local conflictFound = false
    local conflicts = {}

    local fileMap = {}

    for _, mod in pairs(mods) do
        if mod.mount then
            hasConflict(modsDirectoryPath .. "/" .. mountPath, "", fileMap, conflicts)
        end
    end

    return conflictFound, conflicts
end

---@param root string
---@param mod table
---@return boolean
local function mount(root, mod)
    local success, error = physfs.mount(root .. "/" .. modsDirectoryPath .. "/" .. mod.directory .. "/" .. mountPath, "/", false)
    success = success and true or false

    if error then
        print("Error mounting mod: " .. error)
    end

    return success
end

function ModLoader:loadMods()
    local mods = getMods()

    local conflictFound, conflictsPath = checkForConflicts(mods)

    if conflictFound then
        for _, file in pairs(conflictsPath) do
            print("Conflict: " .. file)
        end

        error("Two or more mods are modifying the same file. Check the console for details.")
    end

    for _, mod in pairs(mods) do
        if mod.mount == true then
            local result = mount(self.root, mod)

            if result == false then
                mod = nil
            end
        end
    end

    for _, mod in pairs(mods) do
        if mod.scriptFile then
            mod.instance = require(mod.scriptFile)
        end
    end

    for _, mod in pairs(mods) do
        if mod.instance and mod.instance.init then
            mod.instance:init(mods)
        end
    end
end

return ModLoader