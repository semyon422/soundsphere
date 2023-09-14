

return {

	-- controllers

	editorController = {
		"selectModel",
		"editorModel",
		"noteSkinModel",
		"previewModel",
		"configModel",
		"resourceModel",
		"windowModel",
		"cacheModel",
	},
	fastplayController = {
		"rhythmModel",
		"replayModel",
		"modifierModel",
		"selectModel",
		"difficultyModel",
	},
	gameplayController = {
		"rhythmModel",
		"selectModel",
		"noteSkinModel",
		"configModel",
		"modifierModel",
		"difficultyModel",
		"replayModel",
		"multiplayerModel",
		"previewModel",
		"discordModel",
		"scoreModel",
		"onlineModel",
		"resourceModel",
		"windowModel",
		"notificationModel",
		"speedModel",
		"cacheModel",
	},
	multiplayerController = {
		"multiplayerModel",
		"modifierModel",
		"configModel",
		"selectModel",
	},
	resultController = {
		"selectModel",
		"replayModel",
		"rhythmModel",
		"modifierModel",
		"onlineModel",
		"configModel",
		"fastplayController",
	},
	selectController = {
		"selectModel",
		"previewModel",
		"modifierModel",
		"noteSkinModel",
		"configModel",
		"backgroundModel",
		"multiplayerModel",
		"onlineModel",
		"mountModel",
		"cacheModel",
		"osudirectModel",
		"windowModel",
	},

	-- models

	backgroundModel = {"configModel"},
	configModel = {},
	cacheModel = {},
	difficultyModel = {},
	editorModel = {
		"configModel",
		"resourceModel",
	},
	notificationModel = {},
	themeModel = {"configModel"},
	scoreModel = {"configModel"},
	onlineModel = {"configModel"},
	modifierModel = {},
	noteSkinModel = {"configModel"},
	inputModel = {"configModel"},
	scoreLibraryModel = {
		"configModel",
		"onlineModel",
		"scoreModel",
	},
	selectModel = {
		"configModel",
		"scoreLibraryModel",
		"cacheModel",
	},
	previewModel = {
		"configModel",
	},
	rhythmModel = {
		"inputModel",
		"resourceModel",
	},
	osudirectModel = {
		"configModel",
		"cacheModel",
	},
	multiplayerModel = {
		"rhythmModel",
		"configModel",
		"modifierModel",
		"selectModel",
		"onlineModel",
		"osudirectModel",
	},
	replayModel = {
		"selectModel",
		"rhythmModel",
		"modifierModel",
	},
	speedModel = {"configModel"},
	resourceModel = {"configModel"},

	-- views

	gameView = {"game"},
	selectView = {"game"},
	resultView = {"game"},
	gameplayView = {"game"},
	multiplayerView = {"game"},
	editorView = {"game"},
}
