local BaitAndSwitch = ty:DefineANewClass()

local functions = ty.Functions

function BaitAndSwitch:UsePill(pillEffect, player, useFlags, pillColor)
    if pillColor & PillColor.PILL_GIANT_FLAG == PillColor.PILL_GIANT_FLAG then
        functions:AddPlayerShield(player, 60)
    end
    player:TeleportToRandomPosition()
    ty.SFXMANAGER:Play(SoundEffect.SOUND_HELL_PORTAL2)
    functions:AddPlayerShield(player, 60)
end
BaitAndSwitch:AddCallback(ModCallbacks.MC_USE_PILL, BaitAndSwitch.UsePill, ty.CustomPills.BAITANDSWITCH)

return BaitAndSwitch