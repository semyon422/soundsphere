local Dan = require("sea.dan.Dan")
local ChartmetaKey = require("sea.chart.ChartmetaKey")

---@param hash string
---@param level number
---@param category string
---@param name string
---@param accuracy number?
---@return sea.Dan
local function osuv1(hash, level, category, name, accuracy)
	local d = Dan()
	local cm = ChartmetaKey()
	cm.hash = hash
	cm.index = 1
	d.chartmeta_keys = {cm}
	d.level = level
	d.category = category
	d.name = name
	d.min_accuracy = accuracy or 0.81
	return d
end

---@param hash string
---@param level number
---@param category string
---@param name string
---@param accuracy number?
---@return sea.Dan
local function osuv2(hash, level, category, name, accuracy)
	local d = Dan()
	local cm = ChartmetaKey()
	cm.hash = hash
	cm.index = 1
	d.chartmeta_keys = {cm}
	d.level = level
	d.category = category
	d.name = name
	d.min_accuracy = accuracy or 0.81
	return d
end

---@param hashes string[]
---@param level number
---@param category string
---@param name string
---@param max_misses number?
---@return sea.Dan
local function bms_dan(hashes, level, category, name, max_misses)
	local d = Dan()
	d.chartmeta_keys = {}
	for _, hash in ipairs(hashes) do
		local cm = ChartmetaKey()
		cm.hash = hash
		cm.index = 1
		table.insert(d.chartmeta_keys, cm)
	end
	d.level = level
	d.category = category
	d.name = name
	d.max_misses = max_misses or 200
	return d
end

---@type {[integer]: sea.Dan}
local t = {
	-- 4K REFORM
	[1] = osuv1("521aacbb806bd0a5e450671565a44709", 1, "4K REFORM", "1st"),
	[2] = osuv1("e5e7b0cd3a7da4bd39cd8f82eaa7cd8b", 2, "4K REFORM", "2nd"),
	[3] = osuv1("31192103e37a913488720f3ae5b107de", 3, "4K REFORM", "3rd"),
	[4] = osuv1("05c57c4a96dbdfbeb9fec810741b5fca", 4, "4K REFORM", "4th"),
	[5] = osuv1("23054363b86479ba1d9596d26a7acc69", 5, "4K REFORM", "5th"),
	[6] = osuv1("f7c9fbb87a804dc7f5f8f558deac71bd", 6, "4K REFORM", "6th"),
	[7] = osuv1("8e1be66b82e1480c4ad8a4e1a297b1b8", 7, "4K REFORM", "7th"),
	[8] = osuv1("92bba709bcc871333df46d606aaa5d48", 8, "4K REFORM", "8th"),
	[9] = osuv1("d25a4b3fde5bc764d259b1bac6a7671c", 9, "4K REFORM", "9th"),
	[10] = osuv1("1e0310955d28145ca287112360d162e8", 10, "4K REFORM", "10th"),
	[11] = osuv1("e86b3a738dd101eb4be9afffcbc5f3a8", 11, "4K REFORM", "Alpha"),
	[12] = osuv1("e3a43a14d982dadfd2b015b0ac641921", 12, "4K REFORM", "Beta"),
	[13] = osuv1("e0bbf500b763e48ddc5a6f3fafacf58e", 13, "4K REFORM", "Gamma"),
	[14] = osuv1("6432f864b074264c230604cfe142edb0", 14, "4K REFORM", "Delta"),
	[15] = osuv1("c290f7c54064a7ff3e15bc64ddfc8692", 15, "4K REFORM", "Epsilon"),
	[16] = osuv1("7fab4c2623aac25d74f9300bfc4394c1", 16, "4K REFORM", "Zeta"),
	[17] = osuv1("8f175c7b6f529a877871eb2044ce516b", 17, "4K REFORM", "Eta"),
	-- 4K LN
	[101] = osuv2("9d85e749d23867de0de4c386f1bcd9c4", 1, "4K LN", "1st", 0.74),
	[102] = osuv2("6225fbaff7826864d3d0dcb969748ba2", 2, "4K LN", "2nd", 0.74),
	[103] = osuv2("a10badbb0221cd980074af52985394f2", 3, "4K LN", "3nd", 0.74),
	[104] = osuv2("c3004678a64284311c4b8122b9c24c95", 4, "4K LN", "4th", 0.74),
	[105] = osuv2("5d0bb157a5a15366e5b3f618c46a4dbc", 5, "4K LN", "5th", 0.74),
	[106] = osuv2("3e48a802afa52dd968af5e873db2d11f", 6, "4K LN", "6th", 0.74),
	[107] = osuv2("805603dbe1ffa54cc3e1de40a46db30f", 7, "4K LN", "7th", 0.74),
	[108] = osuv2("c5de0708efdb56b4081e6f922e82ca1f", 8, "4K LN", "8th", 0.74),
	[109] = osuv2("72424bc96cdcfc9093d8c131ac049cca", 9, "4K LN", "9th", 0.74),
	[110] = osuv2("90bba68a15429f745702dbf1d17664c2", 10, "4K LN", "10th", 0.74),
	[111] = osuv2("c81ab2651fb6746d6af37f53e8830105", 11, "4K LN", "11th", 0.74),
	[112] = osuv2("ec14ce28a853cf7ac1e74adbed61a820", 12, "4K LN", "12th", 0.74),
	[113] = osuv2("9068585a3e2874492da1f9a1e080d86b", 13, "4K LN", "13th", 0.74),
	[114] = osuv2("6bd4f93291d68ec74c009a7ff94c1d40", 14, "4K LN", "14th", 0.74),
	[115] = osuv2("bb1590cce46fd65a548541fe8c38a317", 15, "4K LN", "15th", 0.74),
	-- 7K REGULAR
	[201] = osuv1("403ddeb24d4deeecc75a09942640401e", 0, "7K REGULAR", "0th"),
	[202] = osuv1("d2dde2e1cdfb0fdeaa975aea4ae33e42", 1, "7K REGULAR", "1st"),
	[203] = osuv1("f33d7c8df46e579996951e63746c3217", 2, "7K REGULAR", "2nd"),
	[204] = osuv1("b2deac5abe831acc34b4cb053f1949a1", 3, "7K REGULAR", "3rd"),
	[205] = osuv1("6ef18aaf72c4f71756b0da87f7a289bc", 4, "7K REGULAR", "4th"),
	[206] = osuv1("f198256f6da1b0a95f8e267196333045", 5, "7K REGULAR", "5th"),
	[207] = osuv1("e0f009741295dc2912d6991f15e3fa43", 6, "7K REGULAR", "6th"),
	[208] = osuv1("a0c3d30d75911706ef371d5bec636de3", 7, "7K REGULAR", "7th"),
	[209] = osuv1("c7040fa644b4649be60f1586e37fe1fa", 8, "7K REGULAR", "8th"),
	[210] = osuv1("4bddef566f968374652f4ec365179435", 9, "7K REGULAR", "9th"),
	[211] = osuv1("71bb06db9d7acb6381aee08cb32d6d74", 10, "7K REGULAR", "10th"),
	[212] = osuv1("22c436600e746a04e7ede85765f382c8", 11, "7K REGULAR", "Gamma"),
	[213] = osuv1("c9927b9b467c5958994ad215abb60609", 12, "7K REGULAR", "Azimuth"),
	[214] = osuv1("90492cfc1244bb1db82bba87eafe9cda", 13, "7K REGULAR", "Zenith"),
	-- 7K LN
	[301] = osuv1("04f95ed271f790090e53dbe7eff50dbd", 0, "7K LN", "0th"),
	[302] = osuv1("d362b5025667785becb1dbd18e55a963", 1, "7K LN", "1st"),
	[303] = osuv1("f80fc0aa5c1ea84faf8919874f37be86", 2, "7K LN", "2nd"),
	[304] = osuv1("1052047a32fa9cc8d4105723e330ada0", 3, "7K LN", "3rd"),
	[305] = osuv1("173928678c78d1fa6cff5d8ca2c07169", 4, "7K LN", "4th"),
	[306] = osuv1("c84c3b7ace5d36c587c269aab33a0c1c", 5, "7K LN", "5th"),
	[307] = osuv1("8aea034ea3f511394c36dcb7adb5ea9c", 6, "7K LN", "6th"),
	[308] = osuv1("a90a6084127cb966436c1a78e5a5bc7f", 7, "7K LN", "7th"),
	[309] = osuv1("58d31463a6ff83551d7571b1e63acba6", 8, "7K LN", "8th"),
	[310] = osuv1("09546ec514f9fa60549a4e08478582a6", 9, "7K LN", "9th"),
	[311] = osuv1("95862ed585b86ccf0a2dd2b0298f19aa", 10, "7K LN", "10th"),
	[312] = osuv1("7bf64c587c2966db05e4bf44e8c78d72", 11, "7K LN", "Gamma"),
	[313] = osuv1("21a9c6b63a722f5903375497306c1c6f", 12, "7K LN", "Azimuth"),
	[314] = osuv1("4ad36f558655a1f17781038517455215", 13, "7K LN", "Zenith"),
	-- 10K REGULAR
	[401] = osuv1("d7328e981f43d7f8ba11b4ad90b8c005", 0, "10K REGULAR", "0th"),
	[402] = osuv1("3663897f04a1bd32d15a475d635e8467", 1, "10K REGULAR", "1st"),
	[403] = osuv1("7e7e67d8385771007d099942c18ba7ff", 2, "10K REGULAR", "2nd"),
	[404] = osuv1("64a84abcf073a90ae8b2080dbd252539", 3, "10K REGULAR", "3rd"),
	[405] = osuv1("fe913e5a9f720884e50d4b7fae7b9fae", 4, "10K REGULAR", "4th"),
	[406] = osuv1("cb1c073652b14f5a346d383565acba91", 5, "10K REGULAR", "5th"),
	[407] = osuv1("149e17f2d7e9c31b3a2999ab2c09ed46", 6, "10K REGULAR", "6th"),
	[408] = osuv1("ee45bd9848b1ec5256058d572078046d", 7, "10K REGULAR", "7th"),
	[409] = osuv1("837b12e08cb309e4509650291b3d5276", 8, "10K REGULAR", "8th"),
	[410] = osuv1("77ce1c182238d516595e19830d8c867c", 9, "10K REGULAR", "9th"),
	[411] = osuv1("849fa8a3264604fd9412d60e5fa46981", 10, "10K REGULAR", "10th"),
	[412] = osuv1("ad25c18e6e4a0f92805c3e9c7399f1ad", 11, "10K REGULAR", "V"),
	[413] = osuv1("24369e1034d8614323ecbafa7672ffe6", 12, "10K REGULAR", "XI"),
	-- BMS
	[99999] = bms_dan({"test1", "test2", "test3", "test4"}, 1, "Test", "Lv.1"),
}

for id, dan in pairs(t) do
	dan.id = id
end

return t
