bms.ChannelEnum = {
	BGM = "01",
	Signature = "02",
	Tempo = "03",
	ExtendedTempo = "08",
	Stop = "09",
	
	_1P7SS = "16",
	_1P7LS = "56",
	
	_1P7S1 = "11",
	_1P7S2 = "12",
	_1P7S3 = "13",
	_1P7S4 = "14",
	_1P7S5 = "15",
	_1P7S6 = "18",
	_1P7S7 = "19",
	
	_1P7L1 = "51",
	_1P7L2 = "52",
	_1P7L3 = "53",
	_1P7L4 = "54",
	_1P7L5 = "55",
	_1P7L6 = "58",
	_1P7L7 = "59",
	
}

bms.ColumnIndexTable = {
	[bms.ChannelEnum._1P7S1] = 1,
	[bms.ChannelEnum._1P7S2] = 2,
	[bms.ChannelEnum._1P7S3] = 3,
	[bms.ChannelEnum._1P7S4] = 4,
	[bms.ChannelEnum._1P7S5] = 5,
	[bms.ChannelEnum._1P7S6] = 6,
	[bms.ChannelEnum._1P7S7] = 7,
	[bms.ChannelEnum._1P7SS] = "S",
	
	[bms.ChannelEnum._1P7L1] = 1,
	[bms.ChannelEnum._1P7L2] = 2,
	[bms.ChannelEnum._1P7L3] = 3,
	[bms.ChannelEnum._1P7L4] = 4,
	[bms.ChannelEnum._1P7L5] = 5,
	[bms.ChannelEnum._1P7L6] = 6,
	[bms.ChannelEnum._1P7L7] = 7,
	[bms.ChannelEnum._1P7LS] = "S",
	
	[bms.ChannelEnum.BGM] = -1,
}

bms.LongNote = {
	[bms.ChannelEnum._1P7L1] = true,
	[bms.ChannelEnum._1P7L2] = true,
	[bms.ChannelEnum._1P7L3] = true,
	[bms.ChannelEnum._1P7L4] = true,
	[bms.ChannelEnum._1P7L5] = true,
	[bms.ChannelEnum._1P7L6] = true,
	[bms.ChannelEnum._1P7L7] = true,
	[bms.ChannelEnum._1P7LS] = true,
}