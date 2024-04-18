local LostBottleCap = ty:DefineANewClass()

local disposableActives = {
    CollectibleType.COLLECTIBLE_FORGET_ME_NOW,
    CollectibleType.COLLECTIBLE_BLUE_BOX,
    CollectibleType.COLLECTIBLE_DIPLOPIA,
    CollectibleType.COLLECTIBLE_PLAN_C,
    CollectibleType.COLLECTIBLE_MAMA_MEGA,
    CollectibleType.COLLECTIBLE_EDENS_SOUL,
    CollectibleType.COLLECTIBLE_MYSTERY_GIFT,
    CollectibleType.COLLECTIBLE_SACRIFICIAL_ALTAR,
    CollectibleType.COLLECTIBLE_DAMOCLES,
    CollectibleType.COLLECTIBLE_ALABASTER_BOX,
    CollectibleType.COLLECTIBLE_GENESIS,
    CollectibleType.COLLECTIBLE_DEATH_CERTIFICATE,
    CollectibleType.COLLECTIBLE_R_KEY,
    ty.CustomCollectibles.WAKEUP
}

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

function LostBottleCap:UseItem(itemID, rng, player, useFlags, activeSlot, varData)
    local multiplier = player:GetTrinketMultiplier(ty.CustomTrinkets.LOSTBOTTLECAP)
    if multiplier > 0 and ty:IsValueInTable(disposableActives, itemID) then
        RemoveBottleCap(player)
        if itemID == ty.CustomCollectibles.WAKEUP then
            local data = ty:GetLibData(player)
            data.WakeUp.Keep = true
        else
            return { Discharge = true, Remove = false, ShowAnim = true }
        end
    end
end
LostBottleCap:AddPriorityCallback(ModCallbacks.MC_USE_ITEM, CallbackPriority.IMPORTANT, LostBottleCap.UseItem)


return LostBottleCap