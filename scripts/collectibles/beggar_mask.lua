local BeggerMask = ty:DefineANewClass()

local prized = false
local slotType = SlotVariant.BEGGAR

local function IsValidSlot(slot)
    return slot.Variant == SlotVariant.BEGGAR or slot.Variant == SlotVariant.DEVIL_BEGGAR or slot.Variant == SlotVariant.BOMB_BUM or slot.Variant == SlotVariant.KEY_MASTER or slot.Variant == SlotVariant.BATTERY_BUM or slot.Variant == SlotVariant.ROTTEN_BEGGAR or slot.Variant == ty.CustomEntities.HEALINGBEGGAR
end

local function SpawnBonus(slot)
    local rng = slot:GetDropRNG()
    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_NULL, 1, slot.Position, Vector(1, 0):Resized(2 + rng:RandomFloat() * 3):Rotated(rng:RandomInt(360)), nil):ToPickup()
    ty.SFXMANAGER:Play(SoundEffect.SOUND_SLOTSPAWN, 0.6)
end

function BeggerMask:PostNewRoom()
    local room = ty.GAME:GetRoom()
    local roomType = room:GetType()
    for _, player in pairs(PlayerManager.GetPlayers()) do
        if player:HasCollectible(ty.CustomCollectibles.BEGGARMASK) and room:IsFirstVisit() then
            local pos = room:FindFreePickupSpawnPosition(Vector(520, 360), 0, true, false)
            if room:GetRoomShape() == RoomShape.ROOMSHAPE_IV then
                pos = room:FindFreePickupSpawnPosition(Vector(360, 360), 0, true, false)
            elseif room:GetRoomShape() == RoomShape.ROOMSHAPE_IH then
                pos = room:FindFreePickupSpawnPosition(Vector(440, 280), 0, true, false)
            elseif room:GetRoomShape() == RoomShape.ROOMSHAPE_2x1 then
                pos = room:FindFreePickupSpawnPosition(Vector(1000, 360), 0, true, false)
            end
            local slot = nil
            if roomType == RoomType.ROOM_ANGEL then
                slot = Isaac.Spawn(EntityType.ENTITY_SLOT, ty.CustomEntities.HEALINGBEGGAR, 0, pos, Vector(0, 0), nil)
            elseif roomType == RoomType.ROOM_DEVIL then
                slot = Isaac.Spawn(EntityType.ENTITY_SLOT, SlotVariant.DEVIL_BEGGAR, 0, pos, Vector(0, 0), nil)
            elseif roomType == RoomType.ROOM_TREASURE then
                slot = Isaac.Spawn(EntityType.ENTITY_SLOT, SlotVariant.BEGGAR, 0, pos, Vector(0, 0), nil)
            elseif roomType == RoomType.ROOM_SECRET then
                slot = Isaac.Spawn(EntityType.ENTITY_SLOT, SlotVariant.BOMB_BUM, 0, pos, Vector(0, 0), nil)
            elseif roomType == RoomType.ROOM_SUPERSECRET then
                slot = Isaac.Spawn(EntityType.ENTITY_SLOT, SlotVariant.KEY_MASTER, 0, pos, Vector(0, 0), nil)
            elseif roomType == RoomType.ROOM_SHOP then
                slot = Isaac.Spawn(EntityType.ENTITY_SLOT, SlotVariant.BATTERY_BUM, 0, pos, Vector(0, 0), nil)
            elseif roomType == RoomType.ROOM_CURSE then
                slot = Isaac.Spawn(EntityType.ENTITY_SLOT, SlotVariant.ROTTEN_BEGGAR, 0, pos, Vector(0, 0), nil)
            end
            if slot then
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, slot.Position, Vector(0, 0), nil)
            end
            break
        end
    end
    if PlayerManager.AnyoneHasCollectible(ty.CustomCollectibles.BEGGARMASK) then
        for _, slot in pairs(Isaac.FindByType(EntityType.ENTITY_SLOT)) do
            if IsValidSlot(slot) then
                local data = ty:GetLibData(slot)
                data.Prized = false
                data.Player = nil
            end
        end
    end
    prized = false
end
BeggerMask:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, BeggerMask.PostNewRoom)

function BeggerMask:PostSlotCollision(slot, collider, low)
    local player = collider:ToPlayer()
    if player and player:HasCollectible(ty.CustomCollectibles.BEGGARMASK) and IsValidSlot(slot) then
        local data = ty:GetLibData(slot)
        data.Player = player
    end
end
BeggerMask:AddCallback(ModCallbacks.MC_POST_SLOT_COLLISION, BeggerMask.PostSlotCollision)

function BeggerMask:PostSlotUpdate(slot)
    if IsValidSlot(slot) then
        local sprite = slot:GetSprite()
        local data = ty:GetLibData(slot)
        if data.Prized == nil then
            data.Prized = false
            data.Player = data.Player or nil
        end
        if sprite:IsEventTriggered("Prize") then
            if data.Prized then
                SpawnBonus(slot)
                data.Prized = false
            else
                prized = true
                slotType = slot.Variant
            end
        end
        if data.Player then
            if data.Player:GetCollectibleRNG(ty.CustomCollectibles.BEGGARMASK):RandomInt(100) < 16 + 4 * data.Player.Luck and not data.Prized and sprite:IsPlaying("PayNothing") and sprite:GetFrame() <= 1 then
                sprite:Play("PayPrize", true)
                data.Prized = true
            end
            if data.Prized and sprite:IsFinished("PayPrize") then
                sprite:Play("Prize", true)
            end
        end
    end
end
BeggerMask:AddCallback(ModCallbacks.MC_POST_SLOT_UPDATE, BeggerMask.PostSlotUpdate)

function BeggerMask:PostPickupUpdate(pickup)
    if pickup.FrameCount <= 1 and prized and PlayerManager.AnyoneHasCollectible(ty.CustomCollectibles.BEGGARMASK) then
        if pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE then
            prized = false
            local rng = pickup:GetDropRNG()
            local randomFloat = rng:RandomFloat()
            if randomFloat < 1/3 then
                local item = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, ty:GetCollectibleFromCurrentRoom(true, nil, rng), ty.GAME:GetRoom():FindFreePickupSpawnPosition(pickup.Position + Vector(80, 0):Rotated(rng:RandomInt(4) * 90), 0, true), Vector(0, 0), nil):ToPickup()
                item:MakeShopItem(-1)
                item.Price = ty.ITEMCONFIG:GetCollectible(item.SubType).ShopPrice
            elseif randomFloat >= 1/3 and randomFloat < 2/3 then
                local item = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, ty:GetCollectibleFromCurrentRoom(true, nil, rng), ty.GAME:GetRoom():FindFreePickupSpawnPosition(pickup.Position + Vector(80, 0):Rotated(rng:RandomInt(4) * 90), 0, true), Vector(0, 0), nil):ToPickup()
                item:MakeShopItem(-2)
                item.Price = ty.ITEMCONFIG:GetCollectible(item.SubType).DevilPrice
            else
                local beggar = Isaac.Spawn(EntityType.ENTITY_SLOT, slotType, 0, ty.GAME:GetRoom():FindFreePickupSpawnPosition(pickup.Position + Vector(80, 0):Rotated(rng:RandomInt(4) * 90), 0, true), Vector(0, 0), nil)
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, beggar.Position, Vector(0, 0), nil)
            end
        else
            prized = false
        end
    end
end
BeggerMask:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, BeggerMask.PostPickupUpdate)

function BeggerMask:PreSlotCreateExplosionDrops(slot)
    if IsValidSlot(slot) then
        for _, player in pairs(PlayerManager.GetPlayers()) do
            if player:HasCollectible(ty.CustomCollectibles.BEGGARMASK) then
                player:RemoveCollectible(ty.CustomCollectibles.BEGGARMASK)
                player:AnimateSad()
                ty.SFXMANAGER:Play(SoundEffect.SOUND_HOLY_MANTLE, 0.6, 2, false, 1.3)
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CRACKED_ORB_POOF, 0, player.Position, Vector(0, 0), nil):GetSprite().Color:SetColorize(0.3, 0.3, 0.3, 1)        
            end
        end
    end
end
BeggerMask:AddCallback(ModCallbacks.MC_PRE_SLOT_CREATE_EXPLOSION_DROPS, BeggerMask.PreSlotCreateExplosionDrops)

return BeggerMask