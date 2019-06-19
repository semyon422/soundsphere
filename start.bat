@echo off

if defined ProgramFiles(x86) (
	start /high aqua\bin64\love.exe .
) else (
	start /high aqua\bin32\love.exe .
)
