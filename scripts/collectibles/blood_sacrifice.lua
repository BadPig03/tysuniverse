local BloodSacrifice = ty:DefineANewClass()

local function GetVesselFromSeed(seed)
    for _, ent in pairs(Isaac.FindByType(EntityType.ENTITY_SLOT, ty.CustomEntities.BLOODSACRIFICEVESSEL)) do
        if ent.InitSeed == seed then
            return ent
        end
    end
    return nil
end

local function DestroyVessel(slot)
    local slotData = ty:GetLibData(slot)
    slotData.Broken = true
    slot:TakeDamage(1, DamageFlag.DAMAGE_EXPLOSION, EntityRef(nil), 0)
    slot.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
    slot:GetSprite():Play("Broken", true)
end

local function RemoveFromList(seed)
    for _, player in pairs(PlayerManager.GetPlayers()) do
        local data = ty:GetLibData(player)
        local list = data.BloodSacrifice.VesselList
        local i = 0
        for index, vesselTable in pairs(list) do
            if vesselTable.InitSeed == seed then
                i = index
                break
            end
        end
        if i ~= 0 then
            table.remove(list, i)
        end    
    end
end

function BloodSacrifice:EvaluateCache(player, cacheFlag)
	local data = ty:GetLibData(player)
	if data.BloodSacrifice and data.BloodSacrifice.UsedCount[player:GetPlayerType()] then
		ty.Stat:AddFlatDamage(player, 0.2 * data.BloodSacrifice.UsedCount[player:GetPlayerType()])
	end
end
BloodSacrifice:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, BloodSacrifice.EvaluateCache, CacheFlag.CACHE_DAMAGE)

function BloodSacrifice:UseItem(itemID, rng, player, useFlags, activeSlot, varData)
    if useFlags & UseFlag.USE_CARBATTERY == UseFlag.USE_CARBATTERY then
        return { Discharge = false, Remove = false, ShowAnim = false }
    end
    local room = ty.GAME:GetRoom()
    local data = ty:GetLibData(player)
    if player:GetMaxHearts() > 0 and ty.LEVEL:GetDimension() == Dimension.NORMAL then
        player:AddMaxHearts(-2)
        player:TakeDamage(0, DamageFlag.DAMAGE_FAKE | DamageFlag.DAMAGE_SPIKES | DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_INVINCIBLE, EntityRef(player), 30)
        ty.SFXMANAGER:Play(SoundEffect.SOUND_MEATY_DEATHS)
        data.BloodSacrifice.UsedCount[player:GetPlayerType()] = (data.BloodSacrifice.UsedCount[player:GetPlayerType()] or 0) + 1
        if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL_PASSIVE) then
            data.BloodSacrifice.UsedCount[player:GetPlayerType()] = data.BloodSacrifice.UsedCount[player:GetPlayerType()] + 1
        end
        local vessel = Isaac.Spawn(EntityType.ENTITY_SLOT, ty.CustomEntities.BLOODSACRIFICEVESSEL, 0, room:FindFreePickupSpawnPosition(player.Position, 0, true), Vector(0, 0), nil)
        vessel:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, vessel.Position, Vector(0, 0), nil)
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 0, player.Position, Vector(0, 0), nil)
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.LARGE_BLOOD_EXPLOSION, 0, player.Position, Vector(0, 0), nil)
        table.insert(data.BloodSacrifice.VesselList, { PositionX = vessel.Position.X, PositionY = vessel.Position.Y, RoomIndex = ty.LEVEL:GetCurrentRoomIndex(), InitSeed = vessel.InitSeed })
        return { Discharge = true, Remove = false,  ShowAnim = true }
    else
        return { Discharge = false, Remove = false,  ShowAnim = true }
    end
end
BloodSacrifice:AddCallback(ModCallbacks.MC_USE_ITEM, BloodSacrifice.UseItem, ty.CustomCollectibles.BLOODSACRIFICE)

function BloodSacrifice:PostNewRoom()
    for _, player in pairs(PlayerManager.GetPlayers()) do
        local data = ty:GetLibData(player)
        if data.Init and data.BloodSacrifice.Respawning then
            local vesselTable = data.BloodSacrifice.VesselList[#data.BloodSacrifice.VesselList]
            local vessel = GetVesselFromSeed(vesselTable.InitSeed)
            vessel:GetSprite():Play("Wiggle", true)
            vessel.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            player:PlayExtraAnimation("Appear")
            player.Position = Vector(vesselTable.PositionX, vesselTable.PositionY)
            ty.GAME:SpawnParticles(player.Position, EffectVariant.BLOOD_PARTICLE, 30, 1) 
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_SPLAT, 0, player.Position, Vector(0, 0), nil)
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 0, player.Position, Vector(0, 0), nil)
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.LARGE_BLOOD_EXPLOSION, 0, player.Position, Vector(0, 0), nil)
            data.BloodSacrifice.PlaySound = true
            data.BloodSacrifice.Respawning = false
        end
    end
end
BloodSacrifice:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, BloodSacrifice.PostNewRoom)

function BloodSacrifice:PostNewLevel()
    for _, player in pairs(PlayerManager.GetPlayers()) do
        local data = ty:GetLibData(player)
        data.BloodSacrifice.VesselList = {}
    end
end
BloodSacrifice:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, BloodSacrifice.PostNewLevel)

function BloodSacrifice:PostPlayerUpdate(player)
    local data = ty:GetLibData(player)
    local sprite = player:GetSprite()
    if data.Init and data.BloodSacrifice.PlaySound and sprite:GetAnimation() == "Appear" then
        local vesselTable = data.BloodSacrifice.VesselList[#data.BloodSacrifice.VesselList]
        local vessel = GetVesselFromSeed(vesselTable.InitSeed)
        if sprite:GetFrame() == 20 then
            local slotData = ty:GetLibData(vessel)
            slotData.Broken = true
            vessel:TakeDamage(1, DamageFlag.DAMAGE_EXPLOSION, EntityRef(nil), 0)
            vessel.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            vessel:GetSprite():Play("Broken", true)
            local color = sprite.Color
            sprite.Color = Color(color.R, color.G, color.B, 1, color.RO, color.GO, color.BO)
        elseif sprite:GetFrame() >= 28 then
            player:StopExtraAnimation()
            ty.SFXMANAGER:Play(SoundEffect.SOUND_DEMON_HIT)
            table.remove(data.BloodSacrifice.VesselList)
            data.BloodSacrifice.PlaySound = false
        end
    end
end
BloodSacrifice:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, BloodSacrifice.PostPlayerUpdate)

function BloodSacrifice:PreSlotCreateExplosionDrops(slot)
    return false
end
BloodSacrifice:AddCallback(ModCallbacks.MC_PRE_SLOT_CREATE_EXPLOSION_DROPS, BloodSacrifice.PreSlotCreateExplosionDrops, ty.CustomEntities.BLOODSACRIFICEVESSEL)

function BloodSacrifice:PostSlotUpdate(slot)
    local vessel = slot:ToSlot()
    local slotData = ty:GetLibData(vessel)
    if not slotData.Broken and vessel.GridCollisionClass == EntityGridCollisionClass.GRIDCOLL_GROUND then
        vessel.Velocity = Vector(0, 0)
        vessel:GetSprite():Play("Broken", true)
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_SPLAT, 0, vessel.Position, Vector(0, 0), nil)
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 0, vessel.Position, Vector(0, 0), nil)
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.LARGE_BLOOD_EXPLOSION, 0, vessel.Position, Vector(0, 0), nil)
        slotData.Broken = true
        vessel.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        local rng = vessel:GetDropRNG()
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_BONE, vessel.Position, Vector(1, 1):Normalized():Resized(3 + rng:RandomFloat() * 5):Rotated(rng:RandomInt(360)), nil):ToPickup()
        local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_LEMON_MISHAP, 0, vessel.Position, Vector(0, 0), player):ToEffect()
        creep.Color = Color(0, 0, 0, 1, 123/255, 12/255, 12/255)
        creep:SetDamageSource(EntityType.ENTITY_PLAYER)
        creep.CollisionDamage = 8
        creep:SetTimeout(160)
        creep:Update()
        RemoveFromList(vessel.InitSeed)
    end
end
BloodSacrifice:AddCallback(ModCallbacks.MC_POST_SLOT_UPDATE, BloodSacrifice.PostSlotUpdate, ty.CustomEntities.BLOODSACRIFICEVESSEL)

function BloodSacrifice:PostReviveBloodSacrifice(player, reviver)
    local data = ty:GetLibData(player)
    if #data.BloodSacrifice.VesselList > 0 and type(data.BloodSacrifice.VesselList[#data.BloodSacrifice.VesselList]) == "table" then
        local vesselTable = data.BloodSacrifice.VesselList[#data.BloodSacrifice.VesselList]
        player:AddSoulHearts(-99)
        player:AddMaxHearts(-99)
        player:AddBoneHearts(-99)
        player:AddMaxHearts(2)
        player:AddHearts(2)
        local color = player:GetSprite().Color
        player:GetSprite().Color = Color(color.R, color.G, color.B, 0, color.RO, color.GO, color.BO)
        data.BloodSacrifice.Respawning = true
        ty.GAME:StartRoomTransition(vesselTable.RoomIndex, Direction.UP, RoomTransitionAnim.FADE_MIRROR, player, -1)
        ty.SFXMANAGER:Stop(SoundEffect.SOUND_MIRROR_EXIT)
        ty.SFXMANAGER:Play(SoundEffect.SOUND_MEATY_DEATHS)
        ty.SFXMANAGER:Play(SoundEffect.SOUND_DEVILROOM_DEAL)
    else
        player:Die()
    end
end

function BloodSacrifice:PreRevive(player)
    local data = ty:GetLibData(player)
    if #data.BloodSacrifice.VesselList > 0 and type(data.BloodSacrifice.VesselList[#data.BloodSacrifice.VesselList]) == "table" then
        return { BeforeVanilla = true, Callback = BloodSacrifice.PostReviveBloodSacrifice }
    end
end
BloodSacrifice:AddPriorityCallback("TY_PRE_PLAYER_REVIVE", 9, BloodSacrifice.PreRevive)

return BloodSacrifice