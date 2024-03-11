local WakeUp = ty:DefineANewClass()

local function GetAbsoluteStage()
    local stageCount = ty.LEVEL:GetAbsoluteStage()
    if stageCount == LevelStage.STAGE4_2 then
        stageCount = LevelStage.STAGE4_3
    end
    return stageCount
end

local function GetStageType()
    local stageCount = ty.LEVEL:GetAbsoluteStage()
    local stage = ty.LEVEL:GetStageType()
    if stageCount == LevelStage.STAGE3_2 and stage >= StageType.STAGETYPE_REPENTANCE then
        stage = stage - StageType.STAGETYPE_GREEDMODE
    elseif stageCount == LevelStage.STAGE4_2 then
        stage = StageType.STAGETYPE_WOTL
    elseif stageCount == LevelStage.STAGE6 and stage == StageType.STAGETYPE_WOTL then
        stage = StageType.STAGETYPE_ORIGINAL
    end
    return stage
end

local function GetCollectibleAtLeastQualityWithTag(quality, rng, tag, itemPoolType)
	itemPoolType = itemPoolType or rng:RandomInt(ItemPoolType.NUM_ITEMPOOLS)
	for itemID = 1, ty.ITEMCONFIG:GetCollectibles().Size - 1 do
		if ItemConfig.Config.IsValidCollectible(itemID) and (ty.ITEMCONFIG:GetCollectible(itemID).Quality < quality or not ty.ITEMCONFIG:GetCollectible(itemID):HasTags(tag)) then
			ty.ITEMPOOL:AddRoomBlacklist(itemID)
		end
	end
	local itemID = ty.ITEMPOOL:GetCollectible(itemPoolType, false, rng:Next(), CollectibleType.COLLECTIBLE_SAD_ONION)
    ty.ITEMPOOL:RemoveCollectible(itemID)
    ty.ITEMPOOL:ResetRoomBlacklist()
    return itemID
end

function WakeUp:UseItem(itemID, rng, player, useFlags, activeSlot, varData)
	local data = ty:GetLibData(player)
    if useFlags & UseFlag.USE_CARBATTERY == UseFlag.USE_CARBATTERY then
        return { Discharge = false, Remove = false, ShowAnim = false }
    end
    if ty.GAME:IsGreedMode() or ty.LEVEL:GetAbsoluteStage() == LevelStage.STAGE8 or ty.LEVEL:IsAscent() then
        return { Discharge = false, Remove = false, ShowAnim = true }
    end
    data.WakeUp.CurrentStage = GetAbsoluteStage()
    data.WakeUp.StageType = GetStageType()
    data.WakeUp.Used = true
    data.WakeUp.DetectDogma = true
    data.WakeUp.HealthFactor = math.min(math.max(ty.LEVEL:GetAbsoluteStage() / 22 + 5 / 11, 0.5), 1)
    ty.LEVEL:SetStage(LevelStage.STAGE8, 1)
	if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
		data.WakeUp.VirtueTriggered = true
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL_PASSIVE) then
		data.WakeUp.BelialTriggered = true
	end
    player:UseActiveItem(CollectibleType.COLLECTIBLE_FORGET_ME_NOW, 0)
    player:AddHearts(99)
	return { Discharge = false, Remove = true, ShowAnim = true }
end
WakeUp:AddCallback(ModCallbacks.MC_USE_ITEM, WakeUp.UseItem, ty.CustomCollectibles.WAKEUP)

function WakeUp:PostPlayerUpdate(player)
    local data = ty:GetLibData(player)
    if data.Init then
        if data.WakeUp.Time > 0 then
            data.WakeUp.Time = data.WakeUp.Time - 1
        elseif data.WakeUp.Time == 0 then
            data.WakeUp.Time = -1
            if data.WakeUp.CurrentStage == LevelStage.STAGE7 then
                data.WakeUp.CurrentStage = data.WakeUp.CurrentStage - 1
            end
            ty.LEVEL:SetStage(data.WakeUp.CurrentStage + 1, data.WakeUp.StageType)
            player:UseActiveItem(CollectibleType.COLLECTIBLE_FORGET_ME_NOW, 0)
        end
    end
end
WakeUp:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, WakeUp.PostPlayerUpdate)

function WakeUp:PostNewRoom()
	local room = ty.GAME:GetRoom()
    for _, player in pairs(PlayerManager.GetPlayers()) do
        local data = ty:GetLibData(player)
        if data.WakeUp.Used then
            local itemPoolType = nil
            if data.WakeUp.VirtueTriggered then
                itemPoolType = ItemPoolType.POOL_ANGEL
            end
            if data.WakeUp.BelialTriggered then
                itemPoolType = ItemPoolType.POOL_DEVIL
            end
            for i = 1, 3 do
                local item = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, GetCollectibleAtLeastQualityWithTag(3, player:GetCollectibleRNG(ty.CustomCollectibles.WAKEUP), ItemConfig.TAG_OFFENSIVE, itemPoolType), room:FindFreePickupSpawnPosition(Vector(220, 200), 0, true), Vector(0, 0), nil):ToPickup()
                item.ShopItemId = -2
                item.Price = 0
            end
            data.WakeUp.Used = false
        end
        if data.WakeUp.DetectDogma and ty.LEVEL:GetAbsoluteStage() == LevelStage.STAGE8 and ty.LEVEL:GetStageType() == StageType.STAGETYPE_WOTL and ty.LEVEL:GetCurrentRoomIndex() == 109 then
            for i = DoorSlot.LEFT0, DoorSlot.DOWN1 do
                room:RemoveDoor(i)
            end
        end
    end
end
WakeUp:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, WakeUp.PostNewRoom)

function WakeUp:PostNewLevel()
    if ty.LEVEL:GetAbsoluteStage() == LevelStage.STAGE8 then
        return
    end
    for _, player in pairs(PlayerManager.GetPlayers()) do
        local data = ty:GetLibData(player)
        data.WakeUp.Used = false
        data.WakeUp.VirtueTriggered = false
        data.WakeUp.BelialTriggered = false
        data.WakeUp.DetectDogma = false
        data.WakeUp.Time = -1
    end
end
WakeUp:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, WakeUp.PostNewLevel)

function WakeUp:PostNPCInit(npc)
    for _, player in pairs(PlayerManager.GetPlayers()) do
        local data = ty:GetLibData(player)
        if data.WakeUp.DetectDogma then
            npc.HitPoints = npc.HitPoints * data.WakeUp.HealthFactor
        end
    end
end
WakeUp:AddCallback(ModCallbacks.MC_POST_NPC_INIT, WakeUp.PostNPCInit, EntityType.ENTITY_DOGMA)

function WakeUp:PostEntityKill(entity)
    for _, player in pairs(PlayerManager.GetPlayers()) do
        local data = ty:GetLibData(player)
        if entity.Variant == 2 and data.WakeUp.DetectDogma then
            data.WakeUp.DetectDogma = false
            data.WakeUp.Time = 180
            ty.GAME:ShakeScreen(178)
            local dogma = Isaac.Spawn(EntityType.ENTITY_DOGMA, 2, 0, entity.Position, Vector(0, 0), nil)
            dogma.DepthOffset = 9999
            dogma:AddHealth(-dogma.MaxHitPoints)
            ty.SFXMANAGER:Play(SoundEffect.SOUND_DOGMA_DEATH, 0.6, 2, false, 0.5)
            ty.SFXMANAGER:Play(SoundEffect.SOUND_DOGMA_LIGHT_RAY_FIRE, 0.6, 2, false, 0.5)
            ty.SFXMANAGER:Play(SoundEffect.SOUND_DOGMA_LIGHT_RAY_CHARGE, 0.6, 2, false, 0.5)
            dogma:Die()
            entity:Remove()
        end
    end
end
WakeUp:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, WakeUp.PostEntityKill, EntityType.ENTITY_DOGMA)

function WakeUp:PreChangeRoom(roomIndex, dimension)
    for _, player in pairs(PlayerManager.GetPlayers()) do
        local data = ty:GetLibData(player)
        if data.WakeUp.DetectDogma and ty.LEVEL:GetAbsoluteStage() == LevelStage.STAGE8 then
            if (roomIndex == 82 or roomIndex == 94 or roomIndex == 95) and dimension == Dimension.NORMAL then
                return {84, Dimension.NORMAL}
            end
        end
    end
end
WakeUp:AddCallback(ModCallbacks.MC_PRE_CHANGE_ROOM, WakeUp.PreChangeRoom)

return WakeUp