local class = require("class")
local MinoProvider = require("rizu.dlc.providers.MinoProvider")
local path_util = require("path_util")
local http_util = require("http_util")
local DlcType = require("rizu.dlc.DlcType")

---@class rizu.dlc.DlcWorker
---@operator call: rizu.dlc.DlcWorker
local DlcWorker = class()

---@param manager rizu.dlc.DlcManager
---@param workingDirectory string
---@param osuConfig table?
function DlcWorker:new(manager, workingDirectory, osuConfig)
	self.manager = manager
	self.workingDirectory = workingDirectory
	self.providers = {
		mino = MinoProvider(osuConfig),
	}
end

---@param query string
---@param type rizu.dlc.DlcType
---@param filters table?
---@param provider_name string?
---@return table[]? results, string? error
function DlcWorker:search(query, type, filters, provider_name)
	provider_name = provider_name or "mino"
	local provider = self.providers[provider_name]
	if not provider then return nil, "Provider not found" end
	return provider:search(query, type, filters)
end

---@param id string|number
---@param type rizu.dlc.DlcType
---@param provider_name string?
---@param metadata table?
---@return boolean? success, string? error
function DlcWorker:download(id, type, provider_name, metadata)
	provider_name = provider_name or "mino"
	local provider = self.providers[provider_name]
	if not provider then return nil, "Provider not found" end

	local url, err = provider:getDownloadUrl(id)
	if not url then return nil, err end

	print("[DlcWorker] Downloading:", url)

	self.manager:updateTask(id, {status = "connecting", progress = 0})

	local http_util = require("web.http.util")
	local client = http_util.client()
	local req, res, err = client:connect(url)
	if not req then
		print("[DlcWorker] Connection error:", err)
		self.manager:updateTask(id, {status = "error", error = err})
		return nil, err
	end

	local body_t = {}
	local total_received = 0
	local total_size = 0
	local start_time = love.timer.getTime()

	local ok, err = req:send("")
	if not ok then
		print("[DlcWorker] Request send error:", err)
		client:close()
		self.manager:updateTask(id, {status = "error", error = err})
		return nil, err
	end

	local ok, err = res:receive_headers()
	if not ok then
		print("[DlcWorker] Receive headers error:", err)
		client:close()
		self.manager:updateTask(id, {status = "error", error = err})
		return nil, err
	end

	if res.status >= 400 then
		local err_msg = "HTTP " .. res.status
		print("[DlcWorker] HTTP error:", res.status)
		client:close()
		self.manager:updateTask(id, {status = "error", error = err_msg})
		return nil, err_msg
	end

	total_size = tonumber(res.headers:get("Content-Length")) or 0
	self.manager:updateTask(id, {status = "downloading", size = total_size})

	local chunk_size = 64 * 1024
	while true do
		local chunk, err, partial = res:receive(chunk_size)
		if not chunk then
			if partial and #partial > 0 then
				total_received = total_received + #partial
				table.insert(body_t, partial)
			end

			if err == "closed" or err == nil then
				break
			end
			print("[DlcWorker] Receive chunk error for " .. tostring(id) .. ": " .. tostring(err))
			client:close()
			self.manager:updateTask(id, {status = "error", error = err})
			return nil, err
		end

		total_received = total_received + #chunk
		table.insert(body_t, chunk)

		local current_time = love.timer.getTime()
		local duration = current_time - start_time
		local speed = duration > 0 and (total_received / duration) or 0
		local progress = total_size > 0 and (total_received / total_size) or 0

		self.manager:updateTask(id, {
			progress = progress,
			total = total_received,
			speed = speed
		})
	end

	client:close()
	local body = table.concat(body_t)

	-- Determine filename
	local filename = url:match("^.+/(.-)$")
	local cd_header = res.headers:get("Content-Disposition")
	if cd_header then
		local cd = require("http_util").parse_content_disposition(cd_header)
		filename = cd.filename or filename
	end
	filename = path_util.fix_illegal(filename)

	-- Save and extract
	self.manager:updateTask(id, {status = "extracting"})
	
	local success, extract_err = self:processDlc(id, type, body, filename, metadata)
	if not success then
		print("[DlcWorker] Processing error for " .. tostring(id) .. ": " .. tostring(extract_err))
		self.manager:updateTask(id, {status = "error", error = extract_err})
		return nil, extract_err
	end

	self.manager:updateTask(id, {status = "completed", progress = 1})
	self.manager:onDlcCompleted(id, type, metadata)

	return true
end

---@param id string|number
---@param type rizu.dlc.DlcType
---@param data string
---@param filename string
---@param metadata table?
---@return boolean? success, string? error
function DlcWorker:processDlc(id, type, data, filename, metadata)
	local fs = love.filesystem
	
	-- We'll try to get the first location path from the library if possible,
	-- otherwise fallback to userdata/downloads
	local location_path = "userdata/downloads"
	-- In the worker we don't have easy access to library.locationsRepo unless we pass it,
	-- but we know from Locations:createDefaultLocation it's "userdata/charts"
	-- Let's use "userdata/charts/downloads" to be safe and compatible with legacy
	local downloads_dir = "userdata/charts/downloads"
	
	if not fs.getInfo(downloads_dir) then
		fs.createDirectory(downloads_dir)
	end

	local filepath = path_util.join(downloads_dir, filename)
	fs.write(filepath, data)

	if type == DlcType.CHART and filename:match("%.osz$") then
		local extract_dir = filename:match("^(.+)%.osz$")
		local extract_path = path_util.join(downloads_dir, extract_dir)
		
		local DlcExtractor = require("rizu.dlc.DlcExtractor")
		local ok, err = DlcExtractor.extract(filepath, extract_path)
		if not ok then
			return nil, "Extraction failed: " .. (err or "unknown error")
		end
		
		return true
	end

	-- For other types or when extraction isn't applicable, we just saved it.
	return true
end

return DlcWorker
