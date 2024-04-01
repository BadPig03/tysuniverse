local TheGospelOfJohn = ty:DefineANewClass()

local function GetAngelRoomCollectible(rng)
    local itemID
    repeat
        for i = 1, ty.ITEMCONFIG:GetCollectibles().Size - 1 do
            if ItemConfig.Config.IsValidCollectible(i) and ty.ITEMCONFIG:GetCollectible(i).Quality < 3 then
                ty.ITEMPOOL:AddRoomBlacklist(i)
            end
        end
        itemID = ty.ITEMPOOL:GetCollectible(ItemPoolType.POOL_ANGEL, false, rng:Next(), CollectibleType.COLLECTIBLE_SERAPHIM)
    until ty.ITEMCONFIG:GetCollectible(itemID).Quality >= 3
    ty.ITEMPOOL:RemoveCollectible(itemID)
    ty.ITEMPOOL:ResetRoomBlacklist()
    return itemID
end

local function MorphAllCollectibles(rng, flag)
    for _, ent in pairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)) do
        local pickup = ent:ToPickup()
        if pickup.SubType > 0 and pickup.SubType ~= CollectibleType.COLLECTIBLE_DADS_NOTE then
            local newItem = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, GetAngelRoomCollectible(rng), pickup.Position, Vector(0, 0), nil):ToPickup()
            newItem:MakeShopItem(pickup.ShopItemId)
            newItem:RemoveCollectibleCycle()
            newItem.AutoUpdatePrice = false
            if flag then
                newItem.Price = math.floor(ty.ITEMCONFIG:GetCollectible(newItem.SubType).ShopPrice * 1.5)
                table.insert(ty.GLOBALDATA.TheGospelOfJohn.Money, newItem.InitSeed)
            else
                newItem.Price = PickupPrice.PRICE_FREE
                table.insert(ty.GLOBALDATA.TheGospelOfJohn.BrokenHeart, newItem.InitSeed)
            end
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, newItem.Position, Vector(0, 0), nil)
            pickup:Remove()
        end
    end
end

function TheGospelOfJohn:UseItem(itemID, rng, player, useFlags, activeSlot, varData)
    if useFlags & UseFlag.USE_CARBATTERY == UseFlag.USE_CARBATTERY then
        player:AddBrokenHearts(-1)
        return { Discharge = false, Remove = false, ShowAnim = false }
    end
    if useFlags & UseFlag.USE_VOID ~= UseFlag.USE_VOID then
        ItemOverlay.Show(ty.CustomGiantBooks.THEGOSPELOFJOHN, 3, player)
    end
    player:AddBrokenHearts(-1)
    MorphAllCollectibles(rng, PlayerManager.AnyoneIsPlayerType(PlayerType.PLAYER_KEEPER) or PlayerManager.AnyoneIsPlayerType(PlayerType.PLAYER_KEEPER_B))
    if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
        player:AddItemWisp(ty.ITEMPOOL:GetCollectible(ItemPoolType.POOL_ANGEL, false), player.Position, true)
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL_PASSIVE) then
        player:AddItemWisp(ty.ITEMPOOL:GetCollectible(ItemPoolType.POOL_DEVIL, false), player.Position, true)
    end
    return { Discharge = true, Remove = false, ShowAnim = true }
end
TheGospelOfJohn:AddCallback(ModCallbacks.MC_USE_ITEM, TheGospelOfJohn.UseItem, ty.CustomCollectibles.THEGOSPELOFJOHN)

function TheGospelOfJohn:PostPickupUpdate(pickup)
    local pickup = pickup:ToPickup()
    if ty.GLOBALDATA.TheGospelOfJohn and ty:IsValueInTable(pickup.InitSeed, ty.GLOBALDATA.TheGospelOfJohn.BrokenHeart) and pickup:IsShopItem() and pickup:GetAlternatePedestal() == -1 and not pickup.Touched then
        local sprite = pickup:GetPriceSprite()
        if sprite:GetFilename() ~= "gfx/items/shops/broken_heart_deal.anm2" then
            sprite:Load("gfx/items/shops/broken_heart_deal.anm2", true)
            sprite:SetFrame("Hearts", ty.ITEMCONFIG:GetCollectible(pickup.SubType).Quality - 2)
        end
        if #pickup:GetCollectibleCycle() > 0 then
            pickup:RemoveCollectibleCycle()
        end
        if pickup.Price ~= PickupPrice.PRICE_FREE then
            pickup.AutoUpdatePrice = false
            pickup.Price = PickupPrice.PRICE_FREE
        end
    end
end
TheGospelOfJohn:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, TheGospelOfJohn.PostPickupUpdate, PickupVariant.PICKUP_COLLECTIBLE)

function TheGospelOfJohn:PostPickupShopPurchase(pickup, player, moneySpent)
    local pickup = pickup:ToPickup()
    if ty:IsValueInTable(pickup.InitSeed, ty.GLOBALDATA.TheGospelOfJohn.BrokenHeart) then
        player:AddBrokenHearts(player.QueuedItem.Item.Quality - 1)
        ty:RemoveValueInTable(pickup.InitSeed, ty.GLOBALDATA.TheGospelOfJohn.BrokenHeart)
    end
    if ty:IsValueInTable(pickup.InitSeed, ty.GLOBALDATA.TheGospelOfJohn.Money) then
        ty:RemoveValueInTable(pickup.InitSeed, ty.GLOBALDATA.TheGospelOfJohn.Money)
    end
end
TheGospelOfJohn:AddCallback(ModCallbacks.MC_POST_PICKUP_SHOP_PURCHASE, TheGospelOfJohn.PostPickupShopPurchase, PickupVariant.PICKUP_COLLECTIBLE)

function TheGospelOfJohn:PrePickupMorph(pickup, type, variant, subType, keepPrice, keepSeed, ignoreModifiers)
    if pickup:IsShopItem() and (ty:IsValueInTable(pickup.InitSeed, ty.GLOBALDATA.TheGospelOfJohn.BrokenHeart) or ty:IsValueInTable(pickup.InitSeed, ty.GLOBALDATA.TheGospelOfJohn.Money)) and keepPrice and not keepSeed and not ignoreModifiers then
        return false
    end
end
TheGospelOfJohn:AddCallback(ModCallbacks.MC_PRE_PICKUP_MORPH, TheGospelOfJohn.PrePickupMorph)

function TheGospelOfJohn:PostNewLevel()
    if ty.GLOBALDATA.TheGospelOfJohn then
        ty.GLOBALDATA.TheGospelOfJohn.Money = {}
        ty.GLOBALDATA.TheGospelOfJohn.BrokenHeart = {}    
    end
end
TheGospelOfJohn:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, TheGospelOfJohn.PostNewLevel)

return TheGospelOfJohn