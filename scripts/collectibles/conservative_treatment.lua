local ConservativeTreatment = ty:DefineANewClass()

local statInitValue = { 
    [1] = 1,
    [2] = 10,
    [3] = 3.5,
    [4] = 260,
    [5] = -23.75,
    [6] = 1,
    [7] = 0
}

function ConservativeTreatment:EvaluateCache(player, cacheFlag)
    if player:HasCollectible(ty.CustomCollectibles.CONSERVATIVETREATMENT) then
        if cacheFlag == CacheFlag.CACHE_SPEED and player.MoveSpeed < statInitValue[1] then
            player.MoveSpeed = statInitValue[1]
        end
        if cacheFlag == CacheFlag.CACHE_FIREDELAY then
            if 30 / (player.MaxFireDelay + 1) <= 30 / 11 then
                ty.Stat:AddTearsModifier(player, function(tears) return 30 / (statInitValue[2] + 1) end, -1)
            end
        end
        if cacheFlag == CacheFlag.CACHE_DAMAGE and player.Damage < statInitValue[3] then
            player.Damage = statInitValue[3]
        end
        if cacheFlag == CacheFlag.CACHE_RANGE and player.TearRange < statInitValue[4] then
            player.TearRange = statInitValue[4]
            player.TearHeight = statInitValue[5]
        end
        if cacheFlag == CacheFlag.CACHE_SHOTSPEED and player.ShotSpeed < statInitValue[6] then
            player.ShotSpeed = statInitValue[6]
        end
        if cacheFlag == CacheFlag.CACHE_LUCK and player.Luck < statInitValue[7] then
            player.Luck = statInitValue[7]
        end
    end
end
ConservativeTreatment:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, ConservativeTreatment.EvaluateCache)

return ConservativeTreatment