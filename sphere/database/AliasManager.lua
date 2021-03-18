local json = require("json")

local AliasManager = {}

AliasManager.path = "userdata/aliases.json"

AliasManager.load = function(self)
	local info = love.filesystem.getInfo(self.path)
	if info then
        local contents = love.filesystem.read(self.path)
		self.data = json.decode(contents)
    else
        self.data = {}
	end
end

AliasManager.getAlias = function(self, type, key)
    local data = self.data
    return data[type] and data[type][key] or key
end

return AliasManager
