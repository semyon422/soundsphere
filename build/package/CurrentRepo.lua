local class = require("class")
local util = require("build.package.util")

---@class repo.CurrentRepo
---@operator call: repo.CurrentRepo
local CurrentRepo = class()

function CurrentRepo:new()
end

function CurrentRepo:getDirName()
	return "." -- We run from root
end

function CurrentRepo:log_date()
	return util.popen_read("git log -1 --format=%cd"):match("^%s*(.+)%s*\n.*$")
end

function CurrentRepo:log_commit()
	return util.popen_read("git log -1 --format=%H"):match("^%s*(.+)%s*\n.*$")
end

return CurrentRepo
