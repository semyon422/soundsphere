local class = require("class")
local Library = require("rizu.library.Library")
local DifficultyModel = require("sphere.models.DifficultyModel")
local LoveFilesystem = require("fs.LoveFilesystem")

---@class rizu.library.LibraryTestContext
---@operator call: rizu.library.LibraryTestContext
local LibraryTestContext = class()

---@param dbPath string?
function LibraryTestContext:new(dbPath)
	self.currentTime = 0
	self.getTime = function() return self.currentTime end

	self.fs = LoveFilesystem()

	self.lib = Library(DifficultyModel(), self.fs, "/test", self.getTime)
	self.lib:setSync(true)

	self.lib:load(":memory:")

	self.statusUpdates = {}
	self.lib.onStatusChanged:add({
		receive = function(_, status)
			-- Deep copy status to record history correctly
			local copy = {}
			for k, v in pairs(status) do copy[k] = v end
			table.insert(self.statusUpdates, copy)
		end,
	})
end

function LibraryTestContext:process()
	self.lib:process()
end

---@param amount number
function LibraryTestContext:advanceTime(amount)
	self.currentTime = self.currentTime + amount
end

function LibraryTestContext:cleanup()
	self.lib:unload()
end

return LibraryTestContext
