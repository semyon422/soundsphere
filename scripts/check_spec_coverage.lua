#!/usr/bin/env luajit

--[[
	Spec-to-Test Traceability Tool
	This script finds all spec.md files, extracts requirements,
	and checks if they are referenced in _test.lua files using @spec tags.
]]

---@class util.SpecCoverageHeading
---@field id string
---@field covered boolean
---@field test_files string[]

---@return {[string]: util.SpecCoverageHeading[]}
local function get_specs()
	---@type {[string]: util.SpecCoverageHeading[]}
	local specs = {}
	local handle = assert(io.popen('find . -name "spec.md"'))
	for path in handle:lines() do ---@diagnostic disable-line: no-unknown
		---@cast path string
		local clean_path = path:gsub("^%./", "")
		local file = io.open(path, "r")
		if file then
			local content = file:read("*a")
			file:close()
			local headings = {}
			-- Search for [REQ-*] anywhere in the content
			for req_tag in content:gmatch("%[REQ%-[^%]]+%]") do ---@diagnostic disable-line: no-unknown
				---@cast req_tag string
				table.insert(headings, {
					id = req_tag,
					covered = false,
					test_files = {},
				})
			end
			specs[clean_path] = headings
		end
	end
	handle:close()
	return specs
end

---@param specs {[string]: util.SpecCoverageHeading[]}
local function check_coverage(specs)
	local handle = assert(io.popen('find . -name "*_test.lua"'))
	for test_path in handle:lines() do
		local file = io.open(test_path, "r")
		if file then
			local content = file:read("*a")
			file:close()

			for spec_path, headings in pairs(specs) do
				for _, heading in ipairs(headings) do
					-- Search for @spec [spec_path]#[ID]
					local pattern = "@spec%s+" ..
						spec_path:gsub("%-", "%%-"):gsub("%.", "%%.") .. "#" .. heading.id:gsub("[%-%(%)%.%%%+%*%?%^%$%[%]]", "%%%1")
					if content:find(pattern) then
						heading.covered = true
						table.insert(heading.test_files, test_path)
					end
				end
			end
		end
	end
	handle:close()
end

---@param specs {[string]: util.SpecCoverageHeading[]}
local function report(specs)
	local total = 0
	local covered = 0
	print("\n--- Specification Coverage Report ---")

	---@type string[]
	local sorted_paths = {}
	for path in pairs(specs) do table.insert(sorted_paths, path) end
	table.sort(sorted_paths)

	for _, path in ipairs(sorted_paths) do
		local headings = specs[path]
		print(string.format("\nFile: %s", path))
		for _, heading in ipairs(headings) do
			total = total + 1
			if heading.covered then
				covered = covered + 1
				print(string.format("  [OK] %s", heading.id))
				for _, test_file in ipairs(heading.test_files) do
					print(string.format("       -> %s", test_file))
				end
			else
				print(string.format("  [MISSING] %s", heading.id))
			end
		end
	end

	print("\n-------------------------------------")
	print(string.format("Total Requirements: %d", total))
	print(string.format("Covered:            %d (%.1f%%)", covered, (covered / total) * 100))
	print("-------------------------------------\n")

	if covered < total then
		os.exit(1)
	end
end

local specs = get_specs()
check_coverage(specs)
report(specs)
