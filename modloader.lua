local physfs = require("physfs")
local class = require("class")

---@class sphere.ModLoader
---@operator call: sphere.ModLoader
local ModLoader = class()

local modsDirectoryPath = "moddedgame"
local scriptFileName = "mod.lua"

---@param path string
function ModLoader:new(path)
    self.root = path
end

---@return table[]
local function getMods()
    local mods = {}
    local modDirs = love.filesystem.getDirectoryItems(modsDirectoryPath)

    for _, dir in ipairs(modDirs) do
        local modPath = modsDirectoryPath .. "/" .. dir .. "/" .. scriptFileName
        local modModule = love.filesystem.getInfo(modPath)

        local mod = {
            scriptFile = nil,
            instance = nil,
            directory = dir,
        }

        if modModule then
            mod.scriptFile = assert(love.filesystem.load(modPath))
        end

        table.insert(mods, mod)
    end

    return mods
end

---@param modPath string
---@param filePath string
---@param fileMap table
---@param conflicts string[]
local function hasConflict(modPath, filePath, fileMap, conflicts)
    local path = modPath .. filePath

    for _, file in ipairs(love.filesystem.getDirectoryItems(path)) do
        local fullPath = filePath .. "/" .. file

        if love.filesystem.getInfo(modPath .. fullPath, "directory") then
            hasConflict(modPath, fullPath, fileMap, conflicts)
        else
            if fileMap[fullPath] ~= nil then
                table.insert(conflicts, fullPath)
            end

            if file ~= scriptFileName then
                fileMap[fullPath] = true
            end
        end
    end
end

---@param mods table[]
---@return string[]
local function checkForConflicts(mods)
    local conflicts = {}

    local fileMap = {}

    for _, mod in pairs(mods) do
        hasConflict(modsDirectoryPath .. "/" .. mod.directory .. "/", "", fileMap, conflicts)
    end

    return conflicts
end

---@param root string
---@param directory string
local function mount(root, directory)
    local success, err = physfs.mount(root .. "/" .. modsDirectoryPath .. "/" .. directory .. "/", "/", false)
    success = success and true or false

    if not success then
        error("Error mounting mod: " .. err)
    end
end

function ModLoader:loadMods()
    local mods = getMods()

    local conflicts = checkForConflicts(mods)

    if #conflicts ~= 0 then
        for _, file in ipairs(conflicts) do
            print("Conflict: " .. file)
        end

        error("Two or more mods are modifying the same file. Check the console for details.")
    end

    for _, mod in pairs(mods) do
        mount(self.root, mod.directory)

        if mod.scriptFile then
            mod.instance = mod.scriptFile()
        end
    end

    for _, mod in pairs(mods) do
        if mod.instance then
            mod.instance:init(mods)
        end
    end
end

return ModLoader