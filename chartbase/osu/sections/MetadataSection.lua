local KeyValue = require("osu.sections.KeyValue")

---@class osu.MetadataSection: osu.KeyValue
---@operator call: osu.MetadataSection
local MetadataSection = KeyValue + {}

MetadataSection.space = false

MetadataSection.Title = ""
MetadataSection.TitleUnicode = ""
MetadataSection.Artist = ""
MetadataSection.ArtistUnicode = ""
MetadataSection.Creator = ""
MetadataSection.Version = ""
MetadataSection.Source = ""
MetadataSection.Tags = ""
MetadataSection.BeatmapID = "0"
MetadataSection.BeatmapSetID = "-1"

MetadataSection.keys = {
	"Title",
	"TitleUnicode",
	"Artist",
	"ArtistUnicode",
	"Creator",
	"Version",
	"Source",
	"Tags",
	"BeatmapID",
	"BeatmapSetID",
}

return MetadataSection
