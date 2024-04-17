local WakeUp = ty:DefineANewClass()

local BannedItems = {
    CollectibleType.COLLECTIBLE_SKELETON_KEY,
    CollectibleType.COLLECTIBLE_DOLLAR,
    CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS,
    CollectibleType.COLLECTIBLE_FORGET_ME_NOW,
    CollectibleType.COLLECTIBLE_CRYSTAL_BALL,
    CollectibleType.COLLECTIBLE_PYRO,
    CollectibleType.COLLECTIBLE_MOMS_KEY,
    CollectibleType.COLLECTIBLE_HUMBLEING_BUNDLE,
    CollectibleType.COLLECTIBLE_GOAT_HEAD,
    CollectibleType.COLLECTIBLE_CONTRACT_FROM_BELOW,
    CollectibleType.COLLECTIBLE_THERES_OPTIONS,
    CollectibleType.COLLECTIBLE_BLACK_CANDLE,
    CollectibleType.COLLECTIBLE_D100,
    CollectibleType.COLLECTIBLE_MIND,
    CollectibleType.COLLECTIBLE_DIPLOPIA,
    CollectibleType.COLLECTIBLE_CAR_BATTERY,
    CollectibleType.COLLECTIBLE_CHARGED_BABY,
    CollectibleType.COLLECTIBLE_RUNE_BAG,
    CollectibleType.COLLECTIBLE_CHAOS,
    CollectibleType.COLLECTIBLE_MORE_OPTIONS,
    CollectibleType.COLLECTIBLE_TELEPORT_2,
    CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS,
    CollectibleType.COLLECTIBLE_SACK_HEAD,
    CollectibleType.COLLECTIBLE_EDENS_SOUL,
    CollectibleType.COLLECTIBLE_EUCHARIST,
    CollectibleType.COLLECTIBLE_SACK_OF_SACKS,
    CollectibleType.COLLECTIBLE_MYSTERY_GIFT,
    CollectibleType.COLLECTIBLE_JUMPER_CABLES,
    CollectibleType.COLLECTIBLE_MR_ME,
    CollectibleType.COLLECTIBLE_SCHOOLBAG,
    CollectibleType.COLLECTIBLE_BOOK_OF_THE_DEAD,
    CollectibleType.COLLECTIBLE_ROCK_BOTTOM,
    CollectibleType.COLLECTIBLE_RED_KEY,
    CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES,
    CollectibleType.COLLECTIBLE_STAIRWAY,
    CollectibleType.COLLECTIBLE_MERCURIUS,
    CollectibleType.COLLECTIBLE_ETERNAL_D6,
    CollectibleType.COLLECTIBLE_BIRTHRIGHT,
    CollectibleType.COLLECTIBLE_GENESIS,
    CollectibleType.COLLECTIBLE_CARD_READING,
    CollectibleType.COLLECTIBLE_ECHO_CHAMBER,
    CollectibleType.COLLECTIBLE_ISAACS_TOMB,
    CollectibleType.COLLECTIBLE_BAG_OF_CRAFTING,
    CollectibleType.COLLECTIBLE_KEEPERS_SACK,
    CollectibleType.COLLECTIBLE_EVERYTHING_JAR,
    CollectibleType.COLLECTIBLE_ANIMA_SOLA,
    CollectibleType.COLLECTIBLE_D6,
    CollectibleType.COLLECTIBLE_VOID,
    CollectibleType.COLLECTIBLE_D_INFINITY,
    CollectibleType.COLLECTIBLE_BROKEN_SHOVEL_1,
    CollectibleType.COLLECTIBLE_BROKEN_SHOVEL_2,
    CollectibleType.COLLECTIBLE_MOMS_SHOVEL,
    CollectibleType.COLLECTIBLE_DEATH_CERTIFICATE,
    CollectibleType.COLLECTIBLE_R_KEY,
    CollectibleType.COLLECTIBLE_GLITCHED_CROWN,
    CollectibleType.COLLECTIBLE_SACRED_ORB,
    CollectibleType.COLLECTIBLE_ABYSS,
    CollectibleType.COLLECTIBLE_FLIP,
    CollectibleType.COLLECTIBLE_SPINDOWN_DICE,
    ty.CustomCollectibles.CROWNOFKINGS,
    ty.CustomCollectibles.ORDER,
    ty.CustomCollectibles.HADESBLADE,
    ty.CustomCollectibles.WAKEUP,
    ty.CustomCollectibles.TELESCOPE,
    ty.CustomCollectibles.BEGGARMASK
}

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

local function GetCollectibleAtLeastQualityWithTag(rng, itemPoolType)
    local itemID
    repeat
        for i = 1, ty.ITEMCONFIG:GetCollectibles().Size - 1 do
            if ItemConfig.Config.IsValidCollectible(i) and (ty.ITEMCONFIG:GetCollectible(i).Quality < 3 or not ty.ITEMCONFIG:GetCollectible(i):HasTags(ItemConfig.TAG_OFFENSIVE) or ty:IsValueInTable(i, BannedItems)) then
                ty.ITEMPOOL:AddRoomBlacklist(i)
            end
        end
        itemID = ty.ITEMPOOL:GetCollectible(itemPoolType, false, rng:Next(), CollectibleType.COLLECTIBLE_WIRE_COAT_HANGER)
    until ty.ITEMCONFIG:GetCollectible(itemID).Quality >= 3 and ty.ITEMCONFIG:GetCollectible(itemID):HasTags(ItemConfig.TAG_OFFENSIVE) and not ty:IsValueInTable(itemID, BannedItems)
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
    data.WakeUp.HealthFactor = math.min(math.max(ty.LEVEL:GetAbsoluteStage() / 22 + 5 / 11, 0.5), 1)
    data.WakeUp.Delay = 300
	return { Discharge = false, Remove = true, ShowAnim = true }
end
WakeUp:AddCallback(ModCallbacks.MC_USE_ITEM, WakeUp.UseItem, ty.CustomCollectibles.WAKEUP)

function WakeUp:PostPlayerUpdate(player)
    local data = ty:GetLibData(player)
    if data.Init then
        if data.WakeUp.Delay > 0 then
            data.WakeUp.Delay = data.WakeUp.Delay - 1
            player:AddSlowing(EntityRef(player), 1, data.WakeUp.Delay / 300, player:GetSprite().Color)
            ty.GAME:Darken((300 - data.WakeUp.Delay) / 300, 1)
        elseif data.WakeUp.Delay == 0 then
            data.WakeUp.Delay = -1
            data.WakeUp.Used = true
            data.WakeUp.DetectDogma = true
            player:SetSlowingCountdown(1)
            ty.LEVEL:SetStage(LevelStage.STAGE8, 1)
            if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
                data.WakeUp.VirtueTriggered = true
            end
            if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL_PASSIVE) then
                data.WakeUp.BelialTriggered = true
            end
            player:UseActiveItem(CollectibleType.COLLECTIBLE_FORGET_ME_NOW, false)
            player:AddHearts(99)
        end
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
        if data.WakeUp.Used and ty.LEVEL:GetAbsoluteStage() == LevelStage.STAGE8 and ty.LEVEL:GetStageType() == StageType.STAGETYPE_WOTL and ty.LEVEL:GetCurrentRoomIndex() == 84 then
            for i = 1, 3 do
                local rng = player:GetCollectibleRNG(ty.CustomCollectibles.WAKEUP)
                local itemPoolType = rng:RandomInt(ItemPoolType.NUM_ITEMPOOLS)
                if data.WakeUp.VirtueTriggered then
                    itemPoolType = ItemPoolType.POOL_ANGEL
                end
                if data.WakeUp.BelialTriggered then
                    itemPoolType = ItemPoolType.POOL_DEVIL
                end
                local item = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, GetCollectibleAtLeastQualityWithTag(rng, itemPoolType), room:FindFreePickupSpawnPosition(Vector(220, 200), 0, true), Vector(0, 0), nil):ToPickup()
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
    for _, player in pairs(PlayerManager.GetPlayers()) do
        local data = ty:GetLibData(player)
        if data.WakeUp.Used and ty.LEVEL:GetAbsoluteStage() ~= LevelStage.STAGE8 then
            data.WakeUp.Used = false
            data.WakeUp.VirtueTriggered = false
            data.WakeUp.BelialTriggered = false
            data.WakeUp.DetectDogma = false
            data.WakeUp.Time = -1
        end    
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