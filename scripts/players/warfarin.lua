local Warfarin = ty:DefineANewClass()

local shouldReviveWithRedHearts = false
local stopHurtSound = false
local restorePosition = false
local replaceTrapDoor = false

if CuerLib then
    CuerLib.Players.SetOnlyRedHeartPlayer(ty.CustomPlayerType.WARFARIN, true)
end

local function GetDamagePerCharge(player)
    local data = ty:GetLibData(player)
    local charge = 20 + math.log(data.Warfarin.UsedCount ^ 2 + 1) + (data.Warfarin.UsedCount) ^ 1.5 / 2
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
    local minDistance = 128
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

local function GetTears(player, tears)
    if player:HasWeaponType(WeaponType.WEAPON_TEARS) then
        tears = 0.8 * tears
    end
    if tears < 30 / 11 and player:HasCollectible(ty.CustomCollectibles.CONSERVATIVETREATMENT) then
        return 30 / 11
    end
    return tears
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
        ty.LUAMIN:DrawString(string.format("%.1f%%", math.min(100, 100 * data.BloodSample.DamageAmount / GetDamagePerCharge(player))), renderPos.X, renderPos.Y, KColor(1, 1, 1, 1), 10, false)
    end
end
Warfarin:AddCallback(ModCallbacks.MC_POST_PLAYERHUD_RENDER_ACTIVE_ITEM, Warfarin.PostPlayerHUDRenderActiveItem)

function Warfarin:PostPlayerUpdate(player)
    local data = ty:GetLibData(player)
    local effects = player:GetEffects()
    local globalData = ty.GLOBALDATA
    if not ty.PERSISTENTGAMEDATA:Unlocked(ty.CustomAchievements.FF0UNLOCKED) and player:GetMaxHearts() >= 24 then
        ty.PERSISTENTGAMEDATA:TryUnlock(ty.CustomAchievements.FF0UNLOCKED)
    end
    if not data.Init then
        return
    end
    if player:GetPlayerType() ~= ty.CustomPlayerType.WARFARIN then
        if effects:HasNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINHAIR).ID) then
            effects:RemoveNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINHAIR).ID)
        end
        if effects:HasNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINWINGS).ID) then
            effects:RemoveNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINWINGS).ID)
        end
        if effects:HasNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINHAEMOLACRIA).ID) then
            effects:RemoveNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINHAEMOLACRIA).ID)
        end
        if effects:HasNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINMAGIC8BALL).ID) then
            effects:RemoveNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINMAGIC8BALL).ID)
        end
        if effects:HasNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINCEREMONIALROBES).ID) then
            effects:RemoveNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINCEREMONIALROBES).ID)
        end
        if effects:HasNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINMOMSWIG).ID) then
            effects:RemoveNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINMOMSWIG).ID)
        end
        if effects:HasNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINBLACKCANDLE).ID) then
            effects:RemoveNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINBLACKCANDLE).ID)
        end
        if effects:HasNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINTAURUS).ID) then
            effects:RemoveNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINTAURUS).ID)
        end
        if effects:HasNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINLEO).ID) then
            effects:RemoveNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINLEO).ID)
        end
        if effects:HasNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINFROZENHAIR).ID) then
            effects:RemoveNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINFROZENHAIR).ID)
        end
        if effects:HasNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINFROZENHAIR2).ID) then
            effects:RemoveNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINFROZENHAIR2).ID)
        end
        if effects:HasNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINFROZENHAIR3).ID) then
            effects:RemoveNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINFROZENHAIR3).ID)
        end
        if effects:HasNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINFROZENHAIR4).ID) then
            effects:RemoveNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINFROZENHAIR4).ID)
        end
        if effects:HasNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINCARDREADING).ID) then
            effects:RemoveNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINCARDREADING).ID)
        end
        if effects:HasNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINESAUJRHAIR).ID) then
            effects:RemoveNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINESAUJRHAIR).ID)
        end
        return
    end
    local room = ty.GAME:GetRoom()
    local damageAmountPerCharge = GetDamagePerCharge(player)
    data.BloodSample.DamageAmount = data.BloodSample.DamageAmount + room:GetEnemyDamageInflicted() / 2
    if data.BloodSample.DamageAmount >= damageAmountPerCharge then
        data.BloodSample.DamageAmount = data.BloodSample.DamageAmount - damageAmountPerCharge
        player:AddActiveCharge(1, ActiveSlot.SLOT_POCKET, true, true, true)
    end
    if player:GetMaxHearts() + player:GetBoneHearts() * 2 > 6 and effects:HasNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINHAEMOLACRIA).ID) then
        effects:RemoveNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINHAEMOLACRIA).ID)
        if not globalData.BloodSample.OutTriggered then
            ItemOverlay.Show(ty.CustomGiantBooks.WARFARINOUT, 3, player)
            globalData.BloodSample.OutTriggered = true
        end
    elseif player:GetMaxHearts() + player:GetBoneHearts() * 2 <= 6 and not effects:HasNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINHAEMOLACRIA).ID) then
        effects:AddNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINHAEMOLACRIA).ID)
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
            if player:IsExtraAnimationFinished() then
                player:AnimateCollectible(ty.CustomCollectibles.BLOODYDICE, "UseItem")
            end
        end
    else
        if player:GetActiveItem(ActiveSlot.SLOT_POCKET) == ty.CustomCollectibles.BLOODYDICE then
            player:SetPocketActiveItem(ty.CustomCollectibles.BLOODSAMPLE, ActiveSlot.SLOT_POCKET, true)
            player:SetActiveCharge(charge, ActiveSlot.SLOT_POCKET)
            if player:IsExtraAnimationFinished() then
                player:AnimateCollectible(ty.CustomCollectibles.BLOODSAMPLE, "UseItem")
            end
        end
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_GNAWED_LEAF) and player:GetGnawedLeafTimer() >= 60 and not effects:HasNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINFROZENHAIR).ID) then
        effects:AddNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINFROZENHAIR).ID)
    end
    if player:GetGnawedLeafTimer() < 60 and effects:HasNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINFROZENHAIR).ID) then
        effects:RemoveNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINFROZENHAIR).ID)
    end
    if effects:HasNullEffect(NullItemID.ID_TOOTH_AND_NAIL) and not effects:HasNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINFROZENHAIR2).ID) then
        effects:AddNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINFROZENHAIR2).ID)
    end
    if not effects:HasNullEffect(NullItemID.ID_TOOTH_AND_NAIL) and effects:HasNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINFROZENHAIR2).ID) then
        effects:RemoveNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINFROZENHAIR2).ID)
    end
    if not effects:HasNullEffect(NullItemID.ID_ESAU_JR) and effects:HasNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINESAUJRHAIR).ID) then
        effects:RemoveNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINESAUJRHAIR).ID)
    end
    if effects:HasNullEffect(NullItemID.ID_ESAU_JR) and not effects:HasNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINESAUJRHAIR).ID) then
        effects:AddNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINESAUJRHAIR).ID)
    end
    if player:GetPlayerFormCounter(PlayerForm.PLAYERFORM_GUPPY) >= 3 and not effects:HasNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINGUPPYWINGS).ID) then
        effects:AddNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINGUPPYWINGS).ID)
    end
    if player:GetPlayerFormCounter(PlayerForm.PLAYERFORM_GUPPY) < 3 and effects:HasNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINGUPPYWINGS).ID) then
        effects:RemoveNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINGUPPYWINGS).ID)
    end
    if not effects:HasNullEffect(NullItemID.ID_REVERSE_EMPRESS) and effects:HasNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINREVERSEEMPRESS).ID) then
        effects:RemoveNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINREVERSEEMPRESS).ID)
    end
    if effects:HasNullEffect(NullItemID.ID_REVERSE_EMPRESS) and not effects:HasNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINREVERSEEMPRESS).ID) then
        effects:AddNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINREVERSEEMPRESS).ID)
    end
end
Warfarin:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Warfarin.PostPlayerUpdate)

function Warfarin:PrePlayerAddHearts(player, amount, addHealthType, _)
    if player:GetPlayerType() == ty.CustomPlayerType.WARFARIN and amount > 0 then
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
        elseif player:GetEffects():HasNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINHAEMOLACRIA).ID) and addHealthType & AddHealthType.RED == AddHealthType.RED then
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
            if PlayerManager.GetEsauJrState(ty:GetPlayerIndex(player)) and player:GetBlackHearts() > 0 then
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
        end
    end
end
Warfarin:AddCallback(ModCallbacks.MC_POST_HUD_UPDATE, Warfarin.PostHUDUpdate)

function Warfarin:PreRoomExit(player, newLevel)
    local room = ty.GAME:GetRoom()
    local globalData = ty.GLOBALDATA.BloodSample
    if room:GetType() == RoomType.ROOM_BOSS and room:IsFirstVisit() then
        globalData.BossItemList = {}
        for _, ent in pairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)) do
            local pickup = ent:ToPickup()
            if pickup:IsShopItem() then
                table.insert(globalData.BossItemList, pickup.InitSeed)
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
    if ty:IsValueInTable(pickup.InitSeed, globalData.BossItemList) then
        pickup:MakeShopItem(-2)
        ty:RemoveValueInTable(pickup.InitSeed, globalData.BossItemList)
    end
    if pickup:GetAlternatePedestal() == 0 and not ty:IsValueInTable(pickup.InitSeed, globalData.ItemList) and pickup.ShopItemId ~= -2 and not pickup.Touched and not itemConfig:HasTags(ItemConfig.TAG_QUEST) and not IsCollectibleHasNoItemPool(pickup.SubType) then
        pickup:MakeShopItem(-2)
    end
    if not ty:IsValueInTable(pickup.InitSeed, globalData.ItemList) then
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
            collectible:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, ty:GetCollectibleFromCurrentRoom(true, nil, rng, collectible.SubType))
            collectible.ShopItemId = -2
            collectible.Price = 0
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
            effects:RemoveNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINWINGS).ID)
            effects:AddNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINWINGS).ID)
        end
        if type == CollectibleType.COLLECTIBLE_BLOOD_BAG then
            player:AddHearts(99)
        end
        if (type == CollectibleType.COLLECTIBLE_MARROW or type == CollectibleType.COLLECTIBLE_DIVORCE_PAPERS) and player:GetMaxHearts() + player:GetBoneHearts() * 2 > GetHeartLimit(player) then
            player:AddBoneHearts(-1)
        end
        if type == CollectibleType.COLLECTIBLE_SPIRIT_OF_THE_NIGHT or type == CollectibleType.COLLECTIBLE_DEAD_DOVE then
            effects:RemoveNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINWINGS).ID)
            effects:AddNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINWINGS).ID)
        end
        if type == CollectibleType.COLLECTIBLE_MAGIC_8_BALL then
            effects:AddNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINMAGIC8BALL).ID)
        end
        if type == CollectibleType.COLLECTIBLE_CEREMONIAL_ROBES then
            effects:AddNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINCEREMONIALROBES).ID)
        end
        if type == CollectibleType.COLLECTIBLE_MOMS_WIG then
            effects:AddNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINMOMSWIG).ID)
        end
        if type == CollectibleType.COLLECTIBLE_BLACK_CANDLE then
            effects:AddNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINBLACKCANDLE).ID)
        end
        if type == CollectibleType.COLLECTIBLE_TAURUS then
            effects:AddNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINTAURUS).ID)
        end
        if type == CollectibleType.COLLECTIBLE_LEO then
            effects:AddNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINLEO).ID)
        end
        if type == CollectibleType.COLLECTIBLE_INTRUDER then
            player:RemoveCostume(ty.ITEMCONFIG:GetCollectible(CollectibleType.COLLECTIBLE_INTRUDER))
        end
        if type == CollectibleType.COLLECTIBLE_TERRA then
            effects:AddNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINFROZENHAIR3).ID)
        end
        if type == CollectibleType.COLLECTIBLE_JUPITER then
            player:RemoveCostume(ty.ITEMCONFIG:GetCollectible(CollectibleType.COLLECTIBLE_JUPITER))
        end
        if type == CollectibleType.COLLECTIBLE_URANUS then
            effects:AddNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINFROZENHAIR4).ID)
        end
        if type == CollectibleType.COLLECTIBLE_CARD_READING then
            effects:AddNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINCARDREADING).ID)
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
        effects:RemoveNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINWINGS).ID)
    end
    if type == CollectibleType.COLLECTIBLE_SPIRIT_OF_THE_NIGHT or type == CollectibleType.COLLECTIBLE_DEAD_DOVE then
        effects:RemoveNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINWINGS).ID)
    end
    if type == CollectibleType.COLLECTIBLE_MAGIC_8_BALL then
	    effects:RemoveNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINMAGIC8BALL).ID)
	end
    if type == CollectibleType.COLLECTIBLE_CEREMONIAL_ROBES then
	    effects:RemoveNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINCEREMONIALROBES).ID)
	end
    if type == CollectibleType.COLLECTIBLE_MOMS_WIG then
	    effects:RemoveNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINMOMSWIG).ID)
	end
    if type == CollectibleType.COLLECTIBLE_BLACK_CANDLE then
	    effects:RemoveNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINBLACKCANDLE).ID)
	end
    if type == CollectibleType.COLLECTIBLE_TAURUS then
        effects:RemoveNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINTAURUS).ID)
    end
    if type == CollectibleType.COLLECTIBLE_LEO then
	    effects:RemoveNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINLEO).ID)
	end
    if type == CollectibleType.COLLECTIBLE_TERRA then
        effects:RemoveNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINFROZENHAIR3).ID)
    end
    if type == CollectibleType.COLLECTIBLE_URANUS then
        effects:RemoveNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINFROZENHAIR4).ID)
    end
    if type == CollectibleType.COLLECTIBLE_CARD_READING then
        effects:RemoveNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINCARDREADING).ID)
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
            ty.Stat:AddFlatDamage(player, 0.2 * ty.GAME:GetDevilRoomDeals())
        elseif cacheFlag == CacheFlag.CACHE_FLYING and player:HasCollectible(CollectibleType.COLLECTIBLE_CHARM_VAMPIRE) then
            player.CanFly = true
        elseif effects:HasNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINHAEMOLACRIA).ID) then
            if cacheFlag == CacheFlag.CACHE_TEARFLAG then
                player.TearFlags = player.TearFlags | TearFlags.TEAR_BURSTSPLIT
            end
            if cacheFlag == CacheFlag.CACHE_FIREDELAY then
                ty.Stat:AddTearsModifier(player, function(tears) return GetTears(player, tears) end)
            end
            if cacheFlag == CacheFlag.CACHE_SPEED then
                player.MoveSpeed = player.MoveSpeed + 0.15
            end
        end
    end
end
Warfarin:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Warfarin.EvaluateCache)

function Warfarin:PostFireTear(tear)
    local tear = tear:ToTear()
    local player = tear.SpawnerEntity:ToPlayer()
    if player and player:GetPlayerType() == ty.CustomPlayerType.WARFARIN then
        if player:GetEffects():HasNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINHAEMOLACRIA).ID) and tear.Variant == TearVariant.BLUE then
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

function Warfarin:PreDevilApplyItems()
    if PlayerManager.AnyoneIsPlayerType(ty.CustomPlayerType.WARFARIN) then
        return 0.36
    end
end
Warfarin:AddCallback(ModCallbacks.MC_PRE_DEVIL_APPLY_ITEMS, Warfarin.PreDevilApplyItems)

function Warfarin:PostGridEntitySpawn(grid)
    local globalData = ty.GLOBALDATA
    local room = ty.GAME:GetRoom()
    if replaceTrapDoor then
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.ISAACS_CARPET, ty.CustomEffects.WARFARINBLACKMARKETCRAWLSPACE, grid.Position, Vector(0, 0), nil)
        globalData.BloodSample.BossIndex = ty.LEVEL:GetCurrentRoomIndex()
        globalData.BloodSample.GridIndex = room:GetGridIndex(grid.Position)
        if not room:DestroyGrid(globalData.BloodSample.GridIndex, true) then
            room:RemoveGridEntity(globalData.BloodSample.GridIndex, 0, false)
        end
        replaceTrapDoor = false
    end
end
Warfarin:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_SPAWN, Warfarin.PostGridEntitySpawn, GridEntityType.GRID_TRAPDOOR)

function Warfarin:PreSpawnCleanAward(rng, spawnPosition)
    local room = ty.GAME:GetRoom()
    if PlayerManager.AnyoneIsPlayerType(ty.CustomPlayerType.WARFARIN) and room:GetType() == RoomType.ROOM_BOSS and room:IsCurrentRoomLastBoss() and ty.LEVEL:GetAbsoluteStage() < LevelStage.STAGE4_2 and not (ty.LEVEL:GetAbsoluteStage() == LevelStage.STAGE4_1 and ty.LEVEL:GetCurses() | LevelCurse.CURSE_OF_LABYRINTH == LevelCurse.CURSE_OF_LABYRINTH) and not ty.LEVEL:IsAscent() and not room:IsMirrorWorld() then
        replaceTrapDoor = not IsDevilAngelRoomOpened()
    end
end
Warfarin:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, Warfarin.PreSpawnCleanAward)

function Warfarin:PostNewRoom()
    local room = ty.GAME:GetRoom()
    local globalData = ty.GLOBALDATA
    if PlayerManager.AnyoneIsPlayerType(ty.CustomPlayerType.WARFARIN) and globalData.BloodSample then
        if room:GetType() == RoomType.ROOM_BLACK_MARKET and globalData.BloodSample.BossIndex > 0 and ty.LEVEL:GetCurrentRoomIndex() ~= GridRooms.ROOM_DEBUG_IDX then
            Isaac.Spawn(EntityType.ENTITY_EFFECT, ty.CustomEffects.WARFARINBLACKMARKETLADDER, 0, Vector(200, 160), Vector(0, 0), nil)
            if not room:DestroyGrid(room:GetGridIndex(Vector(200, 160)), true) then
                room:RemoveGridEntity(room:GetGridIndex(Vector(200, 160)), 0, false)
            end
        end
        if room:GetType() == RoomType.ROOM_BOSS and ty.LEVEL:GetCurrentRoomIndex() == globalData.BloodSample.BossIndex and not ty.LEVEL:IsAscent() and not room:IsMirrorWorld() then
            if restorePosition then
                for _, player in pairs(PlayerManager.GetPlayers()) do
                    player.Position = room:GetGridPosition(globalData.BloodSample.GridIndex)
                end
                restorePosition = false
            end
            if not room:DestroyGrid(globalData.BloodSample.GridIndex, true) then
                room:RemoveGridEntity(globalData.BloodSample.GridIndex, 0, false)
            end
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
        globalData.BloodSample.BossIndex = GridRooms.ROOM_ERROR_IDX
        globalData.BloodSample.GridIndex = 37
    end
end
Warfarin:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, Warfarin.PostNewLevel)

function Warfarin:PostCrawlspaceUpdate(effect)
    local sprite = effect:GetSprite()
    local data = ty:GetLibData(effect)
    local room = ty.GAME:GetRoom()
    if effect.SubType == ty.CustomEffects.WARFARINBLACKMARKETCRAWLSPACE then
        if sprite:IsPlaying("Closed") and #Isaac.FindInRadius(effect.Position, 24, EntityPartition.PLAYER) == 0 then
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
        if not PlayerManager.AnyoneIsPlayerType(ty.CustomPlayerType.WARFARIN) then
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
                ty.GAME:StartRoomTransition(ty.GLOBALDATA.BloodSample.BossIndex, Direction.NO_DIRECTION, RoomTransitionAnim.PIXELATION, ent:ToPlayer(), 0)
            end
        else
            sprite.Color = Color(1, 1, 1, 0.1)
        end
    end
end
Warfarin:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, Warfarin.PostLadderUpdate, ty.CustomEffects.WARFARINBLACKMARKETLADDER)

return Warfarin