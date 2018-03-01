ncdk.SignatureTable = {}
local SignatureTable = ncdk.SignatureTable

ncdk.SignatureTable_metatable = {}
local SignatureTable_metatable = ncdk.SignatureTable_metatable
SignatureTable_metatable.__index = SignatureTable

SignatureTable.new = function(self, defaultSignature)
	local signatureTable = {}
	
	signatureTable.defaultSignature = defaultSignature
	
	setmetatable(signatureTable, SignatureTable_metatable)
	
	return signatureTable
end

SignatureTable.setSignature = function(self, measureIndex, signature)
	self[measureIndex] = signature
end

SignatureTable.getSignature = function(self, measureIndex)
	return self[measureIndex] or self.defaultSignature
end