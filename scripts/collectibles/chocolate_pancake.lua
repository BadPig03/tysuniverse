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
    if PlayerManager.AnyoneHasCollectible(ty.CustomCollectibles.CHOCOLATEPANCAKE) then
        if not ty:IsValueInTable(pickup.InitSeed, ty.GLOBALDATA.ChocolatePancake) and pickup:IsShopItem() and pickup:GetAlternatePedestal() == -1 and not pickup.Touched and pickup.Price < 0 and pickup.Price ~= PickupPrice.PRICE_FREE then
            pickup.AutoUpdatePrice = false
            pickup.Price = PickupPrice.PRICE_FREE
            table.insert(ty.GLOBALDATA.ChocolatePancake, pickup.InitSeed)
        end
        if ty:IsValueInTable(pickup.InitSeed, ty.GLOBALDATA.ChocolatePancake) then
            local sprite = pickup:GetPriceSprite()
            if sprite:GetFilename() ~= "gfx/items/shops/chocolate_pancake_deal.anm2" then
                sprite:Load("gfx/items/shops/chocolate_pancake_deal.anm2", true)
                sprite:Play("Idle", true)
            end
            if pickup.Price ~= PickupPrice.PRICE_FREE then
                pickup.AutoUpdatePrice = false
                pickup.Price = PickupPrice.PRICE_FREE
            end
        end
    else
        if ty:IsValueInTable(pickup.InitSeed, ty.GLOBALDATA.ChocolatePancake) and pickup:IsShopItem() and not pickup.Touched and pickup.Price == PickupPrice.PRICE_FREE and pickup:GetPriceSprite():GetFilename() == "gfx/items/shops/chocolate_pancake_deal.anm2" then
            pickup.AutoUpdatePrice = true
            ty:RemoveValueInTable(pickup.InitSeed, ty.GLOBALDATA.ChocolatePancake)
        end
    end
end
ChocolatePancake:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, ChocolatePancake.PostPickupUpdate, PickupVariant.PICKUP_COLLECTIBLE)

function ChocolatePancake:PostPickupShopPurchase(pickup, player, moneySpent)
    local pickup = pickup:ToPickup()
    if ty:IsValueInTable(pickup.InitSeed, ty.GLOBALDATA.ChocolatePancake) then
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

function ChocolatePancake:PostNewLevel()
    ty.GLOBALDATA.ChocolatePancake = {}
end
ChocolatePancake:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, ChocolatePancake.PostNewLevel)

return ChocolatePancake