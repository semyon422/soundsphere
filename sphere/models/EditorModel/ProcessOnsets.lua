local rbtree = require("rbtree")

return function(self)  -- self is EditorModel
	local ok, ncbt = pcall(require, "ncbt")
	if not ok then
		return
	end

	local onsets = ncbt.onsets(self.soundData)

	local tree = rbtree.new()
	for _, time in ipairs(onsets) do
		tree:insert(time)
	end
	self.onsets = tree
	function tree:findsub(key)
		local y
		local x = self.root
		while x and key ~= x.key.time do
			y = x
			if key < x.key.time then
				x = x.left
			else
				x = x.right
			end
		end
		return x, y
	end


	local out = ncbt.tempo_offset(onsets)
	for k, v in pairs(out) do
		self[k] = v
	end
end
