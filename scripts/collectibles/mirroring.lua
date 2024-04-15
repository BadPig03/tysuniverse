local Mirroring = ty:DefineANewClass()

local function ChangePlayerToOtherSide(player)
    local data = ty:GetLibData(player)
    local room = ty.GAME:GetRoom()
    local playerType = player:GetPlayerType()
    if playerType == PlayerType.PLAYER_ISAAC then
        local historyItems = player:GetHistory():GetCollectiblesHistory()
        local newItems = {}
        player:ChangePlayerType(PlayerType.PLAYER_ISAAC_B)
        local count, limit = 0, 10
        if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
            limit = 16
        end
        for index = #historyItems, 1, -1 do
            local item = historyItems[index]
            local itemID = item:GetItemID()
            if not item:IsTrinket() and not ty.ITEMCONFIG:GetCollectible(itemID):HasTags(ItemConfig.TAG_QUEST) and ty.ITEMCONFIG:GetCollectible(itemID).Type ~= ItemType.ITEM_ACTIVE and itemID ~= CollectibleType.COLLECTIBLE_BIRTHRIGHT then
                if count <= limit then
                    player:DropCollectible(itemID)
                    table.insert(newItems, { ItemID = itemID, ItemPoolType = item:GetItemPoolType() })
                    count = count + 1
                end
                player:RemoveCollectible(itemID)
            end
        end
        for _, newItem in pairs(newItems) do
            for _, ent in pairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, newItem.ItemID)) do
                local pickup = ent:ToPickup()
                if pickup.FrameCount <= 1 then
                    pickup:AddCollectibleCycle(ty.ITEMPOOL:GetCollectible(newItem.ItemPoolType, true, player:GetCollectibleRNG(newItem.ItemID):Next()))
                end
            end    
        end
    elseif playerType == PlayerType.PLAYER_JUDAS or playerType == PlayerType.PLAYER_BLACKJUDAS then
        local health = player:GetMaxHearts() + player:GetSoulHearts()
        data.Mirroring.BlackJudas = playerType == PlayerType.PLAYER_BLACKJUDAS
        player:ChangePlayerType(PlayerType.PLAYER_JUDAS_B)
        player:AddSoulHearts(-99)
        player:AddBlackHearts(health)
    elseif playerType == PlayerType.PLAYER_JUDAS_B and data.Mirroring.BlackJudas then
        player:ChangePlayerType(PlayerType.PLAYER_BLACKJUDAS)
    elseif playerType == PlayerType.PLAYER_BLUEBABY then
        local bomb = player:GetNumBombs()
        player:ChangePlayerType(PlayerType.PLAYER_BLUEBABY_B)
        for i = 1, bomb do
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_POOP, PoopPickupSubType.POOP_SMALL, room:FindFreePickupSpawnPosition(player.Position, 0, true), Vector(0, 0), nil)
        end
    elseif playerType == PlayerType.PLAYER_THEFORGOTTEN or playerType == PlayerType.PLAYER_THESOUL then
        player:ChangePlayerType(PlayerType.PLAYER_THEFORGOTTEN_B)
    elseif playerType == PlayerType.PLAYER_THEFORGOTTEN_B then
        player:ChangePlayerType(PlayerType.PLAYER_THEFORGOTTEN)
        player:AddSoulHearts(-1)
    elseif playerType == PlayerType.PLAYER_BETHANY then
        local charge = player:GetMaxHearts()
        local health = math.max(2, player:GetSoulCharge())
        player:ChangePlayerType(PlayerType.PLAYER_BETHANY_B)
        player:AddMaxHearts(-99)
        player:AddHearts(-99)
        player:AddSoulHearts(-99)
        player:AddSoulHearts(health)
        player:AddBloodCharge(charge)
    elseif playerType == PlayerType.PLAYER_BETHANY_B then
        local charge = player:GetSoulHearts()
        local health = math.max(2, player:GetBloodCharge())
        player:ChangePlayerType(PlayerType.PLAYER_BETHANY)
        player:AddMaxHearts(-99)
        player:AddHearts(-99)
        player:AddSoulHearts(-99)
        player:AddMaxHearts(health)
        player:AddHearts(health)
        player:AddSoulCharge(charge)
    else
        player:ChangePlayerType(EntityConfig.GetPlayer(playerType):GetTaintedCounterpart():GetPlayerType())
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

function Mirroring:UseItem(itemID, rng, player, useFlags, activeSlot, varData)
    if itemID == ty.CustomCollectibles.MIRRORING or itemID == ty.CustomCollectibles.BROKENMIRRORING then
        if useFlags & UseFlag.USE_CARBATTERY == UseFlag.USE_CARBATTERY then
            return { Discharge = false, Remove = false, ShowAnim = false }
        end
        local room = ty.GAME:GetRoom()
        local playerConfig = EntityConfig.GetPlayer(player:GetPlayerType())
        if player:GetPlayerType() == PlayerType.PLAYER_ESAU or player:GetPlayerType() == PlayerType.PLAYER_LAZARUS2 or player:GetPlayerType() == PlayerType.PLAYER_LAZARUS2_B or player:GetPlayerType() == ty.CustomPlayerType.WARFARIN or playerConfig:GetTaintedCounterpart() == nil then
            ty.SFXMANAGER:Play(SoundEffect.SOUND_MIRROR_BREAK)
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_SHARD_OF_GLASS, room:FindFreePickupSpawnPosition(player.Position), Vector(0, 0), nil)
            return { Discharge = false, Remove = true, ShowAnim = true }
        end
        if playerConfig:IsTainted() then
            if itemID == ty.CustomCollectibles.MIRRORING then
                ChangeItemStatus(player)
                return { Discharge = false, Remove = false, ShowAnim = true }
            end
            ty.SFXMANAGER:Play(SoundEffect.SOUND_MIRROR_EXIT)
        else
            if itemID == ty.CustomCollectibles.BROKENMIRRORING then
                ChangeItemStatus(player)
                return { Discharge = false, Remove = false, ShowAnim = true }
            end
            ty.SFXMANAGER:Play(SoundEffect.SOUND_MIRROR_ENTER)
        end
        ChangePlayerToOtherSide(player)
        ChangeItemStatus(player)
        player:AnimateSad()
        ty.SFXMANAGER:Stop(SoundEffect.SOUND_THUMBS_DOWN)
        ty.GAME:ShowHallucination(5, room:GetBackdropType())
        ty.SFXMANAGER:Stop(SoundEffect.SOUND_DEATH_CARD)
        return { Discharge = true, Remove = false, ShowAnim = true }
    end
end
Mirroring:AddCallback(ModCallbacks.MC_USE_ITEM, Mirroring.UseItem)

function Mirroring:PostUpdate()
    local globalData = ty.GLOBALDATA
    if ty.LEVEL:GetStage() == LevelStage.STAGE1_2 and ty.LEVEL:GetCurrentRoomDesc().Data.Variant >= 10000 and ty.LEVEL:GetStateFlag(LevelStateFlag.STATE_MIRROR_BROKEN) and not globalData.Mirroring then
        local room = ty.GAME:GetRoom()
        local targetPos
        for _, v in pairs({60, 74}) do
            local door = room:GetGridEntity(v)
            if door and door:ToDoor() and door:ToDoor().TargetRoomIndex == GridRooms.ROOM_MIRROR_IDX and door.Desc.Variant == 8 then
                targetPos = room:GetGridPosition(v)
                break
            end
        end
        if targetPos then
            local rng = Isaac.GetPlayer(0):GetCollectibleRNG(ty.CustomCollectibles.MIRRORING)
            if rng:RandomInt(100) < 100 then
                local item = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, ty.CustomCollectibles.MIRRORING, ty.GAME:GetRoom():FindFreePickupSpawnPosition(targetPos), Vector(0, 0), nil):ToPickup()
                item.ShopItemId = -2
                item.Price = 0
            end
        end
        globalData.Broken = true
    end
end
Mirroring:AddCallback(ModCallbacks.MC_POST_UPDATE, Mirroring.PostUpdate)

return Mirroring