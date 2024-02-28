local Warfarin = ty:DefineANewClass()

local deadByBrokenHearts = false
local stopHurtSound = false
local restorePosition = false
local replaceTrapDoor = false

if CuerLib then
    CuerLib.Players.SetOnlyRedHeartPlayer(ty.CustomPlayerType.WARFARIN, true)
end

local function GetDamagePerCharge(player)
    local stage = ty.LEVEL:GetAbsoluteStage()
    if ty.GAME:IsGreedMode() then
        stage = stage * 2
    end
    local charge = 16 + 19 * stage ^ 1.2
    if player:HasCollectible(CollectibleType.COLLECTIBLE_4_5_VOLT) then
        charge = charge * 0.9
    end
    return charge
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
    local minDistance = 8192
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

local function GetClosestEmptyPedestal(player)
    local minDistance = 8192
    local collectible = nil
    for _, pickup in pairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, 0)) do
        if (pickup.Position - player.Position):Length() < minDistance then
            minDistance = (pickup.Position - player.Position):Length()
            collectible = pickup:ToPickup()
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
    if player:HasWeaponType(WeaponType.WEAPON_TEARS) or player:HasWeaponType(WeaponType.WEAPON_FETUS) then
        if player:HasCollectible(ty.CustomCollectibles.CONSERVATIVETREATMENT) then
            return math.max(0.85 * tears, 30 / 11)
        else
            return 0.85 * tears
        end
    end
    return tears
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
    if not ty.PERSISTENTGAMEDATA:Unlocked(ty.CustomAchievements.FF0UNLOCKED) and player:GetMaxHearts() >= 24 then
        ty.PERSISTENTGAMEDATA:TryUnlock(ty.CustomAchievements.FF0UNLOCKED)
    end
    if not data.Init or player:GetPlayerType() ~= ty.CustomPlayerType.WARFARIN then
        return
    end
    local room = ty.GAME:GetRoom()
    local effects = player:GetEffects()
    local damageAmountPerCharge = GetDamagePerCharge(player)
    data.BloodSample.DamageAmount = data.BloodSample.DamageAmount + room:GetEnemyDamageInflicted() / 2
    if data.BloodSample.DamageAmount >= damageAmountPerCharge then
        data.BloodSample.DamageAmount = data.BloodSample.DamageAmount - damageAmountPerCharge
        player:AddActiveCharge(1, ActiveSlot.SLOT_POCKET, true, true, true)
    end
    if player:GetMaxHearts() > 6 and effects:HasNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINHAEMOLACRIA).ID) then
        effects:RemoveNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINHAEMOLACRIA).ID)
    elseif player:GetMaxHearts() <= 6 and not effects:HasNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINHAEMOLACRIA).ID) then
        effects:AddNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINHAEMOLACRIA).ID)
    end
end
Warfarin:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Warfarin.PostPlayerUpdate)

function Warfarin:PostHUDUpdate()
    for _, player in pairs(PlayerManager.GetPlayers()) do
        if player:GetPlayerType() == ty.CustomPlayerType.WARFARIN then
            local data = ty:GetLibData(player)
            if data.Init then
                if PlayerManager.GetEsauJrState(ty:GetPlayerIndex(player)) and player:GetBlackHearts() > 0 then
                    player:AddMaxHearts(2)
                    player:AddHearts(2)
                end
                if player:HasCollectible(CollectibleType.COLLECTIBLE_ALABASTER_BOX) and player:GetSoulHearts() + player:GetBlackHearts() > 0 then
                    for i = 1, 2 do
                        if player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) == CollectibleType.COLLECTIBLE_ALABASTER_BOX then
                            player:DropCollectible(CollectibleType.COLLECTIBLE_ALABASTER_BOX, GetClosestEmptyPedestal(player), true)
                        end
                    end
                end
                if player:GetSoulHearts() > 0 then
                    player:AddActiveCharge(player:GetSoulHearts(), ActiveSlot.SLOT_POCKET, true, true, true)
                    player:AddSoulHearts(-player:GetSoulHearts())
                end
                if player:GetBlackHearts() > 0 then
                    player:AddActiveCharge(player:GetSoulHearts(), ActiveSlot.SLOT_POCKET, true, true, true)
                    player:AddBlackHearts(-player:GetBlackHearts())
                end
                if not ty.PERSISTENTDATA.GlowingHourglass and not ty.PERSISTENTDATA.Rewind and player:GetEffects():HasNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINHAEMOLACRIA).ID) then
                    if player:GetHearts() > data.BloodSample.RedHearts then
                        player:AddHearts(player:GetHearts() - data.BloodSample.RedHearts)
                    end
                    data.BloodSample.RedHearts = player:GetHearts()
                end
                if deadByBrokenHearts then
                    player:AddMaxHearts(2)
                    player:AddHearts(2)
                    deadByBrokenHearts = false
                end    
            end
        end
    end
end
Warfarin:AddCallback(ModCallbacks.MC_POST_HUD_UPDATE, Warfarin.PostHUDUpdate)

function Warfarin:PostPickupUpdate(pickup)
    local room = ty.GAME:GetRoom()
    local itemConfig = ty.ITEMCONFIG:GetCollectible(pickup.SubType)
    if not PlayerManager.AnyoneIsPlayerType(ty.CustomPlayerType.WARFARIN) or ty.LEVEL:GetDimension() == Dimension.DEATH_CERTIFICATE or ty.LEVEL:GetCurrentRoomIndex() == GridRooms.ROOM_GENESIS_IDX or room:GetType() == RoomType.ROOM_SHOP or room:GetType() == RoomType.ROOM_ANGEL or pickup.SubType <= 0 or pickup:GetAlternatePedestal() ~= 0 then
        return
    end
    local pickup = pickup:ToPickup()
    if pickup.ShopItemId ~= -2 and not pickup.Touched and not itemConfig:HasTags(ItemConfig.TAG_QUEST) and not IsCollectibleHasNoItemPool(pickup.SubType) then
        pickup:MakeShopItem(-2)
    end
end
Warfarin:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, Warfarin.PostPickupUpdate, PickupVariant.PICKUP_COLLECTIBLE)

function Warfarin:UseItem(itemID, rng, player, useFlags, activeSlot, varData)
    if player:GetPlayerType() ~= ty.CustomPlayerType.WARFARIN then
        return
    end
    local data = ty:GetLibData(player)
    local collectible = GetClosestCollectible(player)
    if collectible then
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, collectible.Position, Vector(0, 0), nil)
        collectible:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, ty:GetCollectibleFromCurrentRoom(true, nil, rng, collectible.SubType))
        collectible.ShopItemId = -2
        collectible.Price = 0
    else
        ty.SFXMANAGER:Play(SoundEffect.SOUND_SUPERHOLY, 0.6)
        player:AddMaxHearts(2)
        if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
            player:AddHearts(2)
        end
    end
    return { Discharge = true, Remove = false, ShowAnim = true }
end
Warfarin:AddCallback(ModCallbacks.MC_USE_ITEM, Warfarin.UseItem, ty.CustomCollectibles.BLOODSAMPLE)

function Warfarin:PostAddCollectible(type, charge, firstTime, slot, varData, player)
    if player:GetPlayerType() == ty.CustomPlayerType.WARFARIN then
        local itemConfig = ty.ITEMCONFIG:GetCollectible(type)
        player:AddActiveCharge(itemConfig.AddSoulHearts + itemConfig.AddBlackHearts, ActiveSlot.SLOT_POCKET, true, true, true)
        player:AddSoulHearts(-itemConfig.AddSoulHearts)
        player:AddBlackHearts(-itemConfig.AddBlackHearts)
        if player:GetHearts() <= 6 then
            player:AddHearts(itemConfig.AddHearts)
        end
        if type == CollectibleType.COLLECTIBLE_ABADDON then
            player:AddMaxHearts(2)
            player:AddHearts(2)
        end
        if type == CollectibleType.COLLECTIBLE_CHARM_VAMPIRE then
            player:AddCacheFlags(CacheFlag.CACHE_FLYING, true)
            player:GetEffects():AddNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.WARFARINWINGS).ID)
        end
        if type == CollectibleType.COLLECTIBLE_BLOOD_BAG then
            player:AddHearts(99)
        end
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)
    end
end
Warfarin:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, Warfarin.PostAddCollectible)

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

function Warfarin:PostDevilCalculate(chance)
    if PlayerManager.AnyoneIsPlayerType(ty.CustomPlayerType.WARFARIN) then
        return 1.5 * chance
    end
end
Warfarin:AddCallback(ModCallbacks.MC_POST_DEVIL_CALCULATE, Warfarin.PostDevilCalculate)

function Warfarin:PreTriggerPlayerDeath(player)
    if player:GetExtraLives() > 0 and player:GetMaxHearts() == 0 and player:GetBrokenHearts() == 12 then
        deadByBrokenHearts = true
    end
end
Warfarin:AddCallback(ModCallbacks.MC_PRE_TRIGGER_PLAYER_DEATH, Warfarin.PreTriggerPlayerDeath)

function Warfarin:PostGridEntitySpawn(grid)
    local globalData = ty.GLOBALDATA
    local room = ty.GAME:GetRoom()
    if replaceTrapDoor then
        local crawlSpace = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.ISAACS_CARPET, ty.CustomEffects.WARFARINBLACKMARKETCRAWLSPACE, grid.Position, Vector(0, 0), nil)
        globalData.BloodSample.BossIndex = ty.LEVEL:GetCurrentRoomIndex()
        globalData.BloodSample.GridIndex = room:GetGridIndex(grid.Position)
        room:RemoveGridEntity(globalData.BloodSample.GridIndex, 0, false)
        replaceTrapDoor = false
    end
end
Warfarin:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_SPAWN, Warfarin.PostGridEntitySpawn, GridEntityType.GRID_TRAPDOOR)

function Warfarin:PreSpawnCleanAward(rng, spawnPosition)
    local room = ty.GAME:GetRoom()
    if PlayerManager.AnyoneIsPlayerType(ty.CustomPlayerType.WARFARIN) and room:GetType() == RoomType.ROOM_BOSS and room:IsCurrentRoomLastBoss() and ty.LEVEL:GetAbsoluteStage() < LevelStage.STAGE4_2 then
        replaceTrapDoor = not IsDevilAngelRoomOpened()
    end
end
Warfarin:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, Warfarin.PreSpawnCleanAward)

function Warfarin:PostNewRoom()
    local room = ty.GAME:GetRoom()
    if PlayerManager.AnyoneIsPlayerType(ty.CustomPlayerType.WARFARIN) then
        local globalData = ty.GLOBALDATA
        if room:GetType() == RoomType.ROOM_BLACK_MARKET and globalData.BloodSample.BossIndex > 0 then
            Isaac.Spawn(EntityType.ENTITY_EFFECT, ty.CustomEffects.WARFARINBLACKMARKETLADDER, 0, Vector(200, 160), Vector(0, 0), nil)
            room:RemoveGridEntity(room:GetGridIndex(Vector(200, 160)), 0, false)
        end
        if room:GetType() == RoomType.ROOM_BOSS and ty.LEVEL:GetCurrentRoomIndex() == globalData.BloodSample.BossIndex and restorePosition then
            for _, player in pairs(PlayerManager.GetPlayers()) do
                player.Position = room:GetGridPosition(globalData.BloodSample.GridIndex)
            end
            restorePosition = false
        end
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
    end
end
Warfarin:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, Warfarin.PostCrawlspaceUpdate, EffectVariant.ISAACS_CARPET)

function Warfarin:PostLadderUpdate(effect)
    local sprite = effect:GetSprite()
    if sprite:IsFinished("Idle") then
        for _, ent in pairs(Isaac.FindInRadius(effect.Position, 8, EntityPartition.PLAYER)) do
            restorePosition = true
            ty.GAME:StartRoomTransition(ty.GLOBALDATA.BloodSample.BossIndex, Direction.NO_DIRECTION, RoomTransitionAnim.PIXELATION, ent:ToPlayer(), 0)
        end
    end
end
Warfarin:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, Warfarin.PostLadderUpdate, ty.CustomEffects.WARFARINBLACKMARKETLADDER)

return Warfarin