local ChocolatePancake = ty:DefineANewClass()

local stat = ty.Stat

function ChocolatePancake:EvaluateCache(player, cacheFlag)
    if player:HasCollectible(ty.CustomCollectibles.CHOCOLATEPANCAKE) and player:HasCollectible(CollectibleType.COLLECTIBLE_BINGE_EATER) then
        local collectibleNum = player:GetCollectibleNum(ty.CustomCollectibles.CHOCOLATEPANCAKE)
        if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
            player.ShotSpeed = player.ShotSpeed + 0.2 * collectibleNum
        end
        if cacheFlag == CacheFlag.CACHE_SPEED then
            stat:AddSpeedUp(player, -0.03 * collectibleNum)
        end
        if cacheFlag == CacheFlag.CACHE_LUCK then
            player.Luck = player.Luck + collectibleNum
        end
    end
end
ChocolatePancake:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, ChocolatePancake.EvaluateCache)

function ChocolatePancake:PostNPCDeath(npc)
    local npc = npc:ToNPC()
    local rng = npc:GetDropRNG()
    if PlayerManager.AnyoneHasCollectible(ty.CustomCollectibles.CHOCOLATEPANCAKE) and ((npc.SpawnerEntity == nil and rng:RandomInt(200) < 5) or (npc.SpawnerEntity and rng:RandomInt(100) < 1)) then
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_BLACK, npc.Position, Vector(0, 0), nil) 
    end
end
ChocolatePancake:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, ChocolatePancake.PostNPCDeath)

return ChocolatePancake