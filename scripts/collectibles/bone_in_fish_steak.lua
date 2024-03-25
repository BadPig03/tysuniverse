local BoneInFishSteak = ty:DefineANewClass()

local function GetSmeltedTrinketCounts(player)
    local count = 0
    for trinket, v in pairs(player:GetSmeltedTrinkets()) do
        count = count + v.trinketAmount
        count = count + v.goldenTrinketAmount
    end
    return count
end

function BoneInFishSteak:PostAddCollectible(type, charge, firstTime, slot, varData, player)
    local data = ty:GetLibData(player)
    if player:HasCollectible(ty.CustomCollectibles.BONEINFISHSTEAK) or type == ty.CustomCollectibles.BONEINFISHSTEAK then
        local item = ty.ITEMCONFIG:GetCollectible(type)
        if item and item:HasTags(ItemConfig.TAG_FOOD) then
            data.BoneInFishSteak.TearsUp = data.BoneInFishSteak.TearsUp + 1
            player:TakeDamage(1, DamageFlag.DAMAGE_RED_HEARTS | DamageFlag.DAMAGE_FAKE, EntityRef(player), 15)
            player:StopExtraAnimation()
            player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY, true)
        end
    end
    if type == ty.CustomCollectibles.BONEINFISHSTEAK and firstTime then
        data.BoneInFishSteak.TrinketsCount = GetSmeltedTrinketCounts(player)
    end
end
BoneInFishSteak:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, BoneInFishSteak.PostAddCollectible)

function BoneInFishSteak:PostPlayerUpdate(player)
    local data = ty:GetLibData(player)
    if data.Init and player:HasCollectible(ty.CustomCollectibles.BONEINFISHSTEAK) then
        local trinketsCount = GetSmeltedTrinketCounts(player)
        if trinketsCount > data.BoneInFishSteak.TrinketsCount then
            data.BoneInFishSteak.TearsUp = data.BoneInFishSteak.TearsUp + trinketsCount - data.BoneInFishSteak.TrinketsCount
            data.BoneInFishSteak.TrinketsCount = trinketsCount
            player:TakeDamage(1, DamageFlag.DAMAGE_RED_HEARTS | DamageFlag.DAMAGE_FAKE, EntityRef(player), 15)
            player:StopExtraAnimation()
            player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY, true)
        end
    end
end
BoneInFishSteak:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, BoneInFishSteak.PostPlayerUpdate)

function BoneInFishSteak:EvaluateCache(player, cacheFlag)
    if player:HasCollectible(ty.CustomCollectibles.BONEINFISHSTEAK) then
        if player:HasCollectible(CollectibleType.COLLECTIBLE_BINGE_EATER) then
            local collectibleNum = player:GetCollectibleNum(ty.CustomCollectibles.BONEINFISHSTEAK)
            if cacheFlag == CacheFlag.CACHE_SPEED then
                player.MoveSpeed = player.MoveSpeed - 0.03 * collectibleNum
            end
            if cacheFlag == CacheFlag.CACHE_DAMAGE then
                ty.Stat:AddFlatDamage(player, collectibleNum)
            end
            if cacheFlag == CacheFlag.CACHE_LUCK then
                player.Luck = player.Luck + collectibleNum
            end
        end
        if cacheFlag == CacheFlag.CACHE_FIREDELAY then
            local data = ty:GetLibData(player)
            ty.Stat:AddTearsModifier(player, function(tears) return tears + 0.2 * data.BoneInFishSteak.TearsUp end)
        end
    end
end
BoneInFishSteak:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, BoneInFishSteak.EvaluateCache)

return BoneInFishSteak