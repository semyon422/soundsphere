@echo off
call setpaths.bat
set PATH=%PATH%;bin/win64
luajit -e require('lapis.cmd.actions').execute({'server'})
pause