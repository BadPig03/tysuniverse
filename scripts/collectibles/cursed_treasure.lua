local CursedTreasure = ty:DefineANewClass()

local function TriggerBloodyPenny(player)
    local room = ty.GAME:GetRoom()
    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_HALF, room:FindFreePickupSpawnPosition(player.Position, 0, true), Vector(0, 0), nil)
end

local function TriggerBurntPenny(player)
    local room = ty.GAME:GetRoom()
    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, BombSubType.BOMB_NORMAL, room:FindFreePickupSpawnPosition(player.Position, 0, true), Vector(0, 0), nil)
end

local function TriggerFlatPenny(player)
    local room = ty.GAME:GetRoom()
    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_KEY, KeySubType.KEY_NORMAL, room:FindFreePickupSpawnPosition(player.Position, 0, true), Vector(0, 0), nil)
end

local function TriggerCounterfeitPenny(player)
    local room = ty.GAME:GetRoom()
    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, ty.CustomEntities.CURSEDCOIN, room:FindFreePickupSpawnPosition(player.Position, 0, true), Vector(0, 0), nil)
end

local function TriggerBlessedPenny(player)
    local room = ty.GAME:GetRoom()
    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_HALF_SOUL, room:FindFreePickupSpawnPosition(player.Position, 0, true), Vector(0, 0), nil)
end

local function TriggerChargedPenny(player)
    if player:AddActiveCharge(1, ActiveSlot.SLOT_PRIMARY) == 0 then
        if player:AddActiveCharge(1, ActiveSlot.SLOT_SECONDARY) == 0 then
            player:AddActiveCharge(1, ActiveSlot.SLOT_POCKET)
        end
    end
end

local function TriggerCursedPenny(player)
    local rng = player:GetCollectibleRNG(ty.CustomCollectibles.CURSEDTREASURE)
    ty.GAME:MoveToRandomRoom(false, rng:Next(), player)
end

local function TriggerButtPenny(player)
    ty.GAME:Fart(player.Position, 85, player)
    ty.GAME:ButterBeanFart(player.Position, 85, player, false, false)
end

local function TriggerRottenPenny(player)
    player:AddBlueFlies(1, player.Position, player)
end

local function TriggerRandomEffect(player)
    local rng = player:GetCollectibleRNG(ty.CustomCollectibles.CURSEDTREASURE)
    local maxNum = 9
    if player:HasCollectible(CollectibleType.COLLECTIBLE_BLACK_CANDLE) then
        maxNum = 8
    end
    local num = rng:RandomInt(maxNum)
    if num == 0 then
        TriggerBloodyPenny(player)
    elseif num == 1 then
        TriggerButtPenny(player)
    elseif num == 2 then
        TriggerBurntPenny(player)
    elseif num == 3 then
        TriggerFlatPenny(player)
    elseif num == 4 then
        TriggerCounterfeitPenny(player)
    elseif num == 5 then
        TriggerRottenPenny(player)
    elseif num == 6 then
        TriggerBlessedPenny(player)
    elseif num == 7 then
        TriggerChargedPenny(player)
    elseif num == 8 then
        TriggerCursedPenny(player)
    end
end

function CursedTreasure:PostAddCollectible(type, charge, firstTime, slot, varData, player)
    for _, ent in pairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN)) do
        if ent.SubType ~= ty.CustomEntities.CURSEDCOIN then
            ent:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, ty.CustomEntities.CURSEDCOIN)
        end
    end
end
CursedTreasure:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, CursedTreasure.PostAddCollectible, ty.CustomCollectibles.CURSEDTREASURE)

function CursedTreasure:PostPickupInit(pickup)
    local pickup = pickup:ToPickup()
    if PlayerManager.AnyoneHasCollectible(ty.CustomCollectibles.CURSEDTREASURE) then
        if pickup.Variant == PickupVariant.PICKUP_COIN and pickup.SubType ~= ty.CustomEntities.CURSEDCOIN then
            pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, ty.CustomEntities.CURSEDCOIN)
        end
        if ty.GAME:GetRoom():GetType() == RoomType.ROOM_SHOP and pickup:IsShopItem() and pickup.Variant ~= PickupVariant.PICKUP_COLLECTIBLE then
            local rng = pickup:GetDropRNG()
            local item = ty:GetCollectibleFromCurrentRoom(true, nil, rng)
            pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, item, true, false, false)
            pickup:MakeShopItem(-1)
        end
    end
end
CursedTreasure:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, CursedTreasure.PostPickupInit)

function CursedTreasure:PostPickupUpdate(pickup)
    if pickup.SubType == ty.CustomEntities.CURSEDCOIN then
        local pickup = pickup:ToPickup()
        local sprite = pickup:GetSprite()
        if sprite:IsEventTriggered("DropSound") then
            ty.SFXMANAGER:Play(SoundEffect.SOUND_PENNYDROP, 0.7, 2, false, 1.2)
        end
    end
end
CursedTreasure:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, CursedTreasure.PostPickupUpdate, PickupVariant.PICKUP_COIN)

function CursedTreasure:PostPickupCollision(pickup, collider, low)
    local player = collider:ToPlayer()
    if pickup.SubType == ty.CustomEntities.CURSEDCOIN and player then
        ty.SFXMANAGER:Play(SoundEffect.SOUND_PENNYPICKUP, 0.7, 2, false, 1.2)
        TriggerRandomEffect(player)
        local rng = player:GetCollectibleRNG(ty.CustomCollectibles.CURSEDTREASURE)
        if rng:RandomFloat() < 1/3 then
            player:AddCoins(rng:RandomInt(5) + 1)
        end
    end
end
CursedTreasure:AddCallback(ModCallbacks.MC_POST_PICKUP_COLLISION, CursedTreasure.PostPickupCollision, PickupVariant.PICKUP_COIN)

return CursedTreasure