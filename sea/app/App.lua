local class = require("class")

---@class sea.App
---@operator call: sea.App
local App = class()

---@param req web.IRequest
---@param res web.IResponse
function App:handle(req, res)
	res.status = 200
	res:set_chunked_encoding()
	res:send("hello world")
	res:send("")
end

return App
