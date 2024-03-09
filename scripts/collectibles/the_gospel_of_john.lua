local TheGospelOfJohn = ty:DefineANewClass()

local johnUsed = false

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
	end
end

local function ReplaceItemPrice(pickup)
    pickup:MakeShopItem(-1)
    pickup.AutoUpdatePrice = false
    pickup.Price = PickupPrice.PRICE_FREE
    local sprite = pickup:GetPriceSprite()
    sprite:Load("gfx/items/shops/broken_heart_deal.anm2", true)
    sprite:SetFrame("Hearts", ty.ITEMCONFIG:GetCollectible(pickup.SubType).Quality - 2)
end

local function IsItemValid(pickup)
    if pickup:IsShopItem() and pickup.AutoUpdatePrice == false and pickup.ShopItemId == -1 and pickup.Price == PickupPrice.PRICE_FREE and pickup.Type == EntityType.ENTITY_PICKUP and pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE and pickup.Touched == false then
        return true
    end
    return false
end

function TheGospelOfJohn:PostPickupUpdate(pickup)
    local pickup = pickup:ToPickup()
    if IsItemValid(pickup) and pickup:GetPriceSprite():GetFilename() ~= "gfx/items/shops/broken_heart_deal.anm2" then
        ReplaceItemPrice(pickup)
    end
    if pickup:IsShopItem() and pickup:GetAlternatePedestal() == -1 and pickup:GetPriceSprite():GetFilename() == "" then
        local newPickup = ty.GAME:Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, pickup.Position, Vector(0, 0), nil, pickup.SubType, pickup.InitSeed):ToPickup()
        pickup:Remove()
        newPickup.Touched = true
    end
end
TheGospelOfJohn:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, TheGospelOfJohn.PostPickupUpdate, PickupVariant.PICKUP_COLLECTIBLE)

function TheGospelOfJohn:PostPickupShopPurchase(pickup, player, moneySpent)
    local pickup = pickup:ToPickup()
    local count = player.QueuedItem.Item.Quality - 1
    if IsItemValid(pickup) and moneySpent == PickupPrice.PRICE_FREE then
        player:AddBrokenHearts(count)
    end
end
TheGospelOfJohn:AddCallback(ModCallbacks.MC_POST_PICKUP_SHOP_PURCHASE, TheGospelOfJohn.PostPickupShopPurchase, PickupVariant.PICKUP_COLLECTIBLE)

function TheGospelOfJohn:PrePickupMorph(pickup, type, variant, subType, keepPrice, keepSeed, ignoreModifiers)
    if not johnUsed and IsItemValid(pickup) and pickup:GetPriceSprite():GetFilename() == "gfx/items/shops/broken_heart_deal.anm2" then
        return false
    end
end
TheGospelOfJohn:AddCallback(ModCallbacks.MC_PRE_PICKUP_MORPH, TheGospelOfJohn.PrePickupMorph)

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
        if pickup.SubType > 0 and not pickup.SubType ~= CollectibleType.COLLECTIBLE_DADS_NOTE then
            johnUsed = true
            if pickup:TryFlip() then
                local seed = pickup.InitSeed
                pickup:Remove()
                pickup = ty.GAME:Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, pickup.Position, Vector(0, 0), nil, GetAngelRoomCollectible(rng), seed):ToPickup()
            else
                pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, GetAngelRoomCollectible(rng))
            end
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector(0, 0), nil)
            ReplaceItemPrice(pickup)
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

return TheGospelOfJohn