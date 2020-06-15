@echo off

if defined ProgramFiles(x86) (
	start /high aqua\love-11.3-win64\love.exe .
) else (
	start /high aqua\love-11.3-win64\love.exe .
)