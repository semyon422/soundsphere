#!/usr/bin/env luajit

--[[
	Spec-to-Test Traceability Tool
	This script finds all spec.md files, extracts requirements,
	and checks if they are referenced in _test.lua files using @spec tags.
]]

local function get_specs()
	local specs = {}
	local handle = io.popen('find . -name "spec.md"')
	for path in handle:lines() do
		local file = io.open(path, "r")
		if file then
			local content = file:read("*a")
			file:close()
			local headings = {}
			for heading in content:gmatch("\n## ([^\n]+)") do
				table.insert(headings, {
					name = heading,
					covered = false,
					test_files = {},
				})
			end
			specs[path] = headings
		end
	end
	handle:close()
	return specs
end

local function check_coverage(specs)
	local handle = io.popen('find . -name "*_test.lua"')
	for test_path in handle:lines() do
		local file = io.open(test_path, "r")
		if file then
			local content = file:read("*a")
			file:close()

			for spec_path, headings in pairs(specs) do
				for _, heading in ipairs(headings) do
					-- Search for @spec: [spec_path]# [heading_name]
					-- Escaping special characters for the pattern
					local pattern = "@spec:%s*" ..
					spec_path:gsub("%-", "%%-"):gsub("%.", "%%.") .. "#%s*" .. heading.name:gsub("[%-%(%)%.%%%+%*%?%^%$%[%]]", "%%%1")
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

local function report(specs)
	local total = 0
	local covered = 0
	print("\n--- Specification Coverage Report ---")

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
				print(string.format("  [OK] %s", heading.name))
				for _, test_file in ipairs(heading.test_files) do
					print(string.format("       -> %s", test_file))
				end
			else
				print(string.format("  [MISSING] %s", heading.name))
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
