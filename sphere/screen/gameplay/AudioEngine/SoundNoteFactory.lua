local SoundNote	        = require("sphere.screen.gameplay.AudioEngine.SoundNote")
local ShortSoundNote	= require("sphere.screen.gameplay.AudioEngine.ShortSoundNote")
local LongSoundNote		= require("sphere.screen.gameplay.AudioEngine.LongSoundNote")

local SoundNoteFactory = {}

SoundNoteFactory.getNote = function(self, logicalNote)
    local soundNote = {logicalNote = logicalNote}
    if logicalNote.noteClass == "ShortLogicalNote" then
        return ShortSoundNote:new(soundNote)
    elseif logicalNote.noteClass == "LongLogicalNote" then
        return LongSoundNote:new(soundNote)
    elseif logicalNote.noteClass == "LaserLogicalNote" then
        return LongSoundNote:new(soundNote)
    end
    return SoundNote:new(soundNote)
end

return SoundNoteFactory
