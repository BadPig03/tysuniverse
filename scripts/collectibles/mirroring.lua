local Mirroring = ty:DefineANewClass()

local function GetAllItem(player)
    local itemList = {}
    for item = 1, ty.ITEMCONFIG:GetCollectibles().Size -1 do
        if player:HasCollectible(item, true) and (ty.ITEMCONFIG:GetCollectible(item).Type == ItemType.ITEM_PASSIVE or ty.ITEMCONFIG:GetCollectible(item).Type == ItemType.ITEM_FAMILIAR) then
            table.insert(itemList, item)
        end
    end
    return itemList
end

local function HaveBothSides()
    local hasTainted = false
    local hasUntainted = false
    for _, player in pairs(PlayerManager.GetPlayers()) do
        if player:GetPlayerType() >= PlayerType.PLAYER_ISAAC_B then
            hasTainted = true
        else
            hasUntainted = true
        end
    end
    if hasTainted and hasUntainted then
        return true
    else
        return false
    end
end

local function UpdateItem(player)
    for _, item in pairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, ty.CustomCollectibles.MIRRORING)) do
        if player:GetPlayerType() >= PlayerType.PLAYER_ISAAC_B then
            item:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, ty.CustomCollectibles.BROKENMIRRORING, true, true, true)
        end
    end
    for _, item in pairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, ty.CustomCollectibles.BROKENMIRRORING)) do
        if player:GetPlayerType() < PlayerType.PLAYER_ISAAC_B then
            item:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, ty.CustomCollectibles.MIRRORING, true, true, true)
        end
    end
end

local function ChangePlayerToOtherSide(player)
    local data = ty:GetLibData(player)
    if player:HasCollectible(ty.CustomCollectibles.MIRRORING) or player:HasCollectible(ty.CustomCollectibles.BROKENMIRRORING) then
        if player:GetPlayerType() == PlayerType.PLAYER_ISAAC then
            data.Mirroring.OldItemList = GetAllItem(player)
            player:ChangePlayerType(PlayerType.PLAYER_ISAAC_B)
        elseif player:GetPlayerType() == PlayerType.PLAYER_ISAAC_B then
            player:ChangePlayerType(PlayerType.PLAYER_ISAAC)
        elseif player:GetPlayerType() == PlayerType.PLAYER_MAGDALENE then
            player:ChangePlayerType(PlayerType.PLAYER_MAGDALENE_B)
        elseif player:GetPlayerType() == PlayerType.PLAYER_MAGDALENE_B then
            player:ChangePlayerType(PlayerType.PLAYER_MAGDALENE)
        elseif player:GetPlayerType() == PlayerType.PLAYER_CAIN then
            player:ChangePlayerType(PlayerType.PLAYER_CAIN_B)
        elseif player:GetPlayerType() == PlayerType.PLAYER_CAIN_B then
            player:ChangePlayerType(PlayerType.PLAYER_CAIN)
        elseif player:GetPlayerType() == PlayerType.PLAYER_JUDAS then
            data.Mirroring.Health = player:GetMaxHearts() + player:GetSoulHearts()
            data.Mirroring.IsDarkJudas = false
            player:ChangePlayerType(PlayerType.PLAYER_JUDAS_B)
        elseif player:GetPlayerType() == PlayerType.PLAYER_BLACKJUDAS then
            data.Mirroring.Health = player:GetSoulHearts()
            data.Mirroring.IsDarkJudas = true
            player:ChangePlayerType(PlayerType.PLAYER_JUDAS_B)
        elseif player:GetPlayerType() == PlayerType.PLAYER_JUDAS_B then
            if not data.Mirroring.IsDarkJudas then
                player:ChangePlayerType(PlayerType.PLAYER_JUDAS)
            elseif data.Mirroring.IsDarkJudas then
                player:ChangePlayerType(PlayerType.PLAYER_BLACKJUDAS)
            end
        elseif player:GetPlayerType() == PlayerType.PLAYER_BLUEBABY then
            data.Mirroring.Bomb = player:GetNumBombs()
            player:ChangePlayerType(PlayerType.PLAYER_BLUEBABY_B)
        elseif player:GetPlayerType() == PlayerType.PLAYER_BLUEBABY_B then
            player:ChangePlayerType(PlayerType.PLAYER_BLUEBABY)
        elseif player:GetPlayerType() == PlayerType.PLAYER_EVE then
            player:ChangePlayerType(PlayerType.PLAYER_EVE_B)
        elseif player:GetPlayerType() == PlayerType.PLAYER_EVE_B then
            player:ChangePlayerType(PlayerType.PLAYER_EVE)
        elseif player:GetPlayerType() == PlayerType.PLAYER_SAMSON then
            player:ChangePlayerType(PlayerType.PLAYER_SAMSON_B)
        elseif player:GetPlayerType() == PlayerType.PLAYER_SAMSON_B then
            player:ChangePlayerType(PlayerType.PLAYER_SAMSON)
        elseif player:GetPlayerType() == PlayerType.PLAYER_AZAZEL then
            player:ChangePlayerType(PlayerType.PLAYER_AZAZEL_B)
        elseif player:GetPlayerType() == PlayerType.PLAYER_AZAZEL_B then
            player:ChangePlayerType(PlayerType.PLAYER_AZAZEL)
        elseif player:GetPlayerType() == PlayerType.PLAYER_LAZARUS then
            player:ChangePlayerType(PlayerType.PLAYER_LAZARUS_B)
            data.Mirroring.IsLazarus2 = false
        elseif player:GetPlayerType() == PlayerType.PLAYER_LAZARUS2 then
            data.Mirroring.IsLazarus2 = true
            player:ChangePlayerType(PlayerType.PLAYER_LAZARUS_B)
        elseif player:GetPlayerType() == PlayerType.PLAYER_LAZARUS_B then
            if not data.Mirroring.IsLazarus2 then
                player:ChangePlayerType(PlayerType.PLAYER_LAZARUS)
            elseif data.Mirroring.IsLazarus2 then
                player:ChangePlayerType(PlayerType.PLAYER_LAZARUS2)
            end
        elseif player:GetPlayerType() == PlayerType.PLAYER_LILITH then
            player:ChangePlayerType(PlayerType.PLAYER_LILITH_B)
        elseif player:GetPlayerType() == PlayerType.PLAYER_LILITH_B then
            player:ChangePlayerType(PlayerType.PLAYER_LILITH)
        elseif player:GetPlayerType() == PlayerType.PLAYER_EDEN then
            player:ChangePlayerType(PlayerType.PLAYER_EDEN_B)
        elseif player:GetPlayerType() == PlayerType.PLAYER_EDEN_B then
            player:ChangePlayerType(PlayerType.PLAYER_EDEN)
        elseif player:GetPlayerType() == PlayerType.PLAYER_THELOST then
            player:ChangePlayerType(PlayerType.PLAYER_THELOST_B)
        elseif player:GetPlayerType() == PlayerType.PLAYER_THELOST_B then
            player:ChangePlayerType(PlayerType.PLAYER_THELOST)
        elseif player:GetPlayerType() == PlayerType.PLAYER_KEEPER then
            player:ChangePlayerType(PlayerType.PLAYER_KEEPER_B)
        elseif player:GetPlayerType() == PlayerType.PLAYER_KEEPER_B then
            player:ChangePlayerType(PlayerType.PLAYER_KEEPER)
        elseif player:GetPlayerType() == PlayerType.PLAYER_APOLLYON then
            player:ChangePlayerType(PlayerType.PLAYER_APOLLYON_B)
        elseif player:GetPlayerType() == PlayerType.PLAYER_APOLLYON_B then
            player:ChangePlayerType(PlayerType.PLAYER_APOLLYON)
        elseif player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN or player:GetPlayerType() == PlayerType.PLAYER_THESOUL then
            player:ChangePlayerType(PlayerType.PLAYER_THEFORGOTTEN_B)
        elseif player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN_B then
            player:ChangePlayerType(PlayerType.PLAYER_THEFORGOTTEN)
        elseif player:GetPlayerType() == PlayerType.PLAYER_BETHANY then
            data.Mirroring.Charge = player:GetSoulCharge()
            data.Mirroring.Health = player:GetMaxHearts()
            if data.Mirroring.Charge == 0 then
                data.Mirroring.Charge = 1
            end
            player:ChangePlayerType(PlayerType.PLAYER_BETHANY_B)
        elseif player:GetPlayerType() == PlayerType.PLAYER_BETHANY_B then
            data.Mirroring.Charge = player:GetBloodCharge()
            if data.Mirroring.Charge == 0 then
                data.Mirroring.Charge = 1
            end
            data.Mirroring.BookOfVirtues = not player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES)
            player:ChangePlayerType(PlayerType.PLAYER_BETHANY)
        elseif player:GetPlayerType() == PlayerType.PLAYER_JACOB then
            player:ChangePlayerType(PlayerType.PLAYER_JACOB_B)
        elseif player:GetPlayerType() == PlayerType.PLAYER_JACOB_B then
            player:ChangePlayerType(PlayerType.PLAYER_JACOB)
        end
    end
end

local function ChangeItemStatus(player)
    local itemCharge = 0
    if player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) == ty.CustomCollectibles.MIRRORING then
        itemCharge = player:GetActiveCharge(ActiveSlot.SLOT_PRIMARY) + player:GetBatteryCharge(ActiveSlot.SLOT_PRIMARY)
        player:RemoveCollectible(ty.CustomCollectibles.MIRRORING, false, ActiveSlot.SLOT_PRIMARY)
        player:AddCollectible(ty.CustomCollectibles.BROKENMIRRORING, itemCharge, false, ActiveSlot.SLOT_PRIMARY)
    elseif player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) == ty.CustomCollectibles.BROKENMIRRORING then
        itemCharge = player:GetActiveCharge(ActiveSlot.SLOT_PRIMARY) + player:GetBatteryCharge(ActiveSlot.SLOT_PRIMARY)
        player:RemoveCollectible(ty.CustomCollectibles.BROKENMIRRORING, false, ActiveSlot.SLOT_PRIMARY)
        player:AddCollectible(ty.CustomCollectibles.MIRRORING, itemCharge, false, ActiveSlot.SLOT_PRIMARY)
    elseif player:GetActiveItem(ActiveSlot.SLOT_SECONDARY) == ty.CustomCollectibles.MIRRORING then
        itemCharge = player:GetActiveCharge(ActiveSlot.SLOT_SECONDARY) + player:GetBatteryCharge(ActiveSlot.SLOT_SECONDARY)
        player:RemoveCollectible(ty.CustomCollectibles.MIRRORING, false, ActiveSlot.SLOT_SECONDARY)
        player:AddCollectible(ty.CustomCollectibles.BROKENMIRRORING, itemCharge, false, ActiveSlot.SLOT_SECONDARY)
    elseif player:GetActiveItem(ActiveSlot.SLOT_SECONDARY) == ty.CustomCollectibles.BROKENMIRRORING then
        itemCharge = player:GetActiveCharge(ActiveSlot.SLOT_SECONDARY) + player:GetBatteryCharge(ActiveSlot.SLOT_SECONDARY)
        player:RemoveCollectible(ty.CustomCollectibles.BROKENMIRRORING, false, ActiveSlot.SLOT_SECONDARY)
        player:AddCollectible(ty.CustomCollectibles.MIRRORING, itemCharge, false, ActiveSlot.SLOT_SECONDARY)
    end
end

local function IsMirrorBusted(player)
    local room = ty.GAME:GetRoom()
    local data = ty:GetLibData(player)
    for _, v in pairs({60, 74}) do
        local door = room:GetGridEntity(v)
        if door and door:ToDoor() and door:ToDoor().TargetRoomIndex == GridRooms.ROOM_MIRROR_IDX and door.Desc.Variant == 8 then
            data.Mirroring.MirrorBustedPosition = room:GetGridPosition(v)
            return true
        end
    end
    return false
end

local function CheckMirror(player)
    local data = ty:GetLibData(player)
    if data.Init and IsMirrorBusted(player) then
        local rng = player:GetCollectibleRNG(ty.CustomCollectibles.MIRRORING)
        if rng:RandomInt(100) <= 20 then
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, ty.CustomCollectibles.MIRRORING, ty.GAME:GetRoom():FindFreePickupSpawnPosition(data.Mirroring.MirrorBustedPosition), Vector(0, 0), nil)
        end
        data.Mirroring.MirroringSpawned = true
    end
end

local function GetDifferentItem(oldTable, newTable)
    local itemList = {}
    for _, value in ipairs(oldTable) do
        local flag = false
        for _, val in ipairs(newTable) do
            if value == val then
                flag = true
                break
            end
        end
        if not flag then
            table.insert(itemList, value)
        end
      end
    return itemList
end

function Mirroring:PostPlayerUpdate(player)
    local room = ty.GAME:GetRoom()
    local data = ty:GetLibData(player)
    if data.Init and player:GetPlayerType() <= PlayerType.PLAYER_THESOUL_B then
        if not HaveBothSides() then
            UpdateItem(player) 
        end
        if (ty.LEVEL:GetStage() == LevelStage.STAGE1_1 or ty.LEVEL:GetStage() == LevelStage.STAGE1_2) and ty.LEVEL:GetCurrentRoomDesc().Data.Variant >= 10000 and not room:IsMirrorWorld() and not data.Mirroring.MirroringSpawned then
            CheckMirror(player)
        end
        if player:HasCollectible(ty.CustomCollectibles.MIRRORING) or player:HasCollectible(ty.CustomCollectibles.BROKENMIRRORING) then
            if data.Mirroring.PlayerType == -1 then
                data.Mirroring.PlayerType = player:GetPlayerType()
            end
            if data.Mirroring.PlayerType ~= player:GetPlayerType() then
                data.Mirroring.PlayerType = player:GetPlayerType()
                if player:GetPlayerType() == PlayerType.PLAYER_ISAAC_B then
                    local itemList = GetDifferentItem(data.Mirroring.OldItemList, GetAllItem(player))
                    local itemLimit = math.floor(#itemList * 0.75) + 1
                    for _, item in ipairs(itemList) do
                        if itemLimit >= 1 then
                            itemLimit = itemLimit - 1
                            local item = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, item, room:FindFreePickupSpawnPosition(player.Position, 0, true), Vector(0, 0), nil)
                            item:ClearEntityFlags(EntityFlag.FLAG_ITEM_SHOULD_DUPLICATE)
                        end
                    end
                    data.Mirroring.OldItemList = {}
                elseif player:GetPlayerType() == PlayerType.PLAYER_JUDAS_B then
                    player:AddSoulHearts(-99)
                    player:AddBlackHearts(data.Mirroring.Health)
                    data.Mirroring.Health = 0
                elseif player:GetPlayerType() == PlayerType.PLAYER_BLUEBABY_B then
                    for i = 1, data.Mirroring.Bomb do
                        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_POOP, PoopPickupSubType.POOP_SMALL, room:FindFreePickupSpawnPosition(player.Position, 0, true), Vector(0, 0), nil)
                    end
                    data.Mirroring.Bomb = 0
                elseif player:GetPlayerType() == PlayerType.PLAYER_BETHANY then
                    player:AddMaxHearts(-100)
                    player:AddMaxHearts(data.Mirroring.Charge)
                    player:AddHearts(data.Mirroring.Charge)
                    if data.Mirroring.BookOfVirtues then
                        data.Mirroring.BookOfVirtues = false
                        player:AddCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES, ty.ITEMCONFIG:GetCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES).MaxCharges)
                    end
                    data.Mirroring.Charge = 0
                elseif player:GetPlayerType() == PlayerType.PLAYER_BETHANY_B then
                    player:AddSoulHearts(-100)
                    player:AddSoulHearts(data.Mirroring.Charge)
                    player:SetBloodCharge(data.Mirroring.Health)
                    data.Mirroring.Charge = 0
                end
            end
        end
    end
end
Mirroring:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Mirroring.PostPlayerUpdate)

function Mirroring:UseItem(itemID, rng, player, useFlags, activeSlot, varData)
    if (itemID == ty.CustomCollectibles.MIRRORING or itemID == ty.CustomCollectibles.BROKENMIRRORING) and useFlags & UseFlag.USE_VOID ~= UseFlag.USE_VOID and useFlags & UseFlag.USE_CARBATTERY ~= UseFlag.USE_CARBATTERY then
        local room = ty.GAME:GetRoom()
        if player:GetPlayerType() == PlayerType.PLAYER_ESAU or player:GetPlayerType() == PlayerType.PLAYER_LAZARUS2 or player:GetPlayerType() == PlayerType.PLAYER_LAZARUS2_B or player:GetPlayerType() == ty.CustomPlayerType.WARFARIN then
            ty.SFXMANAGER:Play(SoundEffect.SOUND_MIRROR_BREAK)
            player:RemoveCollectible(ty.CustomCollectibles.MIRRORING, false, ActiveSlot.SLOT_PRIMARY)
            player:RemoveCollectible(ty.CustomCollectibles.BROKENMIRRORING, false, ActiveSlot.SLOT_PRIMARY)
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_SHARD_OF_GLASS, room:FindFreePickupSpawnPosition(player.Position), Vector(0, 0), nil)
        end
        if player:GetPlayerType() <= PlayerType.PLAYER_JACOB then
            ty.SFXMANAGER:Play(SoundEffect.SOUND_MIRROR_ENTER)
        else
            ty.SFXMANAGER:Play(SoundEffect.SOUND_MIRROR_EXIT)
        end
        ChangePlayerToOtherSide(player)
        ChangeItemStatus(player)
        player:AnimateSad()
        ty.SFXMANAGER:Stop(SoundEffect.SOUND_THUMBS_DOWN)
        ty.GAME:ShowHallucination(5, room:GetBackdropType())
        ty.SFXMANAGER:Stop(SoundEffect.SOUND_DEATH_CARD)
    end
end
Mirroring:AddCallback(ModCallbacks.MC_USE_ITEM, Mirroring.UseItem)

return Mirroring