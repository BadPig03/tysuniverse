local PlanetariumTelescope = ty:DefineANewClass()

local stat = ty.Stat

local function GetAvarageLuck()
    local luck = 0
    for _, player in pairs(PlayerManager.GetPlayers()) do
        luck = luck + player.Luck
    end
    return luck / #PlayerManager.GetPlayers()
end

local function GetStarsItemsCount(player)
    local count = 0
    for itemID, itemCount in pairs(player:GetCollectiblesList()) do
        if ItemConfig.Config.IsValidCollectible(itemID) and ty.ITEMCONFIG:GetCollectible(itemID):HasTags(ItemConfig.TAG_STARS) then
            count = count + itemCount
        end
    end
    return count
end

function PlanetariumTelescope:EvaluateCache(player, cacheFlag)
    if player:HasCollectible(ty.CustomCollectibles.PLANETARIUMTELESCOPE) then
        player.Luck = player.Luck + 2 * GetStarsItemsCount(player)
    end
end
PlanetariumTelescope:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, PlanetariumTelescope.EvaluateCache, CacheFlag.CACHE_LUCK)

function PlanetariumTelescope:PrePlanetariumApplyStagePenalty()
    local stage = ty.LEVEL:GetAbsoluteStage()
    if PlayerManager.AnyoneHasCollectible(ty.CustomCollectibles.PLANETARIUMTELESCOPE) and stage ~= LevelStage.STAGE4_3 and stage ~= LevelStage.STAGE8 then
        return false
    end
end
PlanetariumTelescope:AddCallback(ModCallbacks.MC_PRE_PLANETARIUM_APPLY_STAGE_PENALTY, PlanetariumTelescope.PrePlanetariumApplyStagePenalty)

function PlanetariumTelescope:PrePlanetariumApplyTelescopeLens(chance)
    if PlayerManager.AnyoneHasCollectible(ty.CustomCollectibles.PLANETARIUMTELESCOPE) then
        return chance + math.min(0.5, math.max(0, GetAvarageLuck() / 12))
    end
end
PlanetariumTelescope:AddCallback(ModCallbacks.MC_PRE_PLANETARIUM_APPLY_TELESCOPE_LENS, PlanetariumTelescope.PrePlanetariumApplyTelescopeLens)

function PlanetariumTelescope:PostPickupUpdate(pickup)
    local pickup = pickup:ToPickup()
    local room = ty.GAME:GetRoom()
    if PlayerManager.AnyoneHasCollectible(ty.CustomCollectibles.PLANETARIUMTELESCOPE) and room:GetType() == RoomType.ROOM_PLANETARIUM then
        if pickup.OptionsPickupIndex ~= 0 then
            pickup.OptionsPickupIndex = 0
        end
    end
end
PlanetariumTelescope:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, PlanetariumTelescope.PostPickupUpdate, PickupVariant.PICKUP_COLLECTIBLE)

function PlanetariumTelescope:PostAddCollectible(type, charge, firstTime, slot, varData, player)
    local room = ty.GAME:GetRoom()
    if type == ty.CustomCollectibles.PLANETARIUMTELESCOPE and firstTime then
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_STARS, room:FindFreePickupSpawnPosition(player.Position, 0, true), Vector(0, 0), nil)
    end
    if ty.ITEMCONFIG:GetCollectible(type):HasTags(ItemConfig.TAG_STARS) then
        player:AddCacheFlags(CacheFlag.CACHE_LUCK, true)
    end
end
PlanetariumTelescope:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, PlanetariumTelescope.PostAddCollectible)

return PlanetariumTelescope