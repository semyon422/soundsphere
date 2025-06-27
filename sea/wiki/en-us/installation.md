# Installing <%= brand.name %>
Installing the game takes just a few minutes. The game runs on Windows, Linux and MacOS immediately, without installing extra libraries and frameworks.
1. Go to [download page](/download)
2. On the left side of the screen, click on `Download for desktop`. The archive contains files to run on the above operating systems.
3. After downloading, you need to unzip the files to any convenient location. You do not need to install the game, you can run it immediately.

## Run on Windows
Simply run `game-win64.bat`.

## Run on Mac OS
After extracting the archive, open a terminal and run the command: `xattr -cr <%= brand.macos_app %>`.  
Then run `<%= brand.macos_app %>`.

## Run on Linux
There are two scripts to run the game: `game-appimage` and `game-linux`. We recommend using the **appimage** version.

Running via `game-linux` will require **love** (**love2d**) to be installed on the system.
