local PeeledBanana = ty:DefineANewClass()

function PeeledBanana:PostNewRoom()
    local room = ty.GAME:GetRoom()
    if room:IsFirstVisit() then
        for _, player in pairs(PlayerManager.GetPlayers()) do
            if player:HasCollectible(ty.CustomCollectibles.PEELEDBANANA) then
                local rng = player:GetCollectibleRNG(ty.CustomCollectibles.PEELEDBANANA)
                if rng:RandomInt(100) < 25 * player:GetCollectibleNum(ty.CustomCollectibles.PEELEDBANANA) then
                    player:AddHearts(1)
                end
            end
        end    
    end
end
PeeledBanana:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, PeeledBanana.PostNewRoom)

function PeeledBanana:EvaluateCache(player, cacheFlag)
    if player:HasCollectible(ty.CustomCollectibles.PEELEDBANANA) and player:HasCollectible(CollectibleType.COLLECTIBLE_BINGE_EATER) then
        local collectibleNum = player:GetCollectibleNum(ty.CustomCollectibles.PEELEDBANANA)
        if cacheFlag == CacheFlag.CACHE_RANGE then
            player.TearRange = player.TearRange + 100 * collectibleNum
        end
        if cacheFlag == CacheFlag.CACHE_SPEED then
            ty.Stat:AddSpeed(player, -0.03 * collectibleNum)
        end
        if cacheFlag == CacheFlag.CACHE_LUCK then
            player.Luck = player.Luck + collectibleNum
        end
    end
end
PeeledBanana:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, PeeledBanana.EvaluateCache)

return PeeledBanana