local AbsenceNote = ty:DefineANewClass()

local function GetItemFromPool(player)
    local data = ty.GLOBALDATA
    local rng = player:GetCollectibleRNG(ty.CustomCollectibles.ABSENCENOTE)
    local validItems = {}
    for _, item in pairs(data.NoticeOfCriticalCondition.ItemList) do
        if ty.ITEMPOOL:HasCollectible(item) and ty.ITEMCONFIG:GetCollectible(item).Type == ItemType.ITEM_PASSIVE then
            table.insert(validItems, item)
        end
    end
    if #validItems > 0 then
        local index = rng:RandomInt(#validItems) + 1
        local selected_item = validItems[index]
        ty:RemoveValueInTable(selected_item, data.NoticeOfCriticalCondition.ItemList)
        ty.ITEMPOOL:RemoveCollectible(selected_item)
        return selected_item
    else
        return CollectibleType.COLLECTIBLE_BREAKFAST
    end
end

local function AddARandomItem(player)
    local item = GetItemFromPool(player)
    local itemConfigCollectible = ty.ITEMCONFIG:GetCollectible(item)
    player:AnimateHappy()
    player:AnimateCollectible(item)
    player:QueueItem(itemConfigCollectible)
    ty.HUD:ShowItemText(player, itemConfigCollectible)
end

function AbsenceNote:PostNewLevel()
    local room = ty.GAME:GetRoom()
    for _, player in pairs(PlayerManager.GetPlayers()) do
        if player:HasCollectible(ty.CustomCollectibles.ABSENCENOTE) then
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_PILL, 0, room:FindFreePickupSpawnPosition(player.Position, 0, true), Vector(0, 0), nil)
        end
    end
end
AbsenceNote:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, AbsenceNote.PostNewLevel)

function AbsenceNote:PostItemOverlayShow(giantBook, delay, _)
    local room = ty.GAME:GetRoom()
    for _, player in pairs(PlayerManager.GetPlayers()) do
        if player:HasCollectible(ty.CustomCollectibles.ABSENCENOTE) then
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_PILL, 0, room:FindFreePickupSpawnPosition(player.Position, 0, true), Vector(0, 0), nil)
        end
    end
end
AbsenceNote:AddCallback(ModCallbacks.MC_POST_ITEM_OVERLAY_SHOW, AbsenceNote.PostItemOverlayShow, Giantbook.SLEEP)

function AbsenceNote:UsePill(pillEffect, player, useFlags, pillColor)
    if player:HasCollectible(ty.CustomCollectibles.ABSENCENOTE) and pillColor ~= PillColor.PILL_NULL then
        local data = ty:GetLibData(player)
        if pillEffect ~= PillEffect.PILLEFFECT_VURP then
            data.AbsenceNote.Count = data.AbsenceNote.Count + 1
            if pillColor & PillColor.PILL_GIANT_FLAG == PillColor.PILL_GIANT_FLAG then
                data.AbsenceNote.Count = data.AbsenceNote.Count + 1
            end
        end
        if not ty:IsValueInTable(pillColor, data.AbsenceNote.Colors) then
            table.insert(data.AbsenceNote.Colors, pillColor)
        end
        data.AbsenceNote.Triggered = false
    end
end
AbsenceNote:AddCallback(ModCallbacks.MC_USE_PILL, AbsenceNote.UsePill)

function AbsenceNote:PostPlayerUpdate(player)
    local data = ty:GetLibData(player)
    if data.Init and player:HasCollectible(ty.CustomCollectibles.ABSENCENOTE) and player:IsExtraAnimationFinished() and not data.AbsenceNote.Triggered then
        if data.AbsenceNote.Count > 0 and data.AbsenceNote.Count % 12 == 0 then
            AddARandomItem(player)
            data.AbsenceNote.Count = 0
        end
        if #data.AbsenceNote.Colors > 0 and #data.AbsenceNote.Colors % 4 == 0 and not ty:IsValueInTable(#data.AbsenceNote.Colors, data.AbsenceNote.TriggeredColorCount) then
            AddARandomItem(player)
            table.insert(data.AbsenceNote.TriggeredColorCount, #data.AbsenceNote.Colors)
        end
        data.AbsenceNote.Triggered = true
    end
end
AbsenceNote:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, AbsenceNote.PostPlayerUpdate)

return AbsenceNote