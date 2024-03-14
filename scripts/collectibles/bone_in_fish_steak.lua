local BoneInFishSteak = ty:DefineANewClass()

local function GetSmeltedTrinketCounts(player)
    local count = 0
    for trinket, v in pairs(player:GetSmeltedTrinkets()) do
        count = count + v.trinketAmount
        count = count + v.goldenTrinketAmount
    end
    return count
end

function BoneInFishSteak:EvaluateCache(player, cacheFlag)
	if player:HasCollectible(ty.CustomCollectibles.BONEINFISHSTEAK) then
        local data = ty:GetLibData(player)
		ty.Stat:AddTearsModifier(player, function(tears) return tears + 0.2 * data.BoneInFishSteak.TearsUp end)
	end
end
BoneInFishSteak:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, BoneInFishSteak.EvaluateCache, CacheFlag.CACHE_FIREDELAY)

function BoneInFishSteak:PostAddCollectible(type, charge, firstTime, slot, varData, player)
    local data = ty:GetLibData(player)
    if player:HasCollectible(ty.CustomCollectibles.BONEINFISHSTEAK) or type == ty.CustomCollectibles.BONEINFISHSTEAK then
        local item = ty.ITEMCONFIG:GetCollectible(type)
        if item and item:HasTags(ItemConfig.TAG_FOOD) then
            data.BoneInFishSteak.TearsUp = data.BoneInFishSteak.TearsUp + 1
            player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY, true)
        end
    end
    if type == ty.CustomCollectibles.BONEINFISHSTEAK and firstTime then
        data.BoneInFishSteak.TrinketsCount = GetSmeltedTrinketCounts(player)
    end
end
BoneInFishSteak:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, BoneInFishSteak.PostAddCollectible)

function BoneInFishSteak:PostPlayerUpdate(player)
    if player:HasCollectible(ty.CustomCollectibles.BONEINFISHSTEAK) then
        local data = ty:GetLibData(player)
        local trinketsCount = GetSmeltedTrinketCounts(player)
        if trinketsCount > data.BoneInFishSteak.TrinketsCount then
            data.BoneInFishSteak.TearsUp = data.BoneInFishSteak.TearsUp + trinketsCount - data.BoneInFishSteak.TrinketsCount
            data.BoneInFishSteak.TrinketsCount = trinketsCount
            player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY, true)
        end
    end
end
BoneInFishSteak:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, BoneInFishSteak.PostPlayerUpdate)

return BoneInFishSteak