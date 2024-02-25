local PhilosophersStaff = ty:DefineANewClass()

function PhilosophersStaff:UseItem(itemID, rng, player, useFlags, activeSlot, varData)
    local room = ty.GAME:GetRoom()
    local flag = false
    if useFlags & UseFlag.USE_CARBATTERY == UseFlag.USE_CARBATTERY then
        return { Discharge = false, Remove = false, ShowAnim = false }
    end
    for i = player:GetMaxTrinkets() - 1, 0, -1 do
        local trinket = player:GetTrinket(i)
        if trinket > 0 then
            player:TryRemoveTrinket(trinket)
            flag = true
            for i = 1, 3 + rng:RandomInt(5) do
                local subType = CoinSubType.COIN_PENNY
                if rng:RandomInt(100) < 10 then
                    subType = rng:RandomInt(CoinSubType.COIN_NICKEL, CoinSubType.COIN_GOLDEN + 1)
                end
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, subType, room:FindFreePickupSpawnPosition(player.Position, 0, true), Vector(0, 0), nil)
            end
        end
    end
    if flag then
        ty.SFXMANAGER:Play(SoundEffect.SOUND_GOLD_HEART)
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CRACKED_ORB_POOF, 0, player.Position, Vector(0, 0), nil)
        local crater = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BOMB_CRATER, 0, player.Position, Vector(0, 0), nil)
        crater:GetSprite().Color:SetColorize(6,4.5,0.2,2)
        ty.GAME:SpawnParticles(player.Position, EffectVariant.COIN_PARTICLE, 25, 7)
        if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
            player:AddWisp(CollectibleType.COLLECTIBLE_GOLDEN_RAZOR, player.Position, true)
        end
        if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL_PASSIVE) then
            for i = 1, 3 do
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, rng:RandomInt(CoinSubType.COIN_PENNY, CoinSubType.COIN_GOLDEN), room:FindFreePickupSpawnPosition(player.Position, 0, true), Vector(0, 0), nil)
            end
        end
    end
    return { Discharge = flag, Remove = false, ShowAnim = true }
end
PhilosophersStaff:AddCallback(ModCallbacks.MC_USE_ITEM, PhilosophersStaff.UseItem, ty.CustomCollectibles.PHILOSOPHERSSTAFF)

function PhilosophersStaff:PostPlayerUpdate(player)
    if player:HasCollectible(ty.CustomCollectibles.PHILOSOPHERSSTAFF) then
        for i = 0, player:GetMaxTrinkets() do
            local trinket = player:GetTrinket(i)
            if trinket > 0 and trinket & TrinketType.TRINKET_GOLDEN_FLAG ~= TrinketType.TRINKET_GOLDEN_FLAG then
                player:TryRemoveTrinket(trinket)
                player:AddTrinket(trinket | TrinketType.TRINKET_GOLDEN_FLAG)
            end
        end
    end
end
PhilosophersStaff:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, PhilosophersStaff.PostPlayerUpdate)

function PhilosophersStaff:PostNPCDeath(npc)
    local npc = npc:ToNPC()
    if PlayerManager.AnyoneHasCollectible(ty.CustomCollectibles.PHILOSOPHERSSTAFF) and npc:GetDropRNG():RandomInt(100) < 4 then
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, 0, npc.Position, Vector(0, 0), nil) 
    end
end
PhilosophersStaff:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, PhilosophersStaff.PostNPCDeath)

return PhilosophersStaff