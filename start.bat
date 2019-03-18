@echo off

if defined ProgramFiles(x86) (
	aqua\bin64\love.exe .
) else (
	aqua\bin32\love.exe .
)