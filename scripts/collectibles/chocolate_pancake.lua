local ChocolatePancake = ty:DefineANewClass()

local function IsItemValid(pickup)
    if pickup:IsShopItem() and pickup.Type == EntityType.ENTITY_PICKUP and pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE and pickup.Touched == false then
        return true
    end
    return false
end

local function ReplaceItemPrice(pickup)
    pickup.ShopItemId = -3
    pickup.Price = PickupPrice.PRICE_FREE
    pickup.AutoUpdatePrice = false
    local sprite = pickup:GetPriceSprite()
    sprite:Load("gfx/items/shops/chocolate_pancake_deal.anm2", true)
    sprite:Play("Idle", true)
end

function ChocolatePancake:EvaluateCache(player, cacheFlag)
    if player:HasCollectible(ty.CustomCollectibles.CHOCOLATEPANCAKE) and player:HasCollectible(CollectibleType.COLLECTIBLE_BINGE_EATER) then
        local collectibleNum = player:GetCollectibleNum(ty.CustomCollectibles.CHOCOLATEPANCAKE)
        if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
            player.ShotSpeed = player.ShotSpeed + 0.2 * collectibleNum
        end
        if cacheFlag == CacheFlag.CACHE_SPEED then
            player.MoveSpeed = player.MoveSpeed - 0.03 * collectibleNum
        end
        if cacheFlag == CacheFlag.CACHE_LUCK then
            player.Luck = player.Luck + collectibleNum
        end
    end
end
ChocolatePancake:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, ChocolatePancake.EvaluateCache)

function ChocolatePancake:PostPickupUpdate(pickup)
    local pickup = pickup:ToPickup()
    local room = ty.GAME:GetRoom()
    if PlayerManager.AnyoneHasCollectible(ty.CustomCollectibles.CHOCOLATEPANCAKE) and room:GetType() ~= RoomType.ROOM_SHOP then
        if IsItemValid(pickup) and pickup:GetPriceSprite():GetFilename() ~= "gfx/items/shops/chocolate_pancake_deal.anm2" and pickup:GetPriceSprite():GetFilename() ~= "gfx/items/shops/broken_heart_deal.anm2" then
            ReplaceItemPrice(pickup)
        end
    else
        if IsItemValid(pickup) and pickup.ShopItemId == -3 and not pickup.AutoUpdatePrice and pickup.Price == PickupPrice.PRICE_FREE and pickup:GetPriceSprite():GetFilename() == "gfx/items/shops/chocolate_pancake_deal.anm2" then
            pickup.ShopItemId = -2
            pickup.AutoUpdatePrice = true
        end
    end
end
ChocolatePancake:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, ChocolatePancake.PostPickupUpdate, PickupVariant.PICKUP_COLLECTIBLE)

function ChocolatePancake:PostPickupShopPurchase(pickup, player, moneySpent)
    local pickup = pickup:ToPickup()
    if pickup.ShopItemId == -3 and moneySpent == PickupPrice.PRICE_FREE then
        if player:HasCollectible(ty.CustomCollectibles.CHOCOLATEPANCAKE) then
            player:RemoveCollectible(ty.CustomCollectibles.CHOCOLATEPANCAKE)
        else
            for _, player2 in pairs(PlayerManager.GetPlayers()) do
                if player2:HasCollectible(ty.CustomCollectibles.CHOCOLATEPANCAKE) then
                    player2:RemoveCollectible(ty.CustomCollectibles.CHOCOLATEPANCAKE)
                    break
                end
            end
        end
    end
end
ChocolatePancake:AddCallback(ModCallbacks.MC_POST_PICKUP_SHOP_PURCHASE, ChocolatePancake.PostPickupShopPurchase, PickupVariant.PICKUP_COLLECTIBLE)

return ChocolatePancake