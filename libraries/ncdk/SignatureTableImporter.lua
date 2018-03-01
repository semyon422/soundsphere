ncdk.SignatureTableImporter = {}
local SignatureTableImporter = ncdk.SignatureTableImporter

ncdk.SignatureTableImporter_metatable = {}
local SignatureTableImporter_metatable = ncdk.SignatureTableImporter_metatable
SignatureTableImporter_metatable.__index = SignatureTableImporter

SignatureTableImporter.new = function(self, lineTable)
	local signatureTableImporter = {}
	
	signatureTableImporter.lineTable = lineTable
	
	setmetatable(signatureTableImporter, SignatureTableImporter_metatable)
	
	return signatureTableImporter
end

SignatureTableImporter.DataEnum = {
	defaultSignature = 3,
	signatureDataFirstIndex = 4
}

SignatureTableImporter.getSignatureTable = function(self)
	local defaultSignature = ncdk.Fraction:new():fromString(self.lineTable[self.DataEnum.defaultSignature])
	local signatureTable = ncdk.SignatureTable:new(defaultSignature)
	
	for i = self.DataEnum.signatureDataFirstIndex, #self.lineTable do
		local data = self.lineTable[i]:split(":")
		local measureIndex = tonumber(data[1])
		local signature = ncdk.Fraction:new():fromString(data[2])
		
		signatureTable:setSignature(measureIndex, signature)
	end
	
	return signatureTable
end