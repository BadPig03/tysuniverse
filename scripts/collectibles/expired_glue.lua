local ExpiredGlue = ty:DefineANewClass()

function ExpiredGlue:PostPickupUpdate(pickup)
    local pickup = pickup:ToPickup()
    if PlayerManager.AnyoneHasCollectible(ty.CustomCollectibles.EXPIREDGLUE) and not PlayerManager.AnyoneHasCollectible(ty.CustomCollectibles.CURSEDTREASURE) and pickup.FrameCount % 6 == 0 then
        local rng = pickup:GetDropRNG()
        if (pickup.SubType ~= CoinSubType.COIN_STICKYNICKEL and pickup.SubType ~= ty.CustomEntities.CURSEDCOIN and rng:RandomFloat() < 0.02) or (pickup.SubType == CoinSubType.COIN_NICKEL and rng:RandomFloat() < 0.04) then
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_STICKYNICKEL, pickup.Position, pickup.Velocity, nil)
            pickup:Remove()
        end
    end
end
ExpiredGlue:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, ExpiredGlue.PostPickupUpdate, PickupVariant.PICKUP_COIN)

return ExpiredGlue