local Conjunctivitis = ty:DefineANewClass()

local stat = ty.Stat

local cached = false
local playSound = true

local function GetTailedLength(player, tear)
    if tear:HasTearFlags(TearFlags.TEAR_ORBIT_ADVANCED) then
        return 3
    elseif tear:HasTearFlags(TearFlags.TEAR_CHAIN) then
        return 2
    else
        return math.max(2, math.min(math.floor(player.TearRange / 78), 12))
    end
end

local function GetTailedDamage(player, tear)
    return math.max(player.ShotSpeed * tear.CollisionDamage * 0.02 * tear.Velocity:Length(), tear.CollisionDamage * 0.1)
end

local function FireNewTear(player, tear)
    if tear.TearFlags & TearFlags.TEAR_POP == TearFlags.TEAR_POP and tear.Velocity:Length() >= 0.5 then
        return
    end
    if tear.TearFlags & TearFlags.TEAR_ABSORB == TearFlags.TEAR_ABSORB or tear.TearFlags & TearFlags.TEAR_LASERSHOT == TearFlags.TEAR_LASERSHOT then
        return
    end
    local newTear = Isaac.Spawn(EntityType.ENTITY_TEAR, tear.Variant, 0, tear.Position, tear.Velocity:Normalized():Resized(0.01), tear.SpawnerEntity):ToTear()
    newTear.TearFlags = tear.TearFlags
    local newTearData = ty:GetLibData(newTear)
    if tear:HasTearFlags(TearFlags.TEAR_POP) then
        newTear.FallingAcceleration = -0.1
    else
        newTear.FallingAcceleration = tear.FallingAcceleration
    end
    newTear.FallingSpeed = 0
    newTear.ContinueVelocity = tear.ContinueVelocity
    newTear.Height = tear.Height
    newTear:GetSprite().Rotation = tear:GetSprite().Rotation
    newTear.Scale = tear.Scale
    newTear.CollisionDamage = GetTailedDamage(player, tear)
    newTear.Color = tear.Color
    newTearData.Tailed = GetTailedLength(player, tear)
    newTearData.MaxTailed = newTearData.Tailed
    if newTear:HasTearFlags(TearFlags.TEAR_HOMING) then
        newTear:ClearTearFlags(TearFlags.TEAR_HOMING)
    end
    if newTear:HasTearFlags(TearFlags.TEAR_SPLIT) then
        newTear:ClearTearFlags(TearFlags.TEAR_SPLIT)
    end
    if newTear:HasTearFlags(TearFlags.TEAR_QUADSPLIT) then
        newTear:ClearTearFlags(TearFlags.TEAR_QUADSPLIT)
    end
    if newTear:HasTearFlags(TearFlags.TEAR_CHAIN) then
        newTear:ClearTearFlags(TearFlags.TEAR_CHAIN)
    end
    if newTear:HasTearFlags(TearFlags.TEAR_ABSORB) then
        newTear:ClearTearFlags(TearFlags.TEAR_ABSORB)
    end
end

function Conjunctivitis:EvaluateCache(player, cacheFlag)
    if player:HasCollectible(ty.CustomCollectibles.CONJUNCTIVITIS) then
        if cacheFlag == CacheFlag.CACHE_TEARFLAG then
            if not player:HasCollectible(CollectibleType.COLLECTIBLE_LACHRYPHAGY) and (player:HasWeaponType(WeaponType.WEAPON_TEARS) or player:HasWeaponType(WeaponType.WEAPON_FETUS)) then
                player.TearFlags = player.TearFlags | TearFlags.TEAR_SPECTRAL | TearFlags.TEAR_PIERCING
            end
        end
        if cacheFlag == CacheFlag.CACHE_FIREDELAY then
            stat:AddTearsMultiplier(player, 0.8)
        end
        if cacheFlag == CacheFlag.CACHE_SHOTSPEED and player:HasCollectible(CollectibleType.COLLECTIBLE_TRISAGION) then
            player.ShotSpeed = player.ShotSpeed * 0.8
        end
    end
end
Conjunctivitis:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Conjunctivitis.EvaluateCache)

function Conjunctivitis:PostPlayerUpdate(player)
    if player:HasCollectible(ty.CustomCollectibles.CONJUNCTIVITIS) then
        if cached == false and player:HasCollectible(CollectibleType.COLLECTIBLE_TRISAGION) then
            player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
            cached = true
        end
    end
end
Conjunctivitis:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Conjunctivitis.PostPlayerUpdate)

function Conjunctivitis:PostFireTear(tear)
    local tear = tear:ToTear()
    local player = ty:GetPlayerFromTear(tear)
    if player and player:HasCollectible(ty.CustomCollectibles.CONJUNCTIVITIS) then
        playSound = true
    end
end
Conjunctivitis:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, Conjunctivitis.PostFireTear)

function Conjunctivitis:PreSFXPlay(id, volume, frameDelay, loop, pitch, pan)
    if PlayerManager.AnyoneHasCollectible(ty.CustomCollectibles.CONJUNCTIVITIS) then
        if id ==  SoundEffect.SOUND_TEARS_FIRE or id == SoundEffect.SOUND_PLOP then
            if playSound then
                playSound = false
            else
                return false
            end
        end
    end
end
Conjunctivitis:AddCallback(ModCallbacks.MC_PRE_SFX_PLAY, Conjunctivitis.PreSFXPlay)

function Conjunctivitis:PostTearUpdate(tear)
    local tear = tear:ToTear()
    local player = ty:GetPlayerFromTear(tear)
    local tearData = ty:GetLibData(tear)
    if player and player:HasCollectible(ty.CustomCollectibles.CONJUNCTIVITIS) then
        if tearData.Tailed == nil and tear.CollisionDamage >= 1 then
            FireNewTear(player, tear)
        end
        if tear:HasTearFlags(TearFlags.TEAR_LASERSHOT) then
            local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_HOLYWATER, 0, tear.Position, Vector(0, 0), nil):ToEffect()
            creep.CollisionDamage = player.Damage * 3
            creep.Color = tear.Color
            creep.Scale = 0.35
            creep:SetTimeout(60)
            creep:Update()
        end
        if tear.Variant == TearVariant.MULTIDIMENSIONAL then
            tear.CollisionDamage = player.Damage * 4
            local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_BLACK, 0, tear.Position, Vector(0, 0), nil):ToEffect()
            creep:SetTimeout(60)
            creep:Update()
        end
        if not tearData.MaxTailed and tear.Velocity:Length() < 0.02 and (tear:HasTearFlags(TearFlags.TEAR_CONTINUUM) or math.abs(tear.Color:GetOffset().R - 0.60784316062927) < 1e-10 or math.abs(tear.Color:GetOffset().R - 0.54117649793625) < 1e-10 or math.abs(tear.Color:GetOffset().R + 0.39215689897537) < 1e-10) then
            tear:ChangeVariant(TearVariant.GRIDENT)
            tear:Remove()
        end
    end
    if tearData.Tailed then
        tearData.Tailed = tearData.Tailed - 1
        if tearData.Tailed <= 0 then
            tear:Remove()
        else
            local oldColor = tear:GetSprite().Color
            local oldColorize = oldColor:GetColorize()
            oldColor:SetColorize(oldColorize.R, oldColorize.G, oldColorize.B, oldColorize.A)
            oldColor:SetTint(tear.Color.R, tear.Color.G, tear.Color.B, tearData.Tailed / tearData.MaxTailed)
        end
    end
end
Conjunctivitis:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, Conjunctivitis.PostTearUpdate)

function Conjunctivitis:PostTearInit(tear)
    local tear = tear:ToTear()
    local player = ty:GetPlayerFromTear(tear)
    local tearData = ty:GetLibData(tear)
    if player and player:HasCollectible(ty.CustomCollectibles.CONJUNCTIVITIS) and not tearData.MaxTailed then
        tear:ChangeVariant(TearVariant.GRIDENT)
        tear:Remove()
    end
end
Conjunctivitis:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, Conjunctivitis.PostTearInit, TearVariant.MULTIDIMENSIONAL)

return Conjunctivitis