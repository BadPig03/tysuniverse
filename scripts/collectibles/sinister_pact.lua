local SinisterPact = ty:DefineANewClass()

local functions = ty.Functions

function SinisterPact:PostPickupShopPurchase(pickup, player, moneySpent)
    if pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE and player:HasCollectible(ty.CustomCollectibles.SINISTERPACT) and moneySpent < 0 and moneySpent > PickupPrice.PRICE_FREE and player:GetHealthType() ~= HealthType.LOST and not player:GetEffects():HasNullEffect(NullItemID.ID_LOST_CURSE) then
        local room = ty.GAME:GetRoom()
        Isaac.CreateTimer(function()
            local item = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, functions:GetCollectibleFromCurrentRoom(true, nil, player:GetCollectibleRNG(ty.CustomCollectibles.SINISTERPACT)), pickup.Position, Vector(0, 0), nil):ToPickup()
            item:MakeShopItem(-2)
            item.Price = ty.ITEMCONFIG:GetCollectible(item.SubType).DevilPrice
        end, 20, 0, false)
        if pickup.SubType > 0 then
            local oldItem = ty.GAME:Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, room:FindFreePickupSpawnPosition(pickup.Position, 0, true, false), Vector(0, 0), nil, pickup.SubType, pickup.InitSeed):ToPickup()
            oldItem:ClearEntityFlags(EntityFlag.FLAG_ITEM_SHOULD_DUPLICATE | EntityFlag.FLAG_APPEAR)
            oldItem.Touched = pickup.Touched
            oldItem.Charge = pickup.Charge
            oldItem:SetNewOptionsPickupIndex(pickup.OptionsPickupIndex)
            oldItem:SetVarData(pickup:GetVarData())
            pickup:Remove()
        end
    end
end
SinisterPact:AddCallback(ModCallbacks.MC_POST_PICKUP_SHOP_PURCHASE, SinisterPact.PostPickupShopPurchase)

return SinisterPact