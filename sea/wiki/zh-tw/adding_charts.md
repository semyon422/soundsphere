> 本頁由 AI 翻譯!!! 可能包含令人困惑的錯誤，但我想您仍然能夠理解這裡解釋的內容。如果您害怕機器人，請閱讀原始英文頁面！

# 新增歌曲
有四種方式可以將歌曲新增到 soundsphere。我們建議您熟悉所有這些方式。

soundsphere 支援以下歌曲格式：
- `.osu` - 來自 **osu!** 的譜面
- `.qua` - 來自 **Quaver** 的歌曲
- `.sm` 和 `.ssc` - 來自 **StepMania** 和 **Etterna** 的歌曲
- `.bms`, `.bme`, `.bml` 和 `.pms` - 來自 **Lunatic Rave 2**, **beatoraja** 和其他 **Beatmania** 模擬器的歌曲
- `.ojn` - 來自 **o2jam** 的歌曲
- `.ksh` - 來自 **K-Shoot MANIA** 的歌曲
- `.sph` - 來自 **soundsphere** 的歌曲
- `.mid` 和 `.midi`。

在頁面的最後，您可以找到歌曲下載連結。

## 從文件夾新增歌曲庫
使用此方法，您可以指定磁碟上的歌曲文件夾路徑。這是新增您計算機上安裝的其他節奏遊戲所有歌曲的最佳方式。遊戲會從您指定的位置讀取，而無需複製文件。

首先，您需要找到歌曲文件夾，它可能是 **osu!**, **Quaver** 或 **Etterna** 的 `Songs` 文件夾，或只是一個包含歌曲的文件夾。我們感興趣的是具有以下文件層級結構的文件夾（**osu!** 和 **Quaver**）：
```
songs_folder/
├── song1/
│ ├── audio.mp3
│ ├── easy.osu
│ └── hard.osu
├── song2/
├── song3/
```

soundsphere 也支援從子文件夾中搜索歌曲（**Etterna** 和 **StepMania**）：
```
songs_folder/
├── pack1/
│ ├── song1/
│ │ ├── audio.mp3
│ │ └── chart.sm
│ ├── song2/
│ └── song3/
├── pack2/
├── pack3/
```

新增歌曲的這種方法需要一個根文件夾，在上面的例子中是 `songs_folder`，在 **osu!**, **Quaver** 和 **Etterna** 的情況下，它將是 `Songs` 文件夾。

1. 啟動 soundsphere。
2. 在屏幕左下角，點擊文件夾圖標。
3. 您需要為每個文件夾創建不同的位置。點擊 `create location` 按鈕。
4. 在菜單的右側，您可以重命名位置。給它一個合適的名字。
5. 接下來，將歌曲文件夾拖到遊戲窗口中。這樣遊戲會獲取此文件夾的路徑。
6. 點擊 `update` 並等待歌曲被新增。

> 新增歌曲後，您需要點擊屏幕右下角的 `collections` 按鈕，並在同一位置點擊 `notecharts` 按鈕以更新歌曲列表。這將在新版本的 UI 中得到修復。這也適用於以下方法。

## 將新歌曲新增到 soundsphere 文件夾
soundsphere 有自己的歌曲文件夾，您可以在其中放置任何格式的歌曲。此文件夾位於相對於遊戲根目錄的路徑：`userdata/charts/`。您應該在子文件夾中新增新歌曲。

1. 前往 `userdata/charts/`。
2. 創建一個文件夾，您將在此文件夾中放置歌曲。例如，路徑如下：`userdata/charts/cool_songs/`。
3. 在此文件夾中放置歌曲或包（包含歌曲的子文件夾）。
4. 進入遊戲，點擊屏幕左下角的文件夾圖標。
5. 確保選擇了 `soundsphere` 位置。點擊右側菜單中的 `update` 按鈕。

## 新增 `.osz` 歌曲
1. 將 `.osz` 拖到遊戲窗口中。
2. 完成。

## 下載連結
> 我們與以下列出的網站無任何聯繫。請自行承擔風險從這些網站下載文件。

在本節中，我們選取了一些網站，您可以輕鬆地從這些網站下載歌曲。
- [**osu.ppy.sh**](https://osu.ppy.sh/beatmapsets) `.osu` 格式。需要註冊。
- [**quavergame.com**](https://quavergame.com/maps) `.qua` 格式。需要通過 `Steam` 註冊。
- [**etternaonline.com**](https://etternaonline.com/packs) `.sm` 和 `.ssc` 格式。
- [**search.stepmaniaonline.net**](https://search.stepmaniaonline.net/) `.sm` 和 `.ssc` 格式。
