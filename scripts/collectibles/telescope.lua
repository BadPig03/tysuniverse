local Telescope = ty:DefineANewClass()

local function GetAvarageLuck()
    local luck = 0
    for _, player in pairs(PlayerManager.GetPlayers()) do
        luck = luck + player.Luck
    end
    return luck / #PlayerManager.GetPlayers()
end

local function GetStarsItemsCount(player)
    local collectibleList = 1
    local count = 0
    for itemID, itemCount in pairs(player:GetCollectiblesList()) do
        if ItemConfig.Config.IsValidCollectible(itemID) and ty.ITEMCONFIG:GetCollectible(itemID):HasTags(ItemConfig.TAG_STARS) then
            count = count + itemCount
        end
    end
    return count
end

function Telescope:EvaluateCache(player, cacheFlag)
    if player:HasCollectible(ty.CustomCollectibles.TELESCOPE) then
        local num = GetStarsItemsCount(player)
        if cacheFlag == CacheFlag.CACHE_LUCK then
            player.Luck = player.Luck + 2 * num
        end
        if cacheFlag == CacheFlag.CACHE_FIREDELAY then
            ty.Stat:AddTearsModifier(player, function(tears) return tears + 0.25 * num end)
        end
    end
end
Telescope:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Telescope.EvaluateCache)

function Telescope:PrePlanetariumApplyStagePenalty()
    if PlayerManager.AnyoneHasCollectible(ty.CustomCollectibles.TELESCOPE) and ty.LEVEL:GetAbsoluteStage() ~= LevelStage.STAGE4_3 then
        return false
    end
end
Telescope:AddCallback(ModCallbacks.MC_PRE_PLANETARIUM_APPLY_STAGE_PENALTY, Telescope.PrePlanetariumApplyStagePenalty)

function Telescope:PostPlanetariumCalculate(chance)
    if PlayerManager.AnyoneHasCollectible(ty.CustomCollectibles.TELESCOPE) then
        return math.max(0, GetAvarageLuck() / 24)
    end
end
Telescope:AddCallback(ModCallbacks.MC_POST_PLANETARIUM_CALCULATE, Telescope.PostPlanetariumCalculate)

function Telescope:PostPickupUpdate(pickup)
    local pickup = pickup:ToPickup()
    if PlayerManager.AnyoneHasCollectible(ty.CustomCollectibles.TELESCOPE) and ty.GAME:GetRoom():GetType() == RoomType.ROOM_PLANETARIUM then
        if pickup.OptionsPickupIndex ~= 0 then
            pickup.OptionsPickupIndex = 0
        end
    end
end
Telescope:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, Telescope.PostPickupUpdate, PickupVariant.PICKUP_COLLECTIBLE)

function Telescope:PostAddCollectible(type, charge, firstTime, slot, varData, player)
    if firstTime then
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_STARS, ty.GAME:GetRoom():FindFreePickupSpawnPosition(player.Position, 0, true), Vector(0, 0), nil)
    end
end
Telescope:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, Telescope.PostAddCollectible, ty.CustomCollectibles.TELESCOPE)

return Telescope