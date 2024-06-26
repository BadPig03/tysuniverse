local Warfarin = ty:DefineANewClass()

local stat = ty.Stat
local functions = ty.Functions

local shouldReviveWithRedHearts = false
local stopHurtSound = false
local restorePosition = false
local replaceTrapDoor = false
local bossItemList = {}

if CuerLib then
    CuerLib.Players.SetOnlyRedHeartPlayer(ty.CustomPlayerType.WARFARIN, true)
end

local function GetDamagePerCharge(player)
    local data = ty:GetLibData(player)
    local charge = 20 + math.log(data.Warfarin.UsedCount ^ 2 + 1) + (data.Warfarin.UsedCount) ^ 1.8
    if player:HasCollectible(CollectibleType.COLLECTIBLE_4_5_VOLT) then
        charge = charge * 0.8
    end
    return math.ceil(charge)
end

local function IsCollectibleHasNoItemPool(collectibleType)
	local itemPoolList = {}
	for itemPoolType = ItemPoolType.POOL_TREASURE, ItemPoolType.NUM_ITEMPOOLS - 1 do
		for item, value in pairs(ty.ITEMPOOL:GetCollectiblesFromPool(itemPoolType)) do
			if item == collectibleType then
				table.insert(itemPoolList, itemPoolType)
			end
		end
	end
	if #itemPoolList == 0 then
        return true
    else
        return false
    end
end

local function GetClosestCollectible(player)
    local minDistance = 192
    local collectible = nil
    for _, ent in pairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)) do
        local pickup = ent:ToPickup()
        if pickup:IsShopItem() and pickup.Price < 0 and pickup:GetPriceSprite():GetFilename() ~= "gfx/items/shops/broken_heart_deal.anm2" and (pickup.Position - player.Position):Length() < minDistance then
            minDistance = (pickup.Position - player.Position):Length()
            collectible = pickup
        end
    end
    return collectible
end

local function IsDevilAngelRoomOpened()
    local room = ty.GAME:GetRoom()
    for i = 0, 7 do
        local door = room:GetDoor(i)
        if door and (door.TargetRoomType == RoomType.ROOM_DEVIL or door.TargetRoomType == RoomType.ROOM_ANGEL) and door.TargetRoomIndex == GridRooms.ROOM_DEVIL_IDX then
            return true
        end
    end
    return false
end

local function GetHeartLimit(player)
    if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
        return 18
    else
        return 12
    end
end

function Warfarin:PostPlayerHUDRenderActiveItem(player, slot, offset, alpha, scale)
    if player:GetPlayerType() == ty.CustomPlayerType.WARFARIN and slot == ActiveSlot.SLOT_POCKET and scale == 1 then
        local hudOffset = Options.HUDOffset
        local renderPos = Vector(Isaac.GetScreenWidth() - 38 - 20 * hudOffset, Isaac.GetScreenHeight() - 28 - 12 * hudOffset)
        local data = ty:GetLibData(player)
        ty.LUAMIN:DrawString(string.format("%.1f%%", math.min(100, 100 * data.BloodSample.Percent)), renderPos.X, renderPos.Y, KColor(1, 1, 1, 1), 10, false)
    end
end
Warfarin:AddCallback(ModCallbacks.MC_POST_PLAYERHUD_RENDER_ACTIVE_ITEM, Warfarin.PostPlayerHUDRenderActiveItem)

function Warfarin:PostPlayerInit(player)
    local effects = player:GetEffects()
    if player:GetPlayerType() ~= ty.CustomPlayerType.WARFARIN then
        if effects:HasNullEffect(ty.CustomNullItemIDs.WARFARINHAIR) then
            effects:RemoveNullEffect(ty.CustomNullItemIDs.WARFARINHAIR)
        end
        if effects:HasNullEffect(ty.CustomNullItemIDs.WARFARINWINGS) then
            effects:RemoveNullEffect(ty.CustomNullItemIDs.WARFARINWINGS)
        end
        if effects:HasNullEffect(ty.CustomNullItemIDs.WARFARINHAEMOLACRIA) then
            effects:RemoveNullEffect(ty.CustomNullItemIDs.WARFARINHAEMOLACRIA)
        end
        if effects:HasNullEffect(ty.CustomNullItemIDs.WARFARINMAGIC8BALL) then
            effects:RemoveNullEffect(ty.CustomNullItemIDs.WARFARINMAGIC8BALL)
        end
        if effects:HasNullEffect(ty.CustomNullItemIDs.WARFARINCEREMONIALROBES) then
            effects:RemoveNullEffect(ty.CustomNullItemIDs.WARFARINCEREMONIALROBES)
        end
        if effects:HasNullEffect(ty.CustomNullItemIDs.WARFARINMOMSWIG) then
            effects:RemoveNullEffect(ty.CustomNullItemIDs.WARFARINMOMSWIG)
        end
        if effects:HasNullEffect(ty.CustomNullItemIDs.WARFARINBLACKCANDLE) then
            effects:RemoveNullEffect(ty.CustomNullItemIDs.WARFARINBLACKCANDLE)
        end
        if effects:HasNullEffect(ty.CustomNullItemIDs.WARFARINTAURUS) then
            effects:RemoveNullEffect(ty.CustomNullItemIDs.WARFARINTAURUS)
        end
        if effects:HasNullEffect(ty.CustomNullItemIDs.WARFARINLEO) then
            effects:RemoveNullEffect(ty.CustomNullItemIDs.WARFARINLEO)
        end
        if effects:HasNullEffect(ty.CustomNullItemIDs.WARFARINFROZENHAIR) then
            effects:RemoveNullEffect(ty.CustomNullItemIDs.WARFARINFROZENHAIR)
        end
        if effects:HasNullEffect(ty.CustomNullItemIDs.WARFARINFROZENHAIR2) then
            effects:RemoveNullEffect(ty.CustomNullItemIDs.WARFARINFROZENHAIR2)
        end
        if effects:HasNullEffect(ty.CustomNullItemIDs.WARFARINFROZENHAIR3) then
            effects:RemoveNullEffect(ty.CustomNullItemIDs.WARFARINFROZENHAIR3)
        end
        if effects:HasNullEffect(ty.CustomNullItemIDs.WARFARINFROZENHAIR4) then
            effects:RemoveNullEffect(ty.CustomNullItemIDs.WARFARINFROZENHAIR4)
        end
        if effects:HasNullEffect(ty.CustomNullItemIDs.WARFARINCARDREADING) then
            effects:RemoveNullEffect(ty.CustomNullItemIDs.WARFARINCARDREADING)
        end
        if effects:HasNullEffect(ty.CustomNullItemIDs.WARFARINESAUJRHAIR) then
            effects:RemoveNullEffect(ty.CustomNullItemIDs.WARFARINESAUJRHAIR)
        end
        if effects:HasNullEffect(ty.CustomNullItemIDs.WARFARINGUPPYWINGS) then
            effects:RemoveNullEffect(ty.CustomNullItemIDs.WARFARINGUPPYWINGS)
        end
        if effects:HasNullEffect(ty.CustomNullItemIDs.WARFARINREVERSEEMPRESS) then
            effects:RemoveNullEffect(ty.CustomNullItemIDs.WARFARINREVERSEEMPRESS)
        end
    end
end
--Warfarin:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, Warfarin.PostPlayerInit)

function Warfarin:PostPlayerUpdate(player)
    local room = ty.GAME:GetRoom()
    if not ty.PERSISTENTGAMEDATA:Unlocked(ty.CustomAchievements.FF0UNLOCKED) and player:GetMaxHearts() >= 24 then
        ty.PERSISTENTGAMEDATA:TryUnlock(ty.CustomAchievements.FF0UNLOCKED)
    end
    local data = ty:GetLibData(player)
    local effects = player:GetEffects()
    if not data.Init or not data.BloodSample or player:GetPlayerType() ~= ty.CustomPlayerType.WARFARIN then
        return
    end
    if ty.LEVEL:GetAbsoluteStage() == LevelStage.STAGE8 and ty.LEVEL:GetCurrentRoomIndex() == 94 and room:GetFrameCount() >= 5 and not ty.PERSISTENTGAMEDATA:Unlocked(ty.CustomAchievements.SOULOFFF0UNLOCKED) then
        ty.PERSISTENTGAMEDATA:TryUnlock(ty.CustomAchievements.SOULOFFF0UNLOCKED)
    end
    data.BloodSample.Percent = data.BloodSample.Percent + 0.5 * room:GetEnemyDamageInflicted() / GetDamagePerCharge(player)
    if data.BloodSample.Percent >= 1 then
        data.BloodSample.Percent = data.BloodSample.Percent - 1
        player:AddActiveCharge(1, ActiveSlot.SLOT_POCKET, true, true, true)
    end
    local globalData = ty.GLOBALDATA
    if player:GetMaxHearts() + player:GetBoneHearts() * 2 > 6 and effects:HasNullEffect(ty.CustomNullItemIDs.WARFARINHAEMOLACRIA) then
        effects:RemoveNullEffect(ty.CustomNullItemIDs.WARFARINHAEMOLACRIA)
        if not globalData.BloodSample.OutTriggered then
            ItemOverlay.Show(ty.CustomGiantBooks.WARFARINOUT, 3, player)
            globalData.BloodSample.OutTriggered = true
        end
    elseif player:GetMaxHearts() + player:GetBoneHearts() * 2 <= 6 and not effects:HasNullEffect(ty.CustomNullItemIDs.WARFARINHAEMOLACRIA) then
        effects:AddNullEffect(ty.CustomNullItemIDs.WARFARINHAEMOLACRIA)
        if not globalData.BloodSample.InTriggered then
            ItemOverlay.Show(ty.CustomGiantBooks.WARFARININ, 3, player)
            globalData.BloodSample.InTriggered = true
        end
    end
    local collectible = GetClosestCollectible(player)
    local charge = player:GetActiveCharge(ActiveSlot.SLOT_POCKET) + player:GetBatteryCharge(ActiveSlot.SLOT_POCKET)
    if collectible and room:IsClear() then
        if player:GetActiveItem(ActiveSlot.SLOT_POCKET) == ty.CustomCollectibles.BLOODSAMPLE then
            player:SetPocketActiveItem(ty.CustomCollectibles.BLOODYDICE, ActiveSlot.SLOT_POCKET, true)
            player:SetActiveCharge(charge, ActiveSlot.SLOT_POCKET)
        end
    else
        if player:GetActiveItem(ActiveSlot.SLOT_POCKET) == ty.CustomCollectibles.BLOODYDICE then
            player:SetPocketActiveItem(ty.CustomCollectibles.BLOODSAMPLE, ActiveSlot.SLOT_POCKET, true)
            player:SetActiveCharge(charge, ActiveSlot.SLOT_POCKET)
        end
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_GNAWED_LEAF) and player:GetGnawedLeafTimer() >= 60 and not effects:HasNullEffect(ty.CustomNullItemIDs.WARFARINFROZENHAIR) then
        effects:AddNullEffect(ty.CustomNullItemIDs.WARFARINFROZENHAIR)
    end
    if player:GetGnawedLeafTimer() < 60 and effects:HasNullEffect(ty.CustomNullItemIDs.WARFARINFROZENHAIR) then
        effects:RemoveNullEffect(ty.CustomNullItemIDs.WARFARINFROZENHAIR)
    end
    if effects:HasNullEffect(NullItemID.ID_TOOTH_AND_NAIL) and not effects:HasNullEffect(ty.CustomNullItemIDs.WARFARINFROZENHAIR2) then
        effects:AddNullEffect(ty.CustomNullItemIDs.WARFARINFROZENHAIR2)
    end
    if not effects:HasNullEffect(NullItemID.ID_TOOTH_AND_NAIL) and effects:HasNullEffect(ty.CustomNullItemIDs.WARFARINFROZENHAIR2) then
        effects:RemoveNullEffect(ty.CustomNullItemIDs.WARFARINFROZENHAIR2)
    end
    if not effects:HasNullEffect(NullItemID.ID_ESAU_JR) and effects:HasNullEffect(ty.CustomNullItemIDs.WARFARINESAUJRHAIR) then
        effects:RemoveNullEffect(ty.CustomNullItemIDs.WARFARINESAUJRHAIR)
    end
    if effects:HasNullEffect(NullItemID.ID_ESAU_JR) and not effects:HasNullEffect(ty.CustomNullItemIDs.WARFARINESAUJRHAIR) then
        effects:AddNullEffect(ty.CustomNullItemIDs.WARFARINESAUJRHAIR)
    end
    if player:GetPlayerFormCounter(PlayerForm.PLAYERFORM_GUPPY) >= 3 and not effects:HasNullEffect(ty.CustomNullItemIDs.WARFARINGUPPYWINGS) then
        effects:AddNullEffect(ty.CustomNullItemIDs.WARFARINGUPPYWINGS)
    end
    if player:GetPlayerFormCounter(PlayerForm.PLAYERFORM_GUPPY) < 3 and effects:HasNullEffect(ty.CustomNullItemIDs.WARFARINGUPPYWINGS) then
        effects:RemoveNullEffect(ty.CustomNullItemIDs.WARFARINGUPPYWINGS)
    end
    if not effects:HasNullEffect(NullItemID.ID_REVERSE_EMPRESS) and effects:HasNullEffect(ty.CustomNullItemIDs.WARFARINREVERSEEMPRESS) then
        effects:RemoveNullEffect(ty.CustomNullItemIDs.WARFARINREVERSEEMPRESS)
    end
    if effects:HasNullEffect(NullItemID.ID_REVERSE_EMPRESS) and not effects:HasNullEffect(ty.CustomNullItemIDs.WARFARINREVERSEEMPRESS) then
        effects:AddNullEffect(ty.CustomNullItemIDs.WARFARINREVERSEEMPRESS)
    end
end
Warfarin:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Warfarin.PostPlayerUpdate)

function Warfarin:PrePlayerAddHearts(player, amount, addHealthType, _)
    if player:GetPlayerType() == ty.CustomPlayerType.WARFARIN and amount > 0 and not (ty.PERSISTENTDATA.GlowingHourglass or ty.PERSISTENTDATA.Rewind) then
        if addHealthType & AddHealthType.SOUL == AddHealthType.SOUL or addHealthType & AddHealthType.BLACK == AddHealthType.BLACK then
            for i = 1, amount do
                if player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) == CollectibleType.COLLECTIBLE_ALABASTER_BOX and player:GetActiveCharge(ActiveSlot.SLOT_PRIMARY) < 12 then
                    player:AddActiveCharge(1, ActiveSlot.SLOT_PRIMARY, true, false, true)
                elseif player:GetActiveItem(ActiveSlot.SLOT_SECONDARY) == CollectibleType.COLLECTIBLE_ALABASTER_BOX and player:GetActiveCharge(ActiveSlot.SLOT_SECONDARY) < 12 then
                    player:AddActiveCharge(1, ActiveSlot.SLOT_SECONDARY, true, false, true)
                else
                    player:AddActiveCharge(1, ActiveSlot.SLOT_POCKET, true, true, true)
                end
            end
            return 0
        elseif player:GetEffects():HasNullEffect(ty.CustomNullItemIDs.WARFARINHAEMOLACRIA) and addHealthType & AddHealthType.RED == AddHealthType.RED then
            return amount * 2
        elseif addHealthType & AddHealthType.MAX == AddHealthType.MAX then
            return math.min(amount, GetHeartLimit(player) - player:GetMaxHearts() - player:GetBoneHearts() * 2)
        end
    end
end
Warfarin:AddCallback(ModCallbacks.MC_PRE_PLAYER_ADD_HEARTS, Warfarin.PrePlayerAddHearts)

function Warfarin:PrePickupCollision(pickup, collider, low)
    local player = collider:ToPlayer()
    if player and player:GetPlayerType() == ty.CustomPlayerType.WARFARIN and pickup.SubType == HeartSubType.HEART_BONE and player:GetMaxHearts() + player:GetBoneHearts() * 2 >= GetHeartLimit(player) then
        return { Collide = true, SkipCollisionEffects = true }
    end
end
Warfarin:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, Warfarin.PrePickupCollision, PickupVariant.PICKUP_HEART)

function Warfarin:PreTriggerPlayerDeath(player)
    if player:GetPlayerType() == ty.CustomPlayerType.WARFARIN and player:GetExtraLives() > 0 and player:GetMaxHearts() + player:GetBoneHearts() == 0 then
        shouldReviveWithRedHearts = true
    end
end
Warfarin:AddCallback(ModCallbacks.MC_PRE_TRIGGER_PLAYER_DEATH, Warfarin.PreTriggerPlayerDeath)

function Warfarin:PostHUDUpdate()
    for _, player in pairs(PlayerManager.GetPlayers()) do
        local data = ty:GetLibData(player)
        if player:GetPlayerType() == ty.CustomPlayerType.WARFARIN then
            if PlayerManager.GetEsauJrState(functions:GetPlayerIndex(player)) and player:GetBlackHearts() > 0 then
                player:AddMaxHearts(2)
                player:AddHearts(2)
            end
            if shouldReviveWithRedHearts then
                player:AddSoulHearts(-99)
                player:AddMaxHearts(2)
                player:AddHearts(2)
                shouldReviveWithRedHearts = false
            end
            if player:GetSoulHearts() > 0 then
                player:AddSoulHearts(-player:GetSoulHearts())
            end
            if player:GetBlackHearts() > 0 then
                player:AddBlackHearts(-player:GetBlackHearts())
            end
            if player:GetMaxHearts() + player:GetBoneHearts() * 2 > GetHeartLimit(player) then
                player:AddBoneHearts((GetHeartLimit(player) - player:GetMaxHearts() - player:GetBoneHearts() * 2) / 2)
            end
            if player:GetMaxHearts() + player:GetBoneHearts() == 0 and player:GetSprite():GetAnimation() == "Death" and player:GetSprite():GetFrame() == 56 and player:WillPlayerRevive() then
                player:AddMaxHearts(2)
            end
        end
    end
end
Warfarin:AddCallback(ModCallbacks.MC_POST_HUD_UPDATE, Warfarin.PostHUDUpdate)

function Warfarin:PreRoomExit(player, newLevel)
    local room = ty.GAME:GetRoom()
    if room:GetType() == RoomType.ROOM_BOSS then
        bossItemList = {}
        for _, ent in pairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)) do
            local pickup = ent:ToPickup()
            if not pickup:IsShopItem() then
                table.insert(bossItemList, pickup.InitSeed)
            end
        end
    end
end
Warfarin:AddCallback(ModCallbacks.MC_PRE_ROOM_EXIT, Warfarin.PreRoomExit)

function Warfarin:PostPickupUpdate(pickup)
    local room = ty.GAME:GetRoom()
    local pickup = pickup:ToPickup()
    local itemConfig = ty.ITEMCONFIG:GetCollectible(pickup.SubType)
    local globalData = ty.GLOBALDATA.BloodSample
    if not globalData or not PlayerManager.AnyoneIsPlayerType(ty.CustomPlayerType.WARFARIN) or ty.LEVEL:GetDimension() == Dimension.DEATH_CERTIFICATE or ty.LEVEL:GetCurrentRoomIndex() == GridRooms.ROOM_GENESIS_IDX or room:GetType() == RoomType.ROOM_SHOP or room:GetType() == RoomType.ROOM_ANGEL or pickup.SubType <= 0 then
        return
    end
    if (room:GetType() == RoomType.ROOM_BOSS and pickup.ShopItemId ~= -2 and not ty:IsValueInTable(bossItemList, pickup.InitSeed) and pickup.FrameCount <= 1 and not pickup.Touched and not itemConfig:HasTags(ItemConfig.TAG_QUEST) and not IsCollectibleHasNoItemPool(pickup.SubType)) or (pickup:GetAlternatePedestal() == 0 and not ty:IsValueInTable(globalData.ItemList, pickup.InitSeed) and pickup.ShopItemId ~= -2 and not pickup.Touched and not itemConfig:HasTags(ItemConfig.TAG_QUEST) and not IsCollectibleHasNoItemPool(pickup.SubType)) then
        pickup:MakeShopItem(-2)
    end
    if not ty:IsValueInTable(globalData.ItemList, pickup.InitSeed) then
        table.insert(globalData.ItemList, pickup.InitSeed)
    end
end
Warfarin:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, Warfarin.PostPickupUpdate, PickupVariant.PICKUP_COLLECTIBLE)

function Warfarin:UseItem(itemID, rng, player, useFlags, activeSlot, varData)
    if useFlags & UseFlag.USE_CARBATTERY == UseFlag.USE_CARBATTERY then
        return { Discharge = false, Remove = false, ShowAnim = false }
    end
    local data = ty:GetLibData(player)
    if itemID == ty.CustomCollectibles.BLOODYDICE then
        local collectible = GetClosestCollectible(player)
        if collectible then
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, collectible.Position, Vector(0, 0), nil)
            collectible:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, functions:GetCollectibleFromCurrentRoom(true, nil, rng, collectible.SubType), true, false, false)
            collectible.ShopItemId = -2
            collectible.Price = 0
            collectible:ClearEntityFlags(EntityFlag.FLAG_ITEM_SHOULD_DUPLICATE)
            data.Warfarin.UsedCount = data.Warfarin.UsedCount + 1
            return { Discharge = true, Remove = false, ShowAnim = true }
        else
            return { Discharge = false, Remove = false, ShowAnim = false }
        end
    elseif itemID == ty.CustomCollectibles.BLOODSAMPLE then
        ty.SFXMANAGER:Play(SoundEffect.SOUND_SUPERHOLY, 0.6)
        player:AddMaxHearts(2)
        if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
            player:AddHearts(2)
        end
        data.Warfarin.UsedCount = data.Warfarin.UsedCount + 1
        return { Discharge = true, Remove = false, ShowAnim = true }
    elseif itemID == CollectibleType.COLLECTIBLE_DIPLOPIA or itemID == CollectibleType.COLLECTIBLE_CROOKED_PENNY then
        for _, ent in pairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)) do
            local pickup = ent:ToPickup()
            if pickup.FrameCount <= 1 then
                pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, pickup.SubType, true, false, false)
                pickup.ShopItemId = -2
                pickup.Price = 0
            end
        end
    end
end
Warfarin:AddCallback(ModCallbacks.MC_USE_ITEM, Warfarin.UseItem)

function Warfarin:PostAddCollectible(type, charge, firstTime, slot, varData, player)
    local effects = player:GetEffects()
    if player:GetPlayerType() == ty.CustomPlayerType.WARFARIN then
        if type == CollectibleType.COLLECTIBLE_ABADDON then
            player:AddMaxHearts(2)
            player:AddHearts(2)
        end
        if type == CollectibleType.COLLECTIBLE_CHARM_VAMPIRE then
            player:AddCacheFlags(CacheFlag.CACHE_FLYING, true)
            effects:RemoveNullEffect(ty.CustomNullItemIDs.WARFARINWINGS)
            effects:AddNullEffect(ty.CustomNullItemIDs.WARFARINWINGS)
        end
        if type == CollectibleType.COLLECTIBLE_BLOOD_BAG then
            player:AddHearts(99)
        end
        if (type == CollectibleType.COLLECTIBLE_MARROW or type == CollectibleType.COLLECTIBLE_DIVORCE_PAPERS) and player:GetMaxHearts() + player:GetBoneHearts() * 2 > GetHeartLimit(player) then
            player:AddBoneHearts(-1)
        end
        if type == CollectibleType.COLLECTIBLE_SPIRIT_OF_THE_NIGHT or type == CollectibleType.COLLECTIBLE_DEAD_DOVE then
            effects:RemoveNullEffect(ty.CustomNullItemIDs.WARFARINWINGS)
            effects:AddNullEffect(ty.CustomNullItemIDs.WARFARINWINGS)
        end
        if type == CollectibleType.COLLECTIBLE_MAGIC_8_BALL then
            effects:AddNullEffect(ty.CustomNullItemIDs.WARFARINMAGIC8BALL)
        end
        if type == CollectibleType.COLLECTIBLE_CEREMONIAL_ROBES then
            effects:AddNullEffect(ty.CustomNullItemIDs.WARFARINCEREMONIALROBES)
        end
        if type == CollectibleType.COLLECTIBLE_MOMS_WIG then
            effects:AddNullEffect(ty.CustomNullItemIDs.WARFARINMOMSWIG)
        end
        if type == CollectibleType.COLLECTIBLE_BLACK_CANDLE then
            effects:AddNullEffect(ty.CustomNullItemIDs.WARFARINBLACKCANDLE)
        end
        if type == CollectibleType.COLLECTIBLE_TAURUS then
            effects:AddNullEffect(ty.CustomNullItemIDs.WARFARINTAURUS)
        end
        if type == CollectibleType.COLLECTIBLE_LEO then
            effects:AddNullEffect(ty.CustomNullItemIDs.WARFARINLEO)
        end
        if type == CollectibleType.COLLECTIBLE_INTRUDER then
            player:RemoveCostume(ty.ITEMCONFIG:GetCollectible(CollectibleType.COLLECTIBLE_INTRUDER))
        end
        if type == CollectibleType.COLLECTIBLE_TERRA then
            effects:AddNullEffect(ty.CustomNullItemIDs.WARFARINFROZENHAIR3)
        end
        if type == CollectibleType.COLLECTIBLE_JUPITER then
            player:RemoveCostume(ty.ITEMCONFIG:GetCollectible(CollectibleType.COLLECTIBLE_JUPITER))
        end
        if type == CollectibleType.COLLECTIBLE_URANUS then
            effects:AddNullEffect(ty.CustomNullItemIDs.WARFARINFROZENHAIR4)
        end
        if type == CollectibleType.COLLECTIBLE_CARD_READING then
            effects:AddNullEffect(ty.CustomNullItemIDs.WARFARINCARDREADING)
        end
        if type == CollectibleType.COLLECTIBLE_C_SECTION then
            player:RemoveCostume(ty.ITEMCONFIG:GetCollectible(CollectibleType.COLLECTIBLE_C_SECTION))
        end
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)
    end
end
Warfarin:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, Warfarin.PostAddCollectible)

function Warfarin:PostTriggerCollectibleRemoved(player, type)
    local effects = player:GetEffects()
    if type == CollectibleType.COLLECTIBLE_CHARM_VAMPIRE then
        player:EvaluateItems()
        effects:RemoveNullEffect(ty.CustomNullItemIDs.WARFARINWINGS)
    end
    if type == CollectibleType.COLLECTIBLE_SPIRIT_OF_THE_NIGHT or type == CollectibleType.COLLECTIBLE_DEAD_DOVE then
        effects:RemoveNullEffect(ty.CustomNullItemIDs.WARFARINWINGS)
    end
    if type == CollectibleType.COLLECTIBLE_MAGIC_8_BALL then
	    effects:RemoveNullEffect(ty.CustomNullItemIDs.WARFARINMAGIC8BALL)
	end
    if type == CollectibleType.COLLECTIBLE_CEREMONIAL_ROBES then
	    effects:RemoveNullEffect(ty.CustomNullItemIDs.WARFARINCEREMONIALROBES)
	end
    if type == CollectibleType.COLLECTIBLE_MOMS_WIG then
	    effects:RemoveNullEffect(ty.CustomNullItemIDs.WARFARINMOMSWIG)
	end
    if type == CollectibleType.COLLECTIBLE_BLACK_CANDLE then
	    effects:RemoveNullEffect(ty.CustomNullItemIDs.WARFARINBLACKCANDLE)
	end
    if type == CollectibleType.COLLECTIBLE_TAURUS then
        effects:RemoveNullEffect(ty.CustomNullItemIDs.WARFARINTAURUS)
    end
    if type == CollectibleType.COLLECTIBLE_LEO then
	    effects:RemoveNullEffect(ty.CustomNullItemIDs.WARFARINLEO)
	end
    if type == CollectibleType.COLLECTIBLE_TERRA then
        effects:RemoveNullEffect(ty.CustomNullItemIDs.WARFARINFROZENHAIR3)
    end
    if type == CollectibleType.COLLECTIBLE_URANUS then
        effects:RemoveNullEffect(ty.CustomNullItemIDs.WARFARINFROZENHAIR4)
    end
    if type == CollectibleType.COLLECTIBLE_CARD_READING then
        effects:RemoveNullEffect(ty.CustomNullItemIDs.WARFARINCARDREADING)
    end
end
Warfarin:AddCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_REMOVED, Warfarin.PostTriggerCollectibleRemoved)

function Warfarin:PostPickupShopPurchase(pickup, player, moneySpent)
    if player:GetPlayerType() == ty.CustomPlayerType.WARFARIN then
        local room = ty.GAME:GetRoom()
        if moneySpent < 0 and moneySpent > PickupPrice.PRICE_FREE and pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE and not (room:GetType() == RoomType.ROOM_DEVIL or (room:GetType() == RoomType.ROOM_BOSS and ty.LEVEL:GetStateFlag(LevelStateFlag.STATE_SATANIC_BIBLE_USED))or (ty.LEVEL:GetAbsoluteStage() == LevelStage.STAGE6 and ty.LEVEL:GetStageType() == StageType.STAGETYPE_ORIGINAL and ty.LEVEL:GetCurrentRoomIndex() == ty.LEVEL:GetStartingRoomIndex())) then
            ty.GAME:AddDevilRoomDeal()
        end
    end
end
Warfarin:AddCallback(ModCallbacks.MC_POST_PICKUP_SHOP_PURCHASE, Warfarin.PostPickupShopPurchase)

function Warfarin:EvaluateCache(player, cacheFlag)
    if player:GetPlayerType() == ty.CustomPlayerType.WARFARIN then
        local effects = player:GetEffects()
        if cacheFlag == CacheFlag.CACHE_DAMAGE then
            stat:AddFlatDamage(player, 0.2 * ty.GAME:GetDevilRoomDeals())
        elseif cacheFlag == CacheFlag.CACHE_FLYING and effects:HasNullEffect(ty.CustomNullItemIDs.WARFARINWINGS) and not player:HasCurseMistEffect() then
            player.CanFly = true
        elseif effects:HasNullEffect(ty.CustomNullItemIDs.WARFARINHAEMOLACRIA) then
            if cacheFlag == CacheFlag.CACHE_TEARFLAG then
                player.TearFlags = player.TearFlags | TearFlags.TEAR_BURSTSPLIT
            end
            if cacheFlag == CacheFlag.CACHE_FIREDELAY then
                stat:AddTearsMultiplier(player, 0.8)
            end
            if cacheFlag == CacheFlag.CACHE_SPEED then
                stat:AddSpeedUp(player, 0.15)
            end
        end
    end
end
Warfarin:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Warfarin.EvaluateCache)

function Warfarin:PostFireTear(tear)
    local tear = tear:ToTear()
    local player = tear.SpawnerEntity:ToPlayer()
    if player and player:GetPlayerType() == ty.CustomPlayerType.WARFARIN then
        if player:GetEffects():HasNullEffect(ty.CustomNullItemIDs.WARFARINHAEMOLACRIA) and tear.Variant == TearVariant.BLUE then
            tear:ChangeVariant(TearVariant.BLOOD)
        end
        if player:HasCollectible(CollectibleType.COLLECTIBLE_POLYPHEMUS) then
            local angle = tear.Velocity:GetAngleDegrees()
            if angle == 0 then
                tear.Position = tear.Position + Vector(0, 4)
            elseif angle == 90 then
                tear.Position = tear.Position + Vector(-10, 0)
            elseif angle == 180 then
                tear.Position = tear.Position + Vector(0, -4)
            elseif angle == -90 then
                tear.Position = tear.Position + Vector(10, 0)
            end
        end
    end
end
Warfarin:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, Warfarin.PostFireTear)

function Warfarin:PrePlayerTakeDamage(player, amount, flags, source, countdown)
	if player:GetPlayerType() == ty.CustomPlayerType.WARFARIN and not stopHurtSound then
        stopHurtSound = true
    elseif player:GetPlayerType() ~= ty.CustomPlayerType.WARFARIN and stopHurtSound then
        stopHurtSound = false
    end
end
Warfarin:AddCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, Warfarin.PrePlayerTakeDamage)

function Warfarin:PreSFXPlay(id, volume, frameDelay, loop, pitch, pan)
	if stopHurtSound then
        stopHurtSound = false
        return {ty.CustomSounds.WARFARINHURT, volume, frameDelay, loop, pitch, pan}
    end
end
Warfarin:AddCallback(ModCallbacks.MC_PRE_SFX_PLAY, Warfarin.PreSFXPlay, SoundEffect.SOUND_ISAAC_HURT_GRUNT)

function Warfarin:PreSpawnCleanAward(rng, spawnPosition)
    local room = ty.GAME:GetRoom()
    if PlayerManager.AnyoneIsPlayerType(ty.CustomPlayerType.WARFARIN) and room:GetType() == RoomType.ROOM_BOSS and room:IsCurrentRoomLastBoss() and ty.LEVEL:GetAbsoluteStage() < LevelStage.STAGE4_2 and not (ty.LEVEL:GetAbsoluteStage() == LevelStage.STAGE4_1 and ty.LEVEL:GetCurses() & LevelCurse.CURSE_OF_LABYRINTH == LevelCurse.CURSE_OF_LABYRINTH) and not ty.LEVEL:IsAscent() and not room:IsMirrorWorld() and not ty.GAME:IsGreedMode() then
        replaceTrapDoor = not IsDevilAngelRoomOpened()
    end
end
Warfarin:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, Warfarin.PreSpawnCleanAward)

function Warfarin:PostGridEntitySpawn(grid)
    local globalData = ty.GLOBALDATA
    local room = ty.GAME:GetRoom()
    if replaceTrapDoor then
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.ISAACS_CARPET, ty.CustomEffects.WARFARINBLACKMARKETCRAWLSPACE, grid.Position, Vector(0, 0), nil)
        globalData.BloodSample.BossDefeated = true
        globalData.BloodSample.GridIndex = room:GetGridIndex(grid.Position)
        room:RemoveGridEntity(globalData.BloodSample.GridIndex, 0, false)
        replaceTrapDoor = false
    end
end
Warfarin:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_SPAWN, Warfarin.PostGridEntitySpawn, GridEntityType.GRID_TRAPDOOR)

function Warfarin:PostNewRoom()
    local room = ty.GAME:GetRoom()
    local globalData = ty.GLOBALDATA
    if PlayerManager.AnyoneIsPlayerType(ty.CustomPlayerType.WARFARIN) and globalData.BloodSample then
        if ty.ITEMPOOL:HasCollectible(CollectibleType.COLLECTIBLE_POUND_OF_FLESH) then
            ty.ITEMPOOL:RemoveCollectible(CollectibleType.COLLECTIBLE_POUND_OF_FLESH)
        end
        if ty.ITEMPOOL:HasCollectible(CollectibleType.COLLECTIBLE_DAMOCLES) then
            ty.ITEMPOOL:RemoveCollectible(CollectibleType.COLLECTIBLE_DAMOCLES)
        end
        local roomType = room:GetType()
        if roomType == RoomType.ROOM_BLACK_MARKET and globalData.BloodSample.BossDefeated and ty.LEVEL:GetCurrentRoomIndex() ~= GridRooms.ROOM_DEBUG_IDX then
            Isaac.Spawn(EntityType.ENTITY_EFFECT, ty.CustomEffects.WARFARINBLACKMARKETLADDER, 0, Vector(200, 160), Vector(0, 0), nil)
            room:RemoveGridEntity(room:GetGridIndex(Vector(200, 160)), 0, false)
            for _, player in pairs(PlayerManager.GetPlayers()) do
                player.Position = Vector(200, 280)
            end
        end
        if roomType == RoomType.ROOM_BLACK_MARKET and ty.LEVEL:GetCurrentRoomDesc().Data.Variant == 7 and room:IsFirstVisit() then
            for _, ent in pairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)) do
                local pickup = ent:ToPickup()
                pickup.ShopItemId = -2
                pickup.Price = 0
            end
            for _, ent in pairs(Isaac.FindByType(EntityType.ENTITY_SLOT, SlotVariant.SHOP_RESTOCK_MACHINE)) do
                ent:Remove()
            end
        end
        if roomType == RoomType.ROOM_BOSS and globalData.BloodSample.BossDefeated and ty.LEVEL:GetCurrentRoomIndex() == functions:GetLastBossRoomIndex() and not ty.LEVEL:IsAscent() and not room:IsMirrorWorld() and room:IsClear() then
            if restorePosition then
                for _, player in pairs(PlayerManager.GetPlayers()) do
                    player.Position = room:GetGridPosition(globalData.BloodSample.GridIndex)
                end
                restorePosition = false
            end
            room:RemoveGridEntity(globalData.BloodSample.GridIndex, 0, false)
            if #Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.ISAACS_CARPET, ty.CustomEffects.WARFARINBLACKMARKETCRAWLSPACE) == 0 then
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.ISAACS_CARPET, ty.CustomEffects.WARFARINBLACKMARKETCRAWLSPACE, room:GetGridPosition(globalData.BloodSample.GridIndex), Vector(0, 0), nil)
            end
        end
        globalData.BloodSample.InTriggered = false
        globalData.BloodSample.OutTriggered = false
    end
end
Warfarin:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Warfarin.PostNewRoom)

function Warfarin:PostNewLevel()
    local globalData = ty.GLOBALDATA
    if PlayerManager.AnyoneIsPlayerType(ty.CustomPlayerType.WARFARIN) and globalData.BloodSample then
        globalData.BloodSample.BossDefeated = false
        globalData.BloodSample.GridIndex = 37
    end
end
Warfarin:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, Warfarin.PostNewLevel)

function Warfarin:PostCrawlspaceUpdate(effect)
    local sprite = effect:GetSprite()
    local data = ty:GetLibData(effect)
    local room = ty.GAME:GetRoom()
    if effect.SubType == ty.CustomEffects.WARFARINBLACKMARKETCRAWLSPACE then
        if not sprite:IsPlaying("Closed") and not room:IsClear() then
            sprite:Play("Closed", true)
        end
        if sprite:IsPlaying("Closed") and #Isaac.FindInRadius(effect.Position, 24, EntityPartition.PLAYER) == 0 and room:IsClear() then
            sprite:Play("Open", true)
        end
        if sprite:IsFinished("Open") then
            sprite:Play("Opened", true)
        end
        if sprite:IsPlaying("Opened") then
            for _, ent in pairs(Isaac.FindInRadius(effect.Position, 8, EntityPartition.PLAYER)) do
                ty.GAME:StartRoomTransition(GridRooms.ROOM_BLACK_MARKET_IDX, Direction.NO_DIRECTION, RoomTransitionAnim.PIXELATION, ent:ToPlayer(), 0)
            end
        end
        if not PlayerManager.AnyoneIsPlayerType(ty.CustomPlayerType.WARFARIN) or ty.LEVEL:IsAscent() then
            room:SpawnGridEntity(room:GetGridIndex(effect.Position), GridEntityType.GRID_TRAPDOOR, 0, 0, 0)
            effect:Remove()
        end
    end
end
Warfarin:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, Warfarin.PostCrawlspaceUpdate, EffectVariant.ISAACS_CARPET)

function Warfarin:PostLadderUpdate(effect)
    local sprite = effect:GetSprite()
    if sprite:IsFinished("Idle") then
        if ty.GAME:GetRoom():IsClear() then
            sprite.Color = Color(1, 1, 1, 1)
            for _, ent in pairs(Isaac.FindInRadius(effect.Position, 8, EntityPartition.PLAYER)) do
                restorePosition = true
                ty.GAME:StartRoomTransition(functions:GetLastBossRoomIndex(), Direction.NO_DIRECTION, RoomTransitionAnim.PIXELATION, ent:ToPlayer(), 0)
            end
        else
            sprite.Color = Color(1, 1, 1, 0.1)
        end
    end
end
Warfarin:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, Warfarin.PostLadderUpdate, ty.CustomEffects.WARFARINBLACKMARKETLADDER)

function Warfarin:PostPickupMorph(pickup, type, variant, subType, keepPrice, keepSeed, ignoreModifiers)
    local globalData = ty.GLOBALDATA.BloodSample
    if PlayerManager.AnyoneIsPlayerType(ty.CustomPlayerType.WARFARIN) and (keepPrice and not keepSeed and not ignoreModifiers) or (keepPrice and keepSeed and ignoreModifiers) then
        if not ty:IsValueInTable(globalData.ItemList, pickup.InitSeed) then
            table.insert(globalData.ItemList, pickup.InitSeed)
        end
    end
end 
Warfarin:AddCallback(ModCallbacks.MC_POST_PICKUP_MORPH, Warfarin.PostPickupMorph)

function Warfarin:PreDevilApplyItems()
    if PlayerManager.AnyoneIsPlayerType(ty.CustomPlayerType.WARFARIN) then
        return 0.36
    end
end
Warfarin:AddCallback(ModCallbacks.MC_PRE_DEVIL_APPLY_ITEMS, Warfarin.PreDevilApplyItems)

return Warfarin