local Cornucopia = ty:DefineANewClass()

local functions = ty.Functions

local chargeIcon = Sprite("gfx/ui/cornucopia_charge.anm2", true)
chargeIcon:Play("Idle", true)

local function GetMaxCharge(player)
    local maxCharge = 24
    if player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) then
        maxCharge = 36
    end
    return maxCharge
end

local function GetZeroFilledString(number)
	if number < 10 then
		return "0"..tostring(number)
	else
		return tostring(number)
	end
end

local function SpawnFakeSprite(entity, animation)
    local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, ty.CustomEffects.EMPTYHELPER, 0, entity.Position, Vector(0, 0), nil)
    local sprite = effect:GetSprite()
    sprite:Load(entity:GetSprite():GetFilename(), true)
    sprite:Play(animation, true)
end

local function GetPickupCharge(pickup, player, real)
    if real and pickup.OptionsPickupIndex ~= 0 then
        for _, ent in pairs(Isaac.FindByType(EntityType.ENTITY_PICKUP)) do
            local ent = ent:ToPickup()
            if ent.OptionsPickupIndex == pickup.OptionsPickupIndex then
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, ent.Position, Vector(0, 0), nil)
                ent:Remove()
            end
        end
    end
    if pickup.Variant == PickupVariant.PICKUP_HEART then
        if pickup.SubType == HeartSubType.HEART_HALF then
            return 1
        elseif pickup.SubType == HeartSubType.HEART_HALF_SOUL or pickup.SubType == HeartSubType.HEART_FULL or pickup.SubType == HeartSubType.HEART_SCARED then
            return 2
        elseif pickup.SubType == HeartSubType.HEART_ROTTEN then
            return 3
        elseif pickup.SubType == HeartSubType.HEART_SOUL or pickup.SubType == HeartSubType.HEART_DOUBLEPACK then
            return 4
        elseif pickup.SubType == HeartSubType.HEART_BLACK or pickup.SubType == HeartSubType.HEART_GOLDEN or pickup.SubType == HeartSubType.HEART_BONE or pickup.SubType == HeartSubType.HEART_ETERNAL then
            return 5
        elseif pickup.SubType == HeartSubType.HEART_BLENDED then
            return 6
        else
            return 2
        end
    elseif pickup.Variant == PickupVariant.PICKUP_COIN then
        if pickup.SubType == CoinSubType.COIN_PENNY then
            return 1
        elseif pickup.SubType == CoinSubType.COIN_DOUBLEPACK then
            return 2
        elseif pickup.SubType == CoinSubType.COIN_NICKEL or pickup.SubType == CoinSubType.COIN_STICKYNICKEL then
            return 3
        elseif pickup.SubType == CoinSubType.COIN_DIME then
            return 5
        elseif pickup.SubType == CoinSubType.COIN_GOLDEN then
            return 7
        elseif pickup.SubType == CoinSubType.COIN_LUCKYPENNY then
            return 8
        else
            return 1
        end
    elseif pickup.Variant == PickupVariant.PICKUP_KEY then
        if pickup.SubType == KeySubType.KEY_NORMAL then
            return 2
        elseif pickup.SubType == KeySubType.KEY_DOUBLEPACK then
            return 4
        elseif pickup.SubType == KeySubType.KEY_CHARGED then
            return 5
        elseif pickup.SubType == KeySubType.KEY_GOLDEN then
            return 7
        else
            return 2
        end
    elseif pickup.Variant == PickupVariant.PICKUP_BOMB then
        if pickup.SubType == BombSubType.BOMB_NORMAL then
            return 2
        elseif pickup.SubType == BombSubType.BOMB_DOUBLEPACK then
            return 4
        elseif pickup.SubType == BombSubType.BOMB_GOLDEN then
            return 7
        elseif pickup.SubType == BombSubType.BOMB_GIGA then
            return 10
        else
            return 2
        end
    elseif pickup.Variant == PickupVariant.PICKUP_PILL then
        if pickup.SubType <= 13 then
            return 2
        elseif pickup.SubType >= 2049 then
            return 4
        elseif pickup.SubType == 14 then
            return 7
        end
    elseif pickup.Variant == PickupVariant.PICKUP_LIL_BATTERY then
        if pickup.SubType == BatterySubType.BATTERY_MICRO then
            return 2
        elseif pickup.SubType == BatterySubType.BATTERY_NORMAL then
            return 4
        elseif pickup.SubType == BatterySubType.BATTERY_MEGA then
            return 8
        elseif pickup.SubType == BatterySubType.BATTERY_GOLDEN then
            return 24
        else
            return 4
        end
    elseif pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE then
        local cycleList = pickup:GetCollectibleCycle()
        table.insert(cycleList, pickup.SubType)
        local charge = 0
        for _, item in pairs(cycleList) do
            if not real and pickup:IsBlind(false) then
                return -16
            end
            if item > 0 then
                local itemConfigCollectible = ty.ITEMCONFIG:GetCollectible(item)
                if itemConfigCollectible:HasTags(ItemConfig.TAG_QUEST) then
                    charge = 12
                else
                    charge = charge + math.max(math.min(24, 6 * itemConfigCollectible.Quality), 3)
                end
            else
                return nil
            end
        end
        return math.min(GetMaxCharge(player), charge)
    elseif pickup.Variant == PickupVariant.PICKUP_TAROTCARD then
        if pickup.SubType == Card.CARD_CRACKED_KEY then
            return 2
        elseif pickup.SubType == Card.CARD_DICE_SHARD then
            return 4
        elseif (pickup.SubType >= Card.RUNE_HAGALAZ and pickup.SubType <= Card.RUNE_BLACK) or (pickup.SubType >= Card.CARD_SOUL_ISAAC and pickup.SubType <= Card.CARD_SOUL_JACOB) then
            return 3
        else
            return 2
        end
    elseif pickup.Variant == PickupVariant.PICKUP_POOP then
        if pickup.SubType == PoopPickupSubType.POOP_SMALL then
            return 1
        else
            return 2
        end
    elseif pickup.Variant == PickupVariant.PICKUP_TRINKET then
        local trinketConfig = ty.ITEMCONFIG:GetTrinket(pickup.SubType)
        if trinketConfig:IsTrinket() then
            if pickup.SubType > 32768 then
                return 12
            else
                return 6
            end
        end
    end
    return nil
end

local function SpawnAnItem(player, rng, index)
    local room = ty.GAME:GetRoom()
    local data = ty:GetLibData(player)
    local globalData = ty.GLOBALDATA
    local item = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, functions:GetCollectibleFromCurrentRoom(true, nil, rng), room:FindFreePickupSpawnPosition(player.Position, 0, true), Vector(0, 0), nil):ToPickup()
    item:ClearEntityFlags(EntityFlag.FLAG_ITEM_SHOULD_DUPLICATE)
    item.OptionsPickupIndex = index
    item.ShopItemId = -2
    item.Price = 0
    if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) and rng:RandomInt(100) < 10 then
        local angelItem = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, ty.ITEMPOOL:GetCollectible(ItemPoolType.POOL_ANGEL, true, rng:Next()), room:FindFreePickupSpawnPosition(player.Position, 0, true), Vector(0, 0), nil):ToPickup()
        angelItem:ClearEntityFlags(EntityFlag.FLAG_ITEM_SHOULD_DUPLICATE)
        angelItem.OptionsPickupIndex = index
        angelItem.ShopItemId = -2
        angelItem.Price = 0
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL_PASSIVE) and rng:RandomInt(100) < 10 then
        local devilItem = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, ty.ITEMPOOL:GetCollectible(ItemPoolType.POOL_DEVIL, true, rng:Next()), room:FindFreePickupSpawnPosition(player.Position, 0, true), Vector(0, 0), nil):ToPickup()
        devilItem:ClearEntityFlags(EntityFlag.FLAG_ITEM_SHOULD_DUPLICATE)
        devilItem.OptionsPickupIndex = index
        devilItem.ShopItemId = -2
        devilItem.Price = 0
    end
end

local function RenderChargeIcon(player)
    local data = ty:GetLibData(player)
    local hudOffset = Options.HUDOffset
    local renderPos = Vector(16 + 20 * hudOffset, 21 + 12 * hudOffset)
    if player:GetPlayerType() == PlayerType.PLAYER_ESAU then
        renderPos = Vector(Isaac.GetScreenWidth() - 20 - 20 * hudOffset, Isaac.GetScreenHeight() - 2 - 12 * hudOffset)
    elseif player:GetPlayerType() == PlayerType.PLAYER_JACOB then
        renderPos = Vector(42 + 20 * hudOffset, 47 + 12 * hudOffset)
    elseif player:GetPlayerType() == PlayerType.PLAYER_ISAAC_B then
        renderPos = Vector(42 + 20 * hudOffset, 57 + 12 * hudOffset)
    else
        renderPos = Vector(42 + 20 * hudOffset, 33 + 12 * hudOffset)
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_DEEP_POCKETS) and player:GetPlayerType() ~= PlayerType.PLAYER_ESAU then
        renderPos = renderPos + Vector(6, 0)
    end
    chargeIcon:Render(renderPos - Vector(15, 1))
    ty.PFTEMP:DrawStringScaledUTF8(GetZeroFilledString(data.Cornucopia.Charge).." / "..GetMaxCharge(player), renderPos.X, renderPos.Y, 1, 1, KColor(1, 1, 1, 1))
end

local function RenderPickupChargeNum(player)
    local room = ty.GAME:GetRoom()
    for _, pickup in pairs(Isaac.FindByType(EntityType.ENTITY_PICKUP)) do
        local pickup = pickup:ToPickup()
        if not pickup:IsShopItem() then
            local charge = GetPickupCharge(pickup, player, false)
            if charge then
                local pickupPos = Isaac.WorldToScreen(pickup.Position)
                local kColor = KColor(1, 1, 1, 1)
                if player:HasCollectible(CollectibleType.COLLECTIBLE_9_VOLT) then
                    charge = charge + 1
                    kColor = KColor(0, 1, 0, 1)
                end
                local x = pickupPos.X - 3
                local y = pickupPos.Y + 7
                if room:IsMirrorWorld() then
                    x = Isaac.GetScreenWidth() - pickupPos.X - 3
                end
                if charge < 0 then
                    ty.PFTEMP:DrawString("?", x, y, kColor, 5, true)
                else
                    if pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE then
                        ty.PFTEMP:DrawString(charge, x, y, kColor, 5, true)
                    else
                        ty.PFTEMP:DrawString(charge, x, y - 7, kColor, 5, true)
                    end
                end
            end
        end
    end
end

function Cornucopia:PostRender()
    if not ty.HUD:IsVisible() then
		return
	end
    for _, player in pairs(PlayerManager.GetPlayers()) do
        if player:HasCollectible(ty.CustomCollectibles.CORNUCOPIA) then
            local data = ty:GetLibData(player)
            RenderChargeIcon(player)
            if data.Cornucopia.IsHolding then
                RenderPickupChargeNum(player)
            end    
        end
    end
end
Cornucopia:AddCallback(ModCallbacks.MC_POST_RENDER, Cornucopia.PostRender)

function Cornucopia:PostPlayerUpdate(player)
    local data = ty:GetLibData(player)
    if player:HasCollectible(ty.CustomCollectibles.CORNUCOPIA) and data.Cornucopia.IsHolding then
        if not player:IsHoldingItem() then
            player:AnimateCollectible(ty.CustomCollectibles.CORNUCOPIA, "HideItem")
            data.Cornucopia.IsHolding = false
        end
    end
end
Cornucopia:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Cornucopia.PostPlayerUpdate)

function Cornucopia:UseItem(itemID, rng, player, useFlags, activeSlot, varData)
    local data = ty:GetLibData(player)
    if useFlags & UseFlag.USE_CARBATTERY == UseFlag.USE_CARBATTERY or useFlags & UseFlag.USE_OWNED ~= UseFlag.USE_OWNED or useFlags & UseFlag.USE_VOID == UseFlag.USE_VOID then
        return { Discharge = false, Remove = false, ShowAnim = false }
    end
    if data.Cornucopia.Charge >= 24 then
        local flag = true
        for _, item in pairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)) do
            if item.SubType > 0 then
                local pickup = item:ToPickup()
                pickup:AddCollectibleCycle(functions:GetCollectibleFromCurrentRoom(true, nil, rng))
                if player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) then
                    pickup:AddCollectibleCycle(functions:GetCollectibleFromCurrentRoom(true, nil, rng))
                end
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector(0, 0), nil)
                flag = false    
            end
        end
        if flag then
            local index = 0
            if ty.LEVEL:GetDimension() == Dimension.DEATH_CERTIFICATE then
                index = 1
            end
            SpawnAnItem(player, rng, index)
            if player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) then
                SpawnAnItem(player, rng, index)
            end
        end
        data.Cornucopia.Charge = data.Cornucopia.Charge - 24
        return { Discharge = false, Remove = false, ShowAnim = true }
    else
        if not data.Cornucopia.IsHolding then
            player:AnimateCollectible(ty.CustomCollectibles.CORNUCOPIA, "LiftItem")
            data.Cornucopia.IsHolding = true
        else
            player:AnimateCollectible(ty.CustomCollectibles.CORNUCOPIA, "HideItem")
            data.Cornucopia.IsHolding = false
        end
    end
    return { Discharge = false, Remove = false, ShowAnim = false }
end
Cornucopia:AddCallback(ModCallbacks.MC_USE_ITEM, Cornucopia.UseItem, ty.CustomCollectibles.CORNUCOPIA)

function Cornucopia:PrePickupCollision(pickup, collider, low)
    local pickup = pickup:ToPickup()
    local player = collider:ToPlayer()
    if not player or pickup.SubType <= 0 or pickup:IsShopItem() then
        return nil
    end
    if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
        player = player:GetOtherTwin()
    end
    if player:HasCollectible(ty.CustomCollectibles.CORNUCOPIA) then
        local data = ty:GetLibData(player)
        if data.Cornucopia.IsHolding and data.Cornucopia.Charge < GetMaxCharge(player) then
            local charge = GetPickupCharge(pickup, player, true)
            if charge then
                if player:HasCollectible(CollectibleType.COLLECTIBLE_9_VOLT) then
                    charge = charge + 1
                end
                data.Cornucopia.Charge = data.Cornucopia.Charge + charge
                if data.Cornucopia.Charge >= GetMaxCharge(player) then
                    data.Cornucopia.Charge = GetMaxCharge(player)
                    player:AnimateCollectible(ty.CustomCollectibles.CORNUCOPIA, "HideItem")
                    data.Cornucopia.IsHolding = false
                end
                ty.SFXMANAGER:Play(SoundEffect.SOUND_BATTERYCHARGE, 0.6)
                if pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE or pickup.Variant == PickupVariant.PICKUP_TRINKET then
                    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector(0, 0), nil)
                else
                    SpawnFakeSprite(pickup, "Collect")
                end
                pickup:Remove()
                return true
            end
        end
    end
    return nil
end
Cornucopia:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, Cornucopia.PrePickupCollision)

function Cornucopia:PostEffectUpdate(effect)
    local sprite = effect:GetSprite()
    if sprite:IsFinished(sprite:GetAnimation()) then
        effect:Remove()
    end
end
Cornucopia:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, Cornucopia.PostEffectUpdate, ty.CustomEffects.EMPTYHELPER)

return Cornucopia