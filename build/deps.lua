-- Rizu Dependency Manifest
return {
	ffmpeg = {
		linux = {
			url = "https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-linux64-gpl-shared.tar.xz",
			archive = "ffmpeg-linux.tar.xz",
			dir = "ffmpeg-linux"
		},
		windows = {
			url = "https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl-shared.zip",
			archive = "ffmpeg-win.zip",
			dir = "ffmpeg-win"
		},
		-- MacOS SDK is handled by setup_cross_macos.sh due to its proprietary nature
	},
	sevenzip = {
		url = "https://www.7-zip.org/a/7z2409-src.7z",
		archive = "7z-src.7z",
		dir = "7zsdk"
	},
	love_macos = {
		url = "https://github.com/love2d/love/releases/download/11.5/love-11.5-macos.zip",
		archive = "love-macos.zip"
	}
	-- Placeholder for future deps like BASS, SQLite, etc.
}
