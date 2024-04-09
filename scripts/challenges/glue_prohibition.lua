local GlueProhibition = ty:DefineANewClass()

function GlueProhibition:GetShopItemPrice(variant, subType, itemID, price)
    if Isaac.GetChallenge() == ty.CustomChallenges.GLUEPROHIBITION then
        return math.min(99, price * 2)
    end
end
GlueProhibition:AddCallback(ModCallbacks.MC_GET_SHOP_ITEM_PRICE, GlueProhibition.GetShopItemPrice)

function GlueProhibition:PostPickupUpdate(pickup)
    local pickup = pickup:ToPickup()
    if Isaac.GetChallenge() == ty.CustomChallenges.GLUEPROHIBITION and not PlayerManager.AnyoneHasCollectible(ty.CustomCollectibles.CURSEDTREASURE) and pickup.FrameCount % 6 == 0 and not pickup:GetSprite():IsPlaying("Collect") then
        local rng = pickup:GetDropRNG()
        if (pickup.SubType ~= CoinSubType.COIN_STICKYNICKEL and pickup.SubType ~= ty.CustomEntities.CURSEDCOIN and pickup.SubType ~= CoinSubType.COIN_NICKEL) or (pickup.SubType == CoinSubType.COIN_NICKEL and rng:RandomFloat() < 0.02) then
            local newPickup = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_STICKYNICKEL, pickup.Position, pickup.Velocity, nil):ToPickup()
            newPickup.OptionsPickupIndex = pickup.OptionsPickupIndex
            pickup:Remove()
        end
    end
end
GlueProhibition:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, GlueProhibition.PostPickupUpdate, PickupVariant.PICKUP_COIN)

return GlueProhibition