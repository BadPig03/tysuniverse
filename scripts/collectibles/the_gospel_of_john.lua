local TheGospelOfJohn = ty:DefineANewClass()

local pickedUp = false

local function GetAngelRoomCollectible(rng)
	for itemID = 1, ty.ITEMCONFIG:GetCollectibles().Size - 1 do
		if ItemConfig.Config.IsValidCollectible(itemID) and ty.ITEMCONFIG:GetCollectible(itemID).Quality < 3 then
			ty.ITEMPOOL:AddRoomBlacklist(itemID)
		end
	end
	local itemID = ty.ITEMPOOL:GetCollectible(ItemPoolType.POOL_ANGEL, false, rng:Next(), CollectibleType.COLLECTIBLE_SERAPHIM)
	if ty.ITEMCONFIG:GetCollectible(itemID).Quality >= 3 then
		ty.ITEMPOOL:RemoveCollectible(itemID)
		ty.ITEMPOOL:ResetRoomBlacklist()
		return itemID
    else
        return CollectibleType.COLLECTIBLE_SERAPHIM
	end
end

function TheGospelOfJohn:UseItem(itemID, rng, player, useFlags, activeSlot, varData)
    if useFlags & UseFlag.USE_CARBATTERY == UseFlag.USE_CARBATTERY then
        player:AddBrokenHearts(-1)
        return { Discharge = false, Remove = false, ShowAnim = false }
    end
    if useFlags & UseFlag.USE_VOID ~= UseFlag.USE_VOID then
        player:AddBrokenHearts(-1)
        ItemOverlay.Show(ty.CustomGiantBooks.THEGOSPELOFJOHN, 3, player)
    end
    for _, ent in pairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)) do
        local pickup = ent:ToPickup()
        if pickup.SubType > 0 and pickup.SubType ~= CollectibleType.COLLECTIBLE_DADS_NOTE then
            local newItem = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, GetAngelRoomCollectible(rng), pickup.Position, Vector(0, 0), nil):ToPickup()
            newItem:MakeShopItem(-4)
            newItem:RemoveCollectibleCycle()
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, newItem.Position, Vector(0, 0), nil)
            pickup:Remove()
        end
    end
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
    local sprite = pickup:GetPriceSprite()
    if pickup:IsShopItem() and pickup:GetAlternatePedestal() == -1 and pickup.ShopItemId == -4 then
        if sprite:GetFilename() ~= "gfx/items/shops/broken_heart_deal.anm2" then
            sprite:Load("gfx/items/shops/broken_heart_deal.anm2", true)
            sprite:SetFrame("Hearts", ty.ITEMCONFIG:GetCollectible(pickup.SubType).Quality - 2)
        end
        if #pickup:GetCollectibleCycle() > 0 then
            pickup:RemoveCollectibleCycle()
        end
    end
end
TheGospelOfJohn:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, TheGospelOfJohn.PostPickupUpdate, PickupVariant.PICKUP_COLLECTIBLE)

function TheGospelOfJohn:GetShopItemPrice(variant, subType, shopItemId, price)
    if shopItemId == -4 then
        return PickupPrice.PRICE_FREE
    end
end
TheGospelOfJohn:AddCallback(ModCallbacks.MC_GET_SHOP_ITEM_PRICE, TheGospelOfJohn.GetShopItemPrice, PickupVariant.PICKUP_COLLECTIBLE)

function TheGospelOfJohn:PostPickupShopPurchase(pickup, player, moneySpent)
    local pickup = pickup:ToPickup()
    if pickup.ShopItemId == -4 and (moneySpent == PickupPrice.PRICE_FREE or pickedUp) then
        player:AddBrokenHearts(player.QueuedItem.Item.Quality - 1)
        pickedUp = false
    end
end
TheGospelOfJohn:AddCallback(ModCallbacks.MC_POST_PICKUP_SHOP_PURCHASE, TheGospelOfJohn.PostPickupShopPurchase, PickupVariant.PICKUP_COLLECTIBLE)

function TheGospelOfJohn:PrePickupCollision(pickup, collider, low)
    local player = collider:ToPlayer()
    local pickup = pickup:ToPickup()
    if player and (player:GetPlayerType() == PlayerType.PLAYER_THESOUL or player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B or player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN_B) and pickup.ShopItemId == -4 and player:CanPickupItem() then
        pickedUp = true
    end
end
TheGospelOfJohn:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, TheGospelOfJohn.PrePickupCollision, PickupVariant.PICKUP_COLLECTIBLE)

function TheGospelOfJohn:PrePlayerAddHearts(player, amount, addHealthType, _)
    if pickedUp and amount < 0 and addHealthType & AddHealthType.SOUL == AddHealthType.SOUL and (player:GetPlayerType() == PlayerType.PLAYER_THESOUL or player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN_B) then
        return 0
    end
end
TheGospelOfJohn:AddCallback(ModCallbacks.MC_PRE_PLAYER_ADD_HEARTS, TheGospelOfJohn.PrePlayerAddHearts)

function TheGospelOfJohn:PrePickupMorph(pickup, type, variant, subType, keepPrice, keepSeed, ignoreModifiers)
    if pickup:IsShopItem() and pickup.ShopItemId == -4 and keepPrice and not keepSeed and not ignoreModifiers and pickup:GetPriceSprite():GetFilename() == "gfx/items/shops/broken_heart_deal.anm2" then
        return false
    end
end
TheGospelOfJohn:AddCallback(ModCallbacks.MC_PRE_PICKUP_MORPH, TheGospelOfJohn.PrePickupMorph)

return TheGospelOfJohn