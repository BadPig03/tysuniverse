local ExpiredGlue = ty:DefineANewClass()

local function MorphTheCoin(pickup)
    local pickup = pickup:ToPickup()
    local data = ty.GLOBALDATA
    if not ty:IsValueInTable(pickup.InitSeed, data.ExpiredGlue) then
        table.insert(data.ExpiredGlue, pickup.InitSeed)
        if pickup.SubType ~= CoinSubType.COIN_STICKYNICKEL and pickup.SubType ~= ty.CustomEntities.CURSEDCOIN then
            pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_STICKYNICKEL, true, true, true)
        end    
    end
end

function ExpiredGlue:PostAddCollectible(type, charge, firstTime, slot, varData, player)
    if not PlayerManager.AnyoneHasCollectible(ty.CustomCollectibles.CURSEDTREASURE) then
        for _, ent in pairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN)) do
            MorphTheCoin(ent)
        end
    end
end
ExpiredGlue:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, ExpiredGlue.PostAddCollectible, ty.CustomCollectibles.EXPIREDGLUE)

function ExpiredGlue:PostPickupInit(pickup)
    if PlayerManager.AnyoneHasCollectible(ty.CustomCollectibles.EXPIREDGLUE) and not PlayerManager.AnyoneHasCollectible(ty.CustomCollectibles.CURSEDTREASURE) then
        MorphTheCoin(pickup)
    end
end
ExpiredGlue:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, ExpiredGlue.PostPickupInit, PickupVariant.PICKUP_COIN)

function ExpiredGlue:PostNewLevel()
    ty.GLOBALDATA.ExpiredGlue = {}
end
ExpiredGlue:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, ExpiredGlue.PostNewLevel)

return ExpiredGlue