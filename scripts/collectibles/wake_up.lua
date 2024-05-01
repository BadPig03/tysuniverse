local WakeUp = ty:DefineANewClass()

local functions = ty.Functions

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

local bannedActives = {
    CollectibleType.COLLECTIBLE_TELEPORT,
    CollectibleType.COLLECTIBLE_FORGET_ME_NOW,
    CollectibleType.COLLECTIBLE_TELEPORT_2,
    CollectibleType.COLLECTIBLE_GENESIS,
    CollectibleType.COLLECTIBLE_DEATH_CERTIFICATE,
    CollectibleType.COLLECTIBLE_R_KEY
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

local function GetCollectibleAtLeastQualityWithTag(itemPoolType)
    local itemID
    local itemList = {}
    local rng = Isaac.GetPlayer(0):GetCollectibleRNG(ty.CustomCollectibles.WAKEUP)
    if itemPoolType ~= -1 then
        repeat
            for i = 1, ty.ITEMCONFIG:GetCollectibles().Size - 1 do
                if ItemConfig.Config.IsValidCollectible(i) and (ty.ITEMCONFIG:GetCollectible(i).Quality < 3 or not ty.ITEMCONFIG:GetCollectible(i):HasTags(ItemConfig.TAG_OFFENSIVE) or ty:IsValueInTable(BannedItems, i)) then
                    ty.ITEMPOOL:AddRoomBlacklist(i)
                end
            end
            itemID = ty.ITEMPOOL:GetCollectible(itemPoolType, false, rng:Next(), CollectibleType.COLLECTIBLE_WIRE_COAT_HANGER)
        until ty.ITEMCONFIG:GetCollectible(itemID).Quality >= 3 and ty.ITEMCONFIG:GetCollectible(itemID):HasTags(ItemConfig.TAG_OFFENSIVE) and not ty:IsValueInTable(BannedItems, itemID)    
    else
        repeat
            for i = 1, ty.ITEMCONFIG:GetCollectibles().Size - 1 do
                if ItemConfig.Config.IsValidCollectible(i) and ty.ITEMCONFIG:GetCollectible(i).Quality >= 3 and ty.ITEMCONFIG:GetCollectible(i):HasTags(ItemConfig.TAG_OFFENSIVE) and not ty:IsValueInTable(BannedItems, i) then
                    table.insert(itemList, i)
                end
            end
            itemID = ty.ITEMPOOL:GetCollectibleFromList(itemList, rng:Next(), CollectibleType.COLLECTIBLE_WIRE_COAT_HANGER)
        until ty.ITEMCONFIG:GetCollectible(itemID).Quality >= 3 and ty.ITEMCONFIG:GetCollectible(itemID):HasTags(ItemConfig.TAG_OFFENSIVE) and not ty:IsValueInTable(BannedItems, itemID)    
    end
    ty.ITEMPOOL:RemoveCollectible(itemID)
    ty.ITEMPOOL:ResetRoomBlacklist()
    return itemID
end

function WakeUp:PreUseItem(itemID, rng, player, useFlags, activeSlot, varData)
    local globalData = ty.GLOBALDATA
    if globalData.WakeUp.PreventActives and ty:IsValueInTable(bannedActives, itemID) then
        return true
    end
end
WakeUp:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, WakeUp.PreUseItem)

function WakeUp:UseItem(itemID, rng, player, useFlags, activeSlot, varData)
	local globalData = ty.GLOBALDATA
    if useFlags & UseFlag.USE_CARBATTERY == UseFlag.USE_CARBATTERY then
        return { Discharge = false, Remove = false, ShowAnim = false }
    end
    if ty.GAME:IsGreedMode() or ty.LEVEL:GetAbsoluteStage() == LevelStage.STAGE8 or ty.LEVEL:IsAscent() then
        return { Discharge = false, Remove = false, ShowAnim = true }
    end
    globalData.WakeUp.CurrentStage = GetAbsoluteStage()
    globalData.WakeUp.StageType = GetStageType()
    globalData.WakeUp.HealthFactor = math.min(math.max(ty.LEVEL:GetAbsoluteStage() / 22 + 5 / 11, 0.5), 1)
    globalData.WakeUp.Delay = 150
	return { Discharge = false, Remove = true, ShowAnim = true }
end
WakeUp:AddCallback(ModCallbacks.MC_USE_ITEM, WakeUp.UseItem, ty.CustomCollectibles.WAKEUP)

function WakeUp:PostUpdate()
    local globalData = ty.GLOBALDATA
    if globalData.WakeUp.Delay > 0 then
        globalData.WakeUp.Delay = globalData.WakeUp.Delay - 1
        ty.GAME:Darken((150 - globalData.WakeUp.Delay) / 150, 1)
        for _, player in pairs(PlayerManager.GetPlayers()) do
            player:AddSlowing(EntityRef(player), 1, globalData.WakeUp.Delay / 150, player:GetSprite().Color)
        end
    elseif globalData.WakeUp.Delay == 0 then
        globalData.WakeUp.Delay = -1
        globalData.WakeUp.Used = true
        globalData.WakeUp.DetectDogma = true
        ty.LEVEL:SetStage(LevelStage.STAGE8, 1)
        if PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
            globalData.WakeUp.VirtueTriggered = true
        end
        if PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL_PASSIVE) then
            globalData.WakeUp.BelialTriggered = true
        end
        for _, player in pairs(PlayerManager.GetPlayers()) do
            player:SetSlowingCountdown(1)
            globalData.WakeUp.PreventActives = false
            player:UseActiveItem(CollectibleType.COLLECTIBLE_FORGET_ME_NOW, false)
            globalData.WakeUp.PreventActives = true
            player:AddHearts(99)    
        end
    end
    if globalData.WakeUp.Time > 0 then
        globalData.WakeUp.Time = globalData.WakeUp.Time - 1
    elseif globalData.WakeUp.Time == 0 then
        globalData.WakeUp.Time = -1
        if globalData.WakeUp.CurrentStage == LevelStage.STAGE7 then
            globalData.WakeUp.CurrentStage = globalData.WakeUp.CurrentStage - 1
        end
        ty.LEVEL:SetStage(globalData.WakeUp.CurrentStage + 1, globalData.WakeUp.StageType)
        globalData.WakeUp.PreventActives = false
        for _, player in pairs(PlayerManager.GetPlayers()) do
            player:UseActiveItem(CollectibleType.COLLECTIBLE_FORGET_ME_NOW, false)
            player:AddCollectible(CollectibleType.COLLECTIBLE_DOGMA)
        end
    end
end
WakeUp:AddCallback(ModCallbacks.MC_POST_UPDATE, WakeUp.PostUpdate)

function WakeUp:PostNewRoom()
	local room = ty.GAME:GetRoom()
    local globalData = ty.GLOBALDATA
    if globalData.WakeUp then
        if globalData.WakeUp.Used and ty.LEVEL:GetAbsoluteStage() == LevelStage.STAGE8 and ty.LEVEL:GetStageType() == StageType.STAGETYPE_WOTL and ty.LEVEL:GetCurrentRoomIndex() == 84 and room:IsFirstVisit() then
            globalData.WakeUp.Used = false
            local itemPoolType = -1
            local both = false
            if globalData.WakeUp.VirtueTriggered and not globalData.WakeUp.BelialTriggered then
                itemPoolType = ItemPoolType.POOL_ANGEL
            end
            if globalData.WakeUp.BelialTriggered and not globalData.WakeUp.VirtueTriggered then
                itemPoolType = ItemPoolType.POOL_DEVIL
            end
            if globalData.WakeUp.VirtueTriggered and globalData.WakeUp.BelialTriggered then
                both = true
            end
            for i = 1, 2 do
                itemPoolType = (both and ((i == 1 and ItemPoolType.POOL_ANGEL) or (i == 2 and ItemPoolType.POOL_DEVIL))) or itemPoolType
                local item = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, GetCollectibleAtLeastQualityWithTag(itemPoolType), room:FindFreePickupSpawnPosition(Vector(220, 200), 0, true), Vector(0, 0), nil):ToPickup()
                item.ShopItemId = -2
                item.Price = 0
            end
        end
        if globalData.WakeUp.DetectDogma and ty.LEVEL:GetAbsoluteStage() == LevelStage.STAGE8 and ty.LEVEL:GetStageType() == StageType.STAGETYPE_WOTL and ty.LEVEL:GetCurrentRoomIndex() == 109 then
            for i = DoorSlot.LEFT0, DoorSlot.DOWN1 do
                room:RemoveDoor(i)
            end
        end
    end
end
WakeUp:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, WakeUp.PostNewRoom)

function WakeUp:PostNewLevel()
    local globalData = ty.GLOBALDATA
    if globalData.WakeUp and globalData.WakeUp.Used and ty.LEVEL:GetAbsoluteStage() ~= LevelStage.STAGE8 then
        globalData.WakeUp.Used = false
        globalData.WakeUp.VirtueTriggered = false
        globalData.WakeUp.BelialTriggered = false
        globalData.WakeUp.DetectDogma = false
        globalData.WakeUp.Time = -1
    end    
end
WakeUp:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, WakeUp.PostNewLevel)

function WakeUp:PostNPCInit(npc)
    local globalData = ty.GLOBALDATA
    if globalData.WakeUp.DetectDogma then
        npc.HitPoints = npc.HitPoints * globalData.WakeUp.HealthFactor
    end
end
WakeUp:AddCallback(ModCallbacks.MC_POST_NPC_INIT, WakeUp.PostNPCInit, EntityType.ENTITY_DOGMA)

function WakeUp:PostEntityKill(entity)
    local globalData = ty.GLOBALDATA
    if entity.Variant == 2 and globalData.WakeUp.DetectDogma then
        globalData.WakeUp.DetectDogma = false
        globalData.WakeUp.Time = 90
        ty.GAME:ShakeScreen(89)
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
WakeUp:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, WakeUp.PostEntityKill, EntityType.ENTITY_DOGMA)

function WakeUp:PreChangeRoom(roomIndex, dimension)
    local globalData = ty.GLOBALDATA
    if globalData.WakeUp.DetectDogma and ty.LEVEL:GetAbsoluteStage() == LevelStage.STAGE8 and (roomIndex == 82 or roomIndex == 94 or roomIndex == 95) and dimension == Dimension.NORMAL then
        return {84, Dimension.NORMAL}
    end
end
WakeUp:AddCallback(ModCallbacks.MC_PRE_CHANGE_ROOM, WakeUp.PreChangeRoom)

return WakeUp