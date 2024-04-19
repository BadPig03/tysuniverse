local LostBottleCap = ty:DefineANewClass()

local detectItem = false
local itemType = 0
local previousItemCount = 0

local function RemoveBottleCap(player)
    local rng = player:GetTrinketRNG(ty.CustomTrinkets.LOSTBOTTLECAP)
    local room = ty.GAME:GetRoom()
    for i = 0, player:GetMaxTrinkets() do
        local trinket = player:GetTrinket(i)
        if trinket > 0 then
            if trinket == ty.CustomTrinkets.LOSTBOTTLECAP then
                if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_BOX) and rng:RandomInt(100) < 50 then
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, ty.CustomTrinkets.LOSTBOTTLECAP, room:FindFreePickupSpawnPosition(player.Position, 0, true), Vector(0, 0), nil) 
                end
                player:TryRemoveTrinket(trinket)
                return
            elseif trinket == ty.CustomTrinkets.LOSTBOTTLECAP | TrinketType.TRINKET_GOLDEN_FLAG then
                if (not player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_BOX) and rng:RandomInt(100) < 50) or (player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_BOX) and rng:RandomInt(100) < 75) then
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, ty.CustomTrinkets.LOSTBOTTLECAP, room:FindFreePickupSpawnPosition(player.Position, 0, true), Vector(0, 0), nil) 
                end
                player:TryRemoveTrinket(trinket)
                return
            end
        end
    end
    for _, item in pairs(player:GetHistory():GetCollectiblesHistory()) do
        if item:IsTrinket() then
            local itemID = item:GetItemID()
            if itemID == ty.CustomTrinkets.LOSTBOTTLECAP then
                if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_BOX) and rng:RandomInt(100) < 50 then
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, ty.CustomTrinkets.LOSTBOTTLECAP, room:FindFreePickupSpawnPosition(player.Position, 0, true), Vector(0, 0), nil) 
                end
                player:TryRemoveSmeltedTrinket(itemID)
                return
            elseif itemID == ty.CustomTrinkets.LOSTBOTTLECAP | TrinketType.TRINKET_GOLDEN_FLAG then
                if (not player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_BOX) and rng:RandomInt(100) < 50) or (player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_BOX) and rng:RandomInt(100) < 75) then
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, ty.CustomTrinkets.LOSTBOTTLECAP, room:FindFreePickupSpawnPosition(player.Position, 0, true), Vector(0, 0), nil) 
                end
                player:TryRemoveSmeltedTrinket(itemID)
                return
            end
        end
    end
end

local function GetActiveItemCounts(player)
    local count = 0
    for index = ActiveSlot.SLOT_PRIMARY, ActiveSlot.SLOT_SECONDARY do
        if player:GetActiveItem(index) > 0 then
            count = count + 1
        end
    end
    return count
end

function LostBottleCap:UseItem(itemID, rng, player, useFlags, activeSlot, varData)
    if activeSlot ~= ActiveSlot.SLOT_POCKET and useFlags & UseFlag.USE_OWNED == UseFlag.USE_OWNED and ty.ITEMCONFIG:GetCollectible(itemID).Type == ItemType.ITEM_ACTIVE then
        local multiplier = player:GetTrinketMultiplier(ty.CustomTrinkets.LOSTBOTTLECAP)
        if multiplier > 0 then
            itemType = itemID
            previousItemCount = GetActiveItemCounts(player)
            detectItem = true
        end
    end
end
LostBottleCap:AddPriorityCallback(ModCallbacks.MC_USE_ITEM, CallbackPriority.IMPORTANT, LostBottleCap.UseItem)

function LostBottleCap:PostPlayerUpdate(player)
    if detectItem then
        if GetActiveItemCounts(player) ~= previousItemCount then
            player:AddCollectible(itemType, 0, false)
            RemoveBottleCap(player)
        end
        previousItemCount = 0
        itemType = 0
        detectItem = false
    end
end
LostBottleCap:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, LostBottleCap.PostPlayerUpdate)

return LostBottleCap