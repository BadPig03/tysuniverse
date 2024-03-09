local AbsenceNote = ty:DefineANewClass()

function AbsenceNote:PreAddCollectible(type, charge, firstTime, slot, varData, player)
    return false
end
AbsenceNote:AddCallback(ModCallbacks.MC_PRE_ADD_COLLECTIBLE, AbsenceNote.PreAddCollectible, ty.CustomCollectibles.ABSENCENOTE)

return AbsenceNote