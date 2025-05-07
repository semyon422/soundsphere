local class = require("class")
local TableOrm = require("rdb.TableOrm")
local Models = require("rdb.Models")
local autoload = require("autoload")
local ServerDatabaseMigrator = require("sea.storage.old_server.ServerDatabaseMigrator")
local ServerRepo = require("sea.storage.old_server.ServerRepo")
local Repos = require("sea.app.Repos")

---@class sea.old.ServerMigration
---@operator call: sea.old.ServerMigration
local ServerMigration = class()

---@param src_db rdb.IDatabase
---@param dst_db rdb.IDatabase
function ServerMigration:new(src_db, dst_db)
	self.src_db = src_db
	self.dst_db = dst_db
end

function ServerMigration:migrate()
	local src_models = Models(autoload("sea.storage.old_server.models", true), TableOrm(self.src_db))
	local old_repo = ServerRepo(src_models)

	local dst_models = Models(autoload("sea.storage.server.models", true), TableOrm(self.dst_db))
	local repos = Repos(dst_models)

	local migrator = ServerDatabaseMigrator(old_repo, repos)
	migrator:migrateAll()
end

return ServerMigration
