-- local ServerMigration = require("sea.storage.old_server.ServerMigration")
-- local LjsqliteDatabase = require("rdb.db.LjsqliteDatabase")
-- local RestyMysqlDatabase = require("rdb.db.RestyMysqlDatabase")
-- local ServerSqliteDatabase = require("sea.storage.server.ServerSqliteDatabase")

local test = {}

-- function test.all()
-- 	local src_db = RestyMysqlDatabase()
-- 	src_db:open("backend", "username", "password", "127.0.0.1", 3306)

-- 	local dst_db = ServerSqliteDatabase(LjsqliteDatabase())
-- 	dst_db.path = "server.db"
-- 	dst_db:open()

-- 	dst_db.db:exec("BEGIN")
-- 	local mig = ServerMigration(src_db, dst_db.db)
-- 	mig:migrate()
-- 	dst_db.db:exec("COMMIT")
-- end

return test
