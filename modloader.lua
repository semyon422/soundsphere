local physfs = require("physfs")

local ModLoader = {}
local modsDirectory = "moddedgame"

---@return string[]
function ModLoader:getMods()
    local mods = {}

    for _, file in ipairs(love.filesystem.getDirectoryItems(modsDirectory)) do
        if love.filesystem.getInfo(modsDirectory .. "/" .. file, "directory") then
            table.insert(mods, file)
        end
    end

    return mods
end

---@param mods string[]
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

    for _, mod in ipairs(mods) do
        checkDirectory(modsDirectory .. "/" .. mod, "")
    end

    return conflictFound, conflicts
end

---@param path string
function ModLoader:mount(path)
    assert(physfs.mount(self.root .. "/" .. modsDirectory .."/" .. path, "/", false))
    print(path .. " mounted")
end

---@param path string
function ModLoader:setRoot(path)
    self.root = path
end

function ModLoader:load()
    physfs.setWriteDir(self.root)

    local mods = self:getMods()

    local conflictFound, conflicts_path = self:checkForConflicts(mods)

    if conflictFound then
        for _, file in pairs(conflicts_path) do
            print("Conflict: " .. file)
        end
        
        error("Two or more mods are modifying the same file. Check the console for details.")
    end

    for _, mod in ipairs(mods) do
        self:mount(mod)
    end
end

return ModLoader