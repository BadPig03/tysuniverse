local StrangeSyringe = ty:DefineANewClass()

function StrangeSyringe:UseItem(itemID, rng, player, useFlags, activeSlot, varData)
    if useFlags & UseFlag.USE_CARBATTERY == UseFlag.USE_CARBATTERY then
        return { Discharge = false, Remove = false, ShowAnim = false }
    end
    player:TakeDamage(rng:Next() % 6, DamageFlag.DAMAGE_SPIKES | DamageFlag.DAMAGE_INVINCIBLE | DamageFlag.DAMAGE_NO_MODIFIERS | DamageFlag.DAMAGE_NO_PENALTIES, EntityRef(player), 30)
    player:IncrementPlayerFormCounter(PlayerForm.PLAYERFORM_DRUGS, 3)
    if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
        player:IncrementPlayerFormCounter(PlayerForm.PLAYERFORM_ANGEL, 1)
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL_PASSIVE) then
        player:IncrementPlayerFormCounter(PlayerForm.PLAYERFORM_EVIL_ANGEL, 1)
    end
    return { Discharge = true, Remove = true, ShowAnim = true }
end
StrangeSyringe:AddCallback(ModCallbacks.MC_USE_ITEM, StrangeSyringe.UseItem, ty.CustomCollectibles.STRANGESYRINGE)

return StrangeSyringe