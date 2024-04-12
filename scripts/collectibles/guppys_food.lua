local GuppysFood = ty:DefineANewClass()

local stat = ty.Stat

function GuppysFood:EvaluateCache(player, cacheFlag)
    if player:HasCollectible(ty.CustomCollectibles.GUPPYSFOOD) and player:HasCollectible(CollectibleType.COLLECTIBLE_BINGE_EATER) then
        local collectibleNum = player:GetCollectibleNum(ty.CustomCollectibles.GUPPYSFOOD)
        if cacheFlag == CacheFlag.CACHE_DAMAGE then
            stat:AddFlatDamage(player, collectibleNum)
        end
        if cacheFlag == CacheFlag.CACHE_SPEED then
            stat:AddSpeedUp(player, -0.03 * collectibleNum)
        end
        if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
            player.ShotSpeed = player.ShotSpeed + collectibleNum * 0.2
        end
    end
end
GuppysFood:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, GuppysFood.EvaluateCache)

return GuppysFood