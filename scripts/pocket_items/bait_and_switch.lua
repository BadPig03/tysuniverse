local BaitAndSwitch = ty:DefineANewClass()

local function AddShield(player, time)
    local effects = player:GetEffects()
    local effect = effects:GetCollectibleEffect(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS)
    if not effect then
        effects:AddCollectibleEffect(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS)
        effect = effects:GetCollectibleEffect(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS)
        effect.Cooldown = 0
    end
    effect.Cooldown = (effect.Cooldown or 0) + time
end

function BaitAndSwitch:UsePill(pillEffect, player, useFlags, pillColor)
    if pillColor & PillColor.PILL_GIANT_FLAG == PillColor.PILL_GIANT_FLAG then
        AddShield(player, 30)
    end
    player:TeleportToRandomPosition()
    ty.SFXMANAGER:Play(SoundEffect.SOUND_HELL_PORTAL2)
    AddShield(player, 30)
end
BaitAndSwitch:AddCallback(ModCallbacks.MC_USE_PILL, BaitAndSwitch.UsePill, ty.CustomPills.BAITANDSWITCH)

return BaitAndSwitch