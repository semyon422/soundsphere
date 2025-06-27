> 本页由 AI 翻译!!! 可能包含令人困惑的错误，但希望您仍然能够理解这里解释的内容。如果您害怕机器人，请阅读原始英文页面！

# 安装 <%= brand.name %>
安装游戏只需几分钟。游戏可以在 Windows、Linux 和 MacOS 上直接运行，无需安装额外的库和框架。
1. 前往 [下载页面](/download)
2. 在屏幕左侧，点击 `下载桌面版本`。该文件包含上述操作系统的运行文件。
3. 下载后，您需要将文件解压到任何方便的位置。您无需安装游戏，可以立即运行。

## 在 Windows 上运行
只需运行 `game-win64.bat`。

## 在 Mac OS 上运行
解压缩后，打开终端并运行命令： `xattr -cr <%= brand.macos_app %>`.  
然后运行 `<%= brand.macos_app %>`。

## 在 Linux 上运行
有两种脚本可以运行游戏：`game-appimage` 和 `game-linux`。我们推荐使用 **appimage** 版本。

通过 `game-linux` 运行需要系统已安装 **love** (**love2d**)。
