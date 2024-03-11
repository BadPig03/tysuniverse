local ChocolatePancake = ty:DefineANewClass()

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
    if PlayerManager.AnyoneHasCollectible(ty.CustomCollectibles.CHOCOLATEPANCAKE) then
        if pickup:IsShopItem() and not pickup.Touched and pickup:GetPriceSprite():GetFilename() ~= "gfx/items/shops/chocolate_pancake_deal.anm2" and pickup.ShopItemId ~= -16 and pickup.Price < 0 then
            pickup.ShopItemId = -3
            local sprite = pickup:GetPriceSprite()
            sprite:Load("gfx/items/shops/chocolate_pancake_deal.anm2", true)
            sprite:Play("Idle", true)
        end
    else
        if pickup:IsShopItem() and not pickup.Touched and pickup.ShopItemId == -3 and pickup.Price == PickupPrice.PRICE_FREE and pickup:GetPriceSprite():GetFilename() == "gfx/items/shops/chocolate_pancake_deal.anm2" then
            pickup.ShopItemId = -2
            pickup.AutoUpdatePrice = true
        end
    end
end
ChocolatePancake:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, ChocolatePancake.PostPickupUpdate, PickupVariant.PICKUP_COLLECTIBLE)

function ChocolatePancake:GetShopItemPrice(variant, subType, shopItemId, price)
    if shopItemId == -3 then
        return PickupPrice.PRICE_FREE
    end
end
ChocolatePancake:AddCallback(ModCallbacks.MC_GET_SHOP_ITEM_PRICE, ChocolatePancake.GetShopItemPrice, PickupVariant.PICKUP_COLLECTIBLE)

local pickedUp = false

function ChocolatePancake:PostPickupShopPurchase(pickup, player, moneySpent)
    local pickup = pickup:ToPickup()
    if pickup.ShopItemId == -3 and (moneySpent == PickupPrice.PRICE_FREE or pickedUp) then
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

function ChocolatePancake:PrePickupCollision(pickup, collider, low)
    local player = collider:ToPlayer()
    local pickup = pickup:ToPickup()
    if player and (player:GetPlayerType() == PlayerType.PLAYER_THESOUL or player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B or player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN_B) and pickup.ShopItemId == -3 and player:CanPickupItem() then
        pickedUp = true
    end
end
ChocolatePancake:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, ChocolatePancake.PrePickupCollision, PickupVariant.PICKUP_COLLECTIBLE)

function ChocolatePancake:PrePlayerAddHearts(player, amount, addHealthType, _)
    if pickedUp and amount < 0 and addHealthType & AddHealthType.SOUL == AddHealthType.SOUL and (player:GetPlayerType() == PlayerType.PLAYER_THESOUL or player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN_B) then
        return 0
    end
end
ChocolatePancake:AddCallback(ModCallbacks.MC_PRE_PLAYER_ADD_HEARTS, ChocolatePancake.PrePlayerAddHearts)

return ChocolatePancake