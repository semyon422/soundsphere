# Adding skins
soundsphere supports **osu!** skins and adding them to the game is quite easy. 

First you need to find your favorite **osu!** skin on the internet and download it. Downloaded skins can be in two formats: `.zip` and `.osk`. You will need to unzip the files from these archives into the folder. `.osk` is actually a `.zip` archive, and is extracted in the same way as `.zip`.  

You should end up with a hierarchy of files like this:  
```
skin_folder/
├── skin.ini
├── image1.png
├── image2.png
├── another_folder/
```

The `skin.ini` file should be in the root of the folder.

## Installing skins
1. Go to the folder with soundsphere installed.
2. Go to the `userdata/skins/` folder.
3. Put the unzipped skin into it.
4. Restart the game if it was running during the skin installation.

## Select a skin in the game
> IMPORTANT NOTE: For each game mode you need to select a different skin! For example: you need to select a skin for 4K and 7K separately.
1. In the song selection menu, you need to click on the `skins` button on the bottom panel.
2. Find the installed skin by name and select it.

## Customizing the skin
You can change some skin settings in the game in the skin menu on the right side of the screen.

For more advanced skin customization, go to [osu! skin wiki](https://osu.ppy.sh/wiki/en/Skinning).

## Lua skins
> We do not recommend using Lua skins as they may contain malicious code.  

Lua skins are an advanced skin format that can add new elements to the screen. They are installed exactly as **osu!** skins are installed.  
