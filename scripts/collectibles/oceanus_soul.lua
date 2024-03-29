local OceanusSoul = ty:DefineANewClass()

local burningEnemies = { [10] = 2, [15] = 3, [41] = 4, [54] = 0,  [87] = 1, [208] = 2, [226] = 2, [818] = 2, [824] = 1, [825] = 0, [841] = true, [915] = 0 }
local bannedGridRooms = { GridRooms.ROOM_DUNGEON_IDX, GridRooms.ROOM_GIDEON_DUNGEON_IDX, GridRooms.ROOM_ROTGUT_DUNGEON1_IDX, GridRooms.ROOM_ROTGUT_DUNGEON2_IDX }
local stopFlushSound = false

local function GetHighestDamageFromAllPlayers()
    local damage = 0
    for _, player in pairs(PlayerManager.GetPlayers()) do
        if player:HasCollectible(ty.CustomCollectibles.OCEANUSSOUL) and player.Damage > damage then
            damage = player.Damage
        end
    end
    return damage
end

local function GetPlaybackSpeed(player)
    if player:ToFamiliar() then
        player = player:ToFamiliar().Player
    end
    local playbackSpeed = 33 / (player.MaxFireDelay + 1)
    if player:HasCollectible(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK) then
        playbackSpeed = playbackSpeed / 2.5
    end
    return playbackSpeed
end

local function SpawnChargeBar(player)
    local chargeBar = Isaac.Spawn(EntityType.ENTITY_EFFECT, ty.CustomEffects.OCEANUSSOULCHARGEBAR, 0, Vector(player.Position.X + 18, player.Position.Y - (player.SpriteScale.Y * 33) - 27), player.Velocity, nil):ToEffect()
	local chargeBarSprite = chargeBar:GetSprite()
	local chargeBarData = ty:GetLibData(chargeBar)
	chargeBarData.Owner = player
    if player:ToPlayer() then
        chargeBar.Position = Vector(player.Position.X - 18, player.Position.Y - (player.SpriteScale.Y * 33) - 27)
    end
    chargeBar:FollowParent(player)
    chargeBar:AddEntityFlags(EntityFlag.FLAG_PERSISTENT)
	chargeBarSprite.PlaybackSpeed = GetPlaybackSpeed(player)
	chargeBarSprite:Play("Charging")
	chargeBar.DepthOffset = 102
end

local function HasChargeBar(player)
	for _, effect in pairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, ty.CustomEffects.OCEANUSSOULCHARGEBAR, 0)) do
		local effectData = ty:GetLibData(effect)
		if effectData.Owner and GetPtrHash(effectData.Owner) == GetPtrHash(player) and not effect:GetSprite():IsPlaying("Disappear") then
			return true
		end
	end
	return false
end

local function GetChargeBarPercent(player)
	for _, effect in pairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, ty.CustomEffects.OCEANUSSOULCHARGEBAR, 0)) do
		local effectData = ty:GetLibData(effect)
		if effectData.Owner and GetPtrHash(effectData.Owner) == GetPtrHash(player) then
            local sprite = effect:GetSprite()
            if sprite:IsPlaying("Charging") then
                return sprite:GetFrame() / 101
            end
            if sprite:IsPlaying("Charged") then
                return 1
            end
		end
	end
	return nil
end

local function DisappearChargeBar(player)
	for _, effect in pairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, ty.CustomEffects.OCEANUSSOULCHARGEBAR, 0)) do
		local effectData = ty:GetLibData(effect)
		if effectData.Owner and GetPtrHash(effectData.Owner) == GetPtrHash(player) then
			local sprite = effect:GetSprite()
			if not sprite:IsPlaying("Disappear") then
                sprite.PlaybackSpeed = 1
				sprite:Play("Disappear", true)
			end
		end
	end
end

local function IsInValidRoom(room)
    return room:GetType() ~= RoomType.ROOM_DUNGEON and not ty:IsValueInTable(ty.LEVEL:GetCurrentRoomIndex(), bannedGridRooms)
end

local function GetDefaultLaserColor(player)
    local laserColor = player:GetLaserColor()
    local laserColorize = laserColor:GetColorize()
    local laserOffset = laserColor:GetOffset()
    if math.abs(laserColorize.R) + math.abs(laserColorize.G) + math.abs(laserColorize.B) + math.abs(laserOffset.R) + math.abs(laserOffset.G) + math.abs(laserOffset.B) == 0 then
        return Color(1, 1, 1, 0.4, 0.1, 0.1, 0.1, 4.5, 4.5, 6, 1)
    end
    return Color(laserColor.R, laserColor.G, laserColor.B, laserColor.A * 0.4, laserOffset.R, laserOffset.G, laserOffset.B, laserColorize.R, laserColorize.G, laserColorize.B, laserColorize.A)
end

local function SpawnLaser(player, index, percent)
    local isFamiliar = false
    local laser = Isaac.Spawn(EntityType.ENTITY_EFFECT, ty.CustomEffects.OCEANUSSOULLASER, 0, player.Position, Vector(0, 0), player)
    laser.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
    local laserData = ty:GetLibData(laser)
    laserData.Owner = player
    if player:ToFamiliar() then
        player = player:ToFamiliar().Player
        isFamiliar = true
    end
    local laserSprite = laser:GetSprite()
    laserData.Timeout = 90
    laserData.Delay = index * 3
    laserData.TearFlags = 1 << -1
    laserData.Weapon = 1 << 1
    laserData.IpecacTimeout = -1
    laserData.Percent = percent or 0
    if isFamiliar then
        laserSprite.Scale = Vector(0.5, 0.5)
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK) then
        local scale = 0.6 + percent ^ 0.8
        laserSprite.Scale = Vector(scale, scale)
        ty.SFXMANAGER:Play(SoundEffect.SOUND_LASERRING_STRONG, 0.6, 2, false, 1 / scale, 0)
    else
        local scale = math.max(0.5, percent ^ 0.8)
        laserSprite.Scale = Vector(scale, scale)
        ty.SFXMANAGER:Play(SoundEffect.SOUND_LASERRING_STRONG, 0.6, 2, false, 1 / scale, 0)
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) or player:GetPlayerType() == PlayerType.PLAYER_AZAZEL or player:GetPlayerType() == PlayerType.PLAYER_AZAZEL_B then
        laserData.Weapon = laserData.Weapon | 1 << 2
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY) or player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY_2) or player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY_ZERO) then
        laserData.Weapon = laserData.Weapon | 1 << 3
        laserSprite:Load("gfx/effects/oceanus_soul_tech_laser.anm2", true)
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_KNIFE) then
        laserData.Weapon = laserData.Weapon | 1 << 4
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_DR_FETUS) then
        laserData.Weapon = laserData.Weapon | 1 << 5
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_EPIC_FETUS) then
        laserData.Weapon = laserData.Weapon | 1 << 6
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE) then
        laserData.Weapon = laserData.Weapon | 1 << 8
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_X) then
        laserData.Weapon = laserData.Weapon | 1 << 9
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_SPIRIT_SWORD) then
        laserData.Weapon = laserData.Weapon | 1 << 13
    end
    if player.TearFlags & TearFlags.TEAR_HOMING == TearFlags.TEAR_HOMING then
        laserData.TearFlags = laserData.TearFlags | TearFlags.TEAR_HOMING
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_MY_REFLECTION) then
        laserData.TearFlags = laserData.TearFlags | TearFlags.TEAR_BOOMERANG
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_SPIDER_BITE) or player:HasCollectible(CollectibleType.COLLECTIBLE_BALL_OF_TAR) or player:HasCollectible(CollectibleType.COLLECTIBLE_INTRUDER) then
        laserData.TearFlags = laserData.TearFlags | TearFlags.TEAR_SLOW
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_COMMON_COLD) or player:HasCollectible(CollectibleType.COLLECTIBLE_SCORPIO) then
        laserData.TearFlags = laserData.TearFlags | TearFlags.TEAR_POISON
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_PARASITE) then
        laserData.TearFlags = laserData.TearFlags | TearFlags.TEAR_SPLIT
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_CONTACTS) then
        laserData.TearFlags = laserData.TearFlags | TearFlags.TEAR_FREEZE
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_LUMP_OF_COAL) then
        laserData.TearFlags = laserData.TearFlags | TearFlags.TEAR_GROW
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_IPECAC) then
        laserData.IpecacTimeout = 30
        laserData.TearFlags = laserData.TearFlags | TearFlags.TEAR_POISON | TearFlags.TEAR_EXPLOSIVE
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_MULLIGAN) then
        laserData.TearFlags = laserData.TearFlags | TearFlags.TEAR_MULLIGAN
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_3_DOLLAR_BILL) or player:HasCollectible(CollectibleType.COLLECTIBLE_FRUIT_CAKE) or player:HasCollectible(CollectibleType.COLLECTIBLE_PLAYDOUGH_COOKIE) then
        laserData.RandomEffect = true
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_EYESHADOW) then
        laserData.TearFlags = laserData.TearFlags | TearFlags.TEAR_CHARM
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_IRON_BAR) or player:HasCollectible(CollectibleType.COLLECTIBLE_GLAUCOMA) or player:HasCollectible(CollectibleType.COLLECTIBLE_KNOCKOUT_DROPS) then
        laserData.TearFlags = laserData.TearFlags | TearFlags.TEAR_CONFUSION
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_LOST_CONTACT) then
        laserData.TearFlags = laserData.TearFlags | TearFlags.TEAR_SHIELDED
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_RUBBER_CEMENT) then
        laserData.TearFlags = laserData.TearFlags | TearFlags.TEAR_BOUNCE
        laserData.RubberCement = 0
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_ANTI_GRAVITY) then
        laserData.Delay = laserData.Delay + 60
        laserData.TearFlags = laserData.TearFlags | TearFlags.TEAR_WAIT
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_CRICKETS_BODY) then
        laserData.TearFlags = laserData.TearFlags | TearFlags.TEAR_QUADSPLIT
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_PERFUME) or player:HasCollectible(CollectibleType.COLLECTIBLE_ABADDON) or player:HasCollectible(CollectibleType.COLLECTIBLE_DARK_MATTER) then
        laserData.TearFlags = laserData.TearFlags | TearFlags.TEAR_FEAR
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_FIRE_MIND) then
        laserData.TearFlags = laserData.TearFlags | TearFlags.TEAR_BURN
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_PROPTOSIS) then
        laserData.TearFlags = laserData.TearFlags | TearFlags.TEAR_SHRINK
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_AQUARIUS) then
        laserData.Aquarius = true
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_STRANGE_ATTRACTOR) then
        laser:AddEntityFlags(EntityFlag.FLAG_MAGNETIZED)
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_MYSTERIOUS_LIQUID) then
        laserData.TearFlags = laserData.TearFlags | TearFlags.TEAR_MYSTERIOUS_LIQUID_CREEP
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_CONTINUUM) then
        laserData.TearFlags = laserData.TearFlags | TearFlags.TEAR_CONTINUUM
        if not player:HasCollectible(CollectibleType.COLLECTIBLE_RUBBER_CEMENT) then
            laser.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
        end
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_GODS_FLESH) then
        laserData.TearFlags = laserData.TearFlags | TearFlags.TEAR_GODS_FLESH
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_EXPLOSIVO) then
        laserData.TearFlags = laserData.TearFlags | TearFlags.TEAR_STICKY
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_SINUS_INFECTION) then
        laserData.TearFlags = laserData.TearFlags | TearFlags.TEAR_BOOGER
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_PARASITOID) then
        laserData.TearFlags = laserData.TearFlags | TearFlags.TEAR_EGG
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_SULFURIC_ACID) or player:HasCollectible(CollectibleType.COLLECTIBLE_TERRA) then
        laserData.TearFlags = laserData.TearFlags | TearFlags.TEAR_ACID
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_JACOBS_LADDER) then
        laserData.TearFlags = laserData.TearFlags | TearFlags.TEAR_JACOBS
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_GHOST_PEPPER) then
        laserData.GhostPepper = true
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_EUTHANASIA) then
        laserData.TearFlags = laserData.TearFlags | TearFlags.TEAR_NEEDLE
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_LITTLE_HORN) then
        laserData.TearFlags = laserData.TearFlags | TearFlags.TEAR_HORN
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_BACKSTABBER) then
        laserData.TearFlags = laserData.TearFlags | TearFlags.TEAR_BACKSTAB
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_URANUS) then
        laserData.TearFlags = laserData.TearFlags | TearFlags.TEAR_ICE
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_OCULAR_RIFT) then
        laserData.TearFlags = laserData.TearFlags | TearFlags.TEAR_OCCULT
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRDS_EYE) then
        laserData.BirdsEye = true
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_LODESTONE) then
        laserData.TearFlags = laserData.TearFlags | TearFlags.TEAR_MAGNETIZE
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_ROTTEN_TOMATO) then
        laserData.TearFlags = laserData.TearFlags | TearFlags.TEAR_BAIT
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_KNOCKOUT_DROPS) then
        laserData.TearFlags = laserData.TearFlags | TearFlags.TEAR_KNOCKBACK
    end
    if laserData.Weapon & 1 << 2 == 1 << 2 then
        for i = 0, 1 do
            local brimstone = player:FireBrimstone(Vector.FromAngle(i * 180), laser, laserSprite.Scale.X)
            brimstone.Parent = laser
            brimstone.PositionOffset = Vector(0, 0)
            brimstone:SetActiveRotation(0, 360, 360 / laserData.Timeout, true)
            brimstone:GetSprite().Color = GetDefaultLaserColor(player)
            brimstone:SetMaxDistance(9999)
            brimstone:SetScale(laserSprite.Scale.X)
        end
    end
    if laserData.Weapon & 1 << 4 == 1 << 4 then
        for i = 0, 3 do
            local knife = player:FireKnife(laser, i * 90, true, 0, 0)
            knife.CollisionDamage = player.Damage / 4
            local knifeData = ty:GetLibData(knife)
            knifeData.OceanusSoul = true
        end
    end
    if laserData.Weapon & 1 << 9 == 1 << 9 then
        for i = 0, 3 do
            local brimstone = player:FireBrimstone(Vector.FromAngle(45 + i * 90), laser, laserSprite.Scale.X)
            brimstone.Parent = laser
            brimstone.PositionOffset = Vector(0, 0)
            brimstone:SetActiveRotation(0, 360, 360 / laserData.Timeout, true)
            brimstone:GetSprite().Color = GetDefaultLaserColor(player)
            brimstone:SetMaxDistance(9999)
            brimstone:SetScale(laserSprite.Scale.X)
        end
    end
    laser:GetSprite().Color = GetDefaultLaserColor(player)
    laserSprite:Play("Start", true)
    laser.Velocity = player:GetLastDirection():Resized(player.ShotSpeed * 4) + player:GetMovementVector():Resized(player.ShotSpeed * 2)
    if IsInValidRoom(ty.GAME:GetRoom()) then
        local whirlPool = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.WHIRLPOOL, 0, laser.Position, Vector(0, 0), laser):ToEffect()
        whirlPool:GetSprite().Scale = laserSprite.Scale * 0.75
        whirlPool:FollowParent(laser)
        whirlPool:GetSprite().Color = Color(1, 1, 1, 0.4)
        laserData.Whirl = whirlPool
        local whirlPoolParticle = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.WHIRLPOOL, 1, laser.Position, Vector(0, 0), laser):ToEffect()
        whirlPoolParticle:GetSprite().Scale = laserSprite.Scale * 0.65
        whirlPoolParticle:FollowParent(whirlPool)
        whirlPoolParticle:GetSprite().Color = Color(1, 1, 1, 0.8)
        if laserData.Weapon & 1 << 8 == 1 << 8 then
            whirlPoolParticle:AddEntityFlags(EntityFlag.FLAG_MAGNETIZED)
        end
        laserData.WhirlParticle = whirlPoolParticle
    else
        laserData.Homing = true
    end
end

local function GetLaserCount(player)
    if player:ToFamiliar() then
        player = player:ToFamiliar().Player
    end
    local num = player:GetMultiShotParams(WeaponType.WEAPON_TEARS):GetNumTears() + player:GetCollectibleNum(CollectibleType.COLLECTIBLE_MONSTROS_LUNG) * 3
    local rng = player:GetCollectibleRNG(ty.CustomCollectibles.OCEANUSSOUL)
    if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_EYE) and rng:RandomInt(100) < 50 + 10 * player.Luck then
        num = num + 1
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_LOKIS_HORNS) and rng:RandomInt(100) < 25 + 5 * player.Luck then
        num = num + 3
    end
    return num
end

local function SpawnLasers(player, percent)
    for i = 0, GetLaserCount(player) - 1 do
        SpawnLaser(player, i, percent)
    end
end

local function SetPlayerWeapon(player)
    local mainWeapon = player:GetWeapon(1)
    if mainWeapon and mainWeapon:GetWeaponType() ~= WeaponType.WEAPON_BONE and mainWeapon:GetWeaponType() ~= WeaponType.WEAPON_NOTCHED_AXE and mainWeapon:GetWeaponType() ~= WeaponType.WEAPON_URN_OF_SOULS and mainWeapon:GetWeaponType() ~= WeaponType.WEAPON_UMBILICAL_WHIP then
        Isaac.DestroyWeapon(mainWeapon)
    end
end

local function GetNearestEnemyInOrder(position)
	local distance = 256
    local nearestEnemy = nil
    for _, ent in pairs(Isaac.FindInRadius(position, 256, EntityPartition.ENEMY)) do
        if ty:IsValidCollider(ent) and (ent.Position - position):Length() < distance then
            distance = (ent.Position - position):Length()
            nearestEnemy = ent
        end
    end
    return nearestEnemy
end

local function DoFlushEnemies(player)
    local room = ty.GAME:GetRoom()
    for _, ent in pairs(Isaac.FindInRadius(Vector(0, 0), 8192, EntityPartition.ENEMY)) do
        if ent:IsVulnerableEnemy() and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
            local data = ty:GetLibData(ent)
            data.Invincible = true
            ent:SetInvincible(true)
            ent:AddEntityFlags(EntityFlag.FLAG_FRIENDLY)
        end
    end
    stopFlushSound = true
    player:UseActiveItem(CollectibleType.COLLECTIBLE_FLUSH, false, false)
    for _, ent in pairs(Isaac.FindInRadius(Vector(0, 0), 8192, EntityPartition.ENEMY)) do
        local data = ty:GetLibData(ent)
        if data.Invincible then
            data.Invincible = nil
            ent:SetInvincible(false)
            ent:ClearEntityFlags(EntityFlag.FLAG_FRIENDLY)
        end
    end
end

local function GetTears(player, tears)
    if player:HasCollectible(CollectibleType.COLLECTIBLE_DR_FETUS) then
        tears = tears * 2
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_EPIC_FETUS) then
        tears = tears * 0.8
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_X) then
        tears = tears * 0.7
    end
    tears = tears * 0.6
    if tears < 30 / 11 and player:HasCollectible(ty.CustomCollectibles.CONSERVATIVETREATMENT) then
        return 30 / 11
    end
    return tears
end

function OceanusSoul:UpdateLaser(effect)
    local room = ty.GAME:GetRoom()
    local sprite = effect:GetSprite()
    local data = ty:GetLibData(effect)
    local player = data.Owner
    if player:ToFamiliar() then
        player = player:ToFamiliar().Player
    end
    local rng = player:GetCollectibleRNG(ty.CustomCollectibles.OCEANUSSOUL)
    if effect.FrameCount >= 20 then
        if not data.Whirl:HasEntityFlags(EntityFlag.FLAG_MAGNETIZED) then
            data.Whirl:AddEntityFlags(EntityFlag.FLAG_MAGNETIZED)
        end
        if data.Weapon | 1 << 8 == 1 << 8 and not data.WhirlParticle:HasEntityFlags(EntityFlag.FLAG_MAGNETIZED) then
            data.WhirlParticle:AddEntityFlags(EntityFlag.FLAG_MAGNETIZED)
        end
    end
    if sprite:IsFinished("Start") then
        sprite:Play("Loop", true)
    end
    if sprite:IsPlaying("Loop") then
        if data.TearFlags & TearFlags.TEAR_CONTINUUM ~= TearFlags.TEAR_CONTINUUM and data.TearFlags & TearFlags.TEAR_BOUNCE ~= TearFlags.TEAR_BOUNCE and effect:CollidesWithGrid() then
            effect.Velocity = Vector(0, 0)
        end
        if data.Timeout > 0 then
            local enemy = nil
            if data.TearFlags & TearFlags.TEAR_BOOMERANG == TearFlags.TEAR_BOOMERANG then
                enemy = GetNearestEnemyInOrder(player.Position) or player
            else
                enemy = GetNearestEnemyInOrder(effect.Position) or player
            end
            if data.Delay == 0 then
                if data.Homing or data.TearFlags & TearFlags.TEAR_HOMING == TearFlags.TEAR_HOMING then
                    if enemy:ToPlayer() then
                        if effect.Velocity:Length() >= player.ShotSpeed * 2 then
                            effect:AddVelocity(-effect.Velocity:Resized(0.06))
                        end
                    else
                        if effect.Velocity:Length() < player.ShotSpeed * 6 then
                            local targetPosition = enemy.Position
                            if data.TearFlags & TearFlags.TEAR_ORBIT == TearFlags.TEAR_ORBIT then
                                targetPosition = targetPosition + Vector(math.sin(data.RotationAngle), math.cos(data.RotationAngle)) * enemy.Size * 0.5
                            end
                            effect:AddVelocity((targetPosition - effect.Position):Normalized():Resized(player.ShotSpeed * 0.8))
                        else
                            effect:AddVelocity(-effect.Velocity:Resized(0.4))
                        end
                    end
                else
                    if enemy:ToPlayer() then
                        if effect.Velocity:Length() >= player.ShotSpeed * 2 then
                            effect:AddVelocity(-effect.Velocity:Resized(0.06))
                        end
                    else
                        effect:AddVelocity(-effect.Velocity:Resized(0.03))
                    end
                end
            else
                data.Delay = data.Delay - 1
            end
            if data.TearFlags & TearFlags.TEAR_BOUNCE == TearFlags.TEAR_BOUNCE then
                if data.RubberCement > 0 then
                    data.RubberCement = data.RubberCement - 1
                else
                    if (not room:IsPositionInRoom(effect.Position + Vector(0, 8), 0) and room:IsPositionInRoom(effect.Position + Vector(0, -8), 0)) or (not room:IsPositionInRoom(effect.Position + Vector(0, -8), 0) and room:IsPositionInRoom(effect.Position + Vector(0, 8), 0)) then
                        effect.Velocity = Vector(effect.Velocity.X, -effect.Velocity.Y)
                        data.RubberCement = 5
                    end
                    if (not room:IsPositionInRoom(effect.Position + Vector(8, 0), 0) and room:IsPositionInRoom(effect.Position + Vector(-8, 0), 0)) or (not room:IsPositionInRoom(effect.Position + Vector(-8, 0), 0) and room:IsPositionInRoom(effect.Position + Vector(8, 0), 0)) then
                        effect.Velocity = Vector(-effect.Velocity.X, effect.Velocity.Y)
                        data.RubberCement = 5
                    end
                end
            elseif data.TearFlags & TearFlags.TEAR_CONTINUUM == TearFlags.TEAR_CONTINUUM then
                local roomSize = room:GetGridSize()
                local roomWidth = room:GetGridWidth()
                if room:GetGridIndex(effect.Position) == -1 and not data.Continuum then
                    local clampedGridIndex = room:GetClampedGridIndex(effect.Position)
                    if clampedGridIndex % roomWidth == 0 then
                        effect.Position = room:GetGridPosition(clampedGridIndex + roomWidth - 1) + Vector(40, effect.Position.Y - room:GetGridPosition(clampedGridIndex).Y)
                    elseif clampedGridIndex % roomWidth == roomWidth - 1 then
                        effect.Position = room:GetGridPosition(clampedGridIndex - roomWidth + 1) + Vector(-40, effect.Position.Y - room:GetGridPosition(clampedGridIndex).Y)
                    elseif clampedGridIndex <= roomWidth - 1 then
                        effect.Position = room:GetGridPosition(clampedGridIndex + roomSize - roomWidth) + Vector(effect.Position.X - room:GetGridPosition(clampedGridIndex).X, 40)
                    elseif clampedGridIndex >= roomSize - roomWidth then
                        effect.Position = room:GetGridPosition(clampedGridIndex - roomSize + roomWidth) + Vector(effect.Position.X - room:GetGridPosition(clampedGridIndex).X, -40)
                    end
                    data.Continuum = true
                elseif room:GetGridIndex(effect.Position) ~= -1 and data.Continuum then
                    data.Continuum = false
                end
            end
            if effect.FrameCount % 5 == 0 and data.TearFlags & TearFlags.TEAR_MYSTERIOUS_LIQUID_CREEP == TearFlags.TEAR_MYSTERIOUS_LIQUID_CREEP then
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_GREEN, 0, effect.Position, Vector(0, 0), player)
            end
            if effect.FrameCount % 3 == 0 and data.Aquarius then
                local creep = player:SpawnAquariusCreep()
                creep.Position = effect.Position
            end
            do
                local gridIndex = room:GetGridIndex(effect.Position)
                local grid = room:GetGridEntity(gridIndex)
                if grid and not grid:ToDoor() and data.TearFlags & TearFlags.TEAR_ACID == TearFlags.TEAR_ACID then
                    room:DestroyGrid(gridIndex)
                end
                room:DamageGrid(gridIndex, 10)
            end
            for _, ent in pairs(Isaac.FindInRadius(effect.Position, 24 * sprite.Scale.X, EntityPartition.ENEMY)) do
                if ent.Type == EntityType.ENTITY_MOVABLE_TNT or (ent:IsActiveEnemy() and ent.Type ~= EntityType.ENTITY_FIREPLACE and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) and not ent:HasEntityFlags(EntityFlag.FLAG_CHARM)) then
                    local damage = player.Damage * sprite.Scale.X / 3
                    if data.Weapon & 1 << 3 == 1 << 3 then
                        damage = damage * 1.5
                    end
                    if data.ChocolateMilk then
                        damage = damage * (0.6 + data.Percent)
                    else
                        damage = damage * math.max(0.4, data.Percent)
                    end
                    if player:HasCollectible(CollectibleType.COLLECTIBLE_APPLE) and rng:RandomFloat() < 1 / math.max(1, 15 - math.floor(player.Luck)) then
                        damage = damage * 4
                    elseif player:HasCollectible(CollectibleType.COLLECTIBLE_TOUGH_LOVE) and rng:RandomFloat() < 1 / math.max(1, 10 - math.floor(player.Luck)) then
                        damage = damage * 3.2
                    end
                    if data.Weapon & 1 << 5 == 1 << 5 or data.Weapon & 1 << 6 == 1 << 6 then
                        ent:TakeDamage(damage, DamageFlag.DAMAGE_IGNORE_ARMOR, EntityRef(player), 0)
                    else
                        ent:TakeDamage(damage, 0, EntityRef(player), 0)
                    end
                    if player:HasCollectible(CollectibleType.COLLECTIBLE_HEAD_OF_THE_KEEPER) and rng:RandomInt(100) < 5 then
                        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY, ent.Position, Vector(0, 0), nil)
                    end
                    if effect.FrameCount % 5 == 0 then
                        if player:HasCollectible(CollectibleType.COLLECTIBLE_HOLY_LIGHT) and rng:RandomFloat() < 1 / math.max(2, 10 - math.floor(0.9 * player.Luck)) then
                            local tear = player:FireTear(ent.Position, Vector(0, 0), true, true, false, player, 1)
                            tear:ChangeVariant(TearVariant.GRIDENT)
                            tear.TearFlags = TearFlags.TEAR_LIGHT_FROM_HEAVEN
                        end
                        if data.TearFlags & TearFlags.TEAR_SPLIT == TearFlags.TEAR_SPLIT then
                            local tear = player:FireTear(ent.Position, Vector(0, 0), true, true, false, player, 1)
                            tear:ChangeVariant(TearVariant.GRIDENT)
                            tear.TearFlags = TearFlags.TEAR_SPLIT
                        end
                        if data.TearFlags & TearFlags.TEAR_QUADSPLIT == TearFlags.TEAR_QUADSPLIT then
                            local tear = player:FireTear(ent.Position, Vector(0, 0), true, true, false, player, 0.5)
                            tear:ChangeVariant(TearVariant.GRIDENT)
                            tear.TearFlags = TearFlags.TEAR_QUADSPLIT
                        end
                        if data.TearFlags & TearFlags.TEAR_MULLIGAN == TearFlags.TEAR_MULLIGAN and rng:RandomInt(100) < 17 then
                            local tear = player:FireTear(ent.Position, Vector(0, 0), true, true, false, player, 1)
                            tear:ChangeVariant(TearVariant.GRIDENT)
                            tear.TearFlags = TearFlags.TEAR_MULLIGAN
                        end
                        if data.TearFlags & TearFlags.TEAR_STICKY == TearFlags.TEAR_STICKY and rng:RandomInt(100) < 25 then
                            local tear = player:FireTear(ent.Position, Vector(0, 0), true, true, false, player, 1)
                            tear:ChangeVariant(TearVariant.EXPLOSIVO)
                            tear.TearFlags = TearFlags.TEAR_STICKY
                        end
                        if data.TearFlags & TearFlags.TEAR_EGG == TearFlags.TEAR_EGG and rng:RandomFloat() < 1 / math.max(2, 7 - math.floor(player.Luck)) then
                            local tear = player:FireTear(ent.Position, Vector(0, 0), true, true, false, player, 1)
                            tear:ChangeVariant(TearVariant.EGG)
                            tear.TearFlags = TearFlags.TEAR_EGG
                        end
                        if data.TearFlags & TearFlags.TEAR_BOOGER == TearFlags.TEAR_BOOGER and rng:RandomInt(100) < 20 then
                            local tear = player:FireTear(ent.Position, Vector(0, 0), true, true, false, player, 1)
                            tear:ChangeVariant(TearVariant.BOOGER)
                            tear.TearFlags = TearFlags.TEAR_BOOGER
                        end
                        if data.GhostPepper and rng:RandomFloat() < 1 / math.max(2, 12 - math.floor(player.Luck)) then
                            local fire = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLUE_FLAME, 0, ent.Position, Vector(0, 0), player):ToEffect()
                            fire:SetTimeout(60)
                            fire.CollisionDamage = player.Damage * 6
                        end
                        if data.TearFlags & TearFlags.TEAR_NEEDLE == TearFlags.TEAR_NEEDLE and rng:RandomFloat() < 1 / math.max(4, 30 - math.floor(2 * player.Luck)) then
                            local tear = player:FireTear(ent.Position, Vector(0, 0), true, true, false, player, 1)
                            tear:ChangeVariant(TearVariant.NEEDLE)
                            tear.TearFlags = TearFlags.TEAR_NEEDLE
                        end
                        if data.TearFlags & TearFlags.TEAR_HORN == TearFlags.TEAR_HORN and rng:RandomFloat() < 1 / math.max(5, 20 - math.floor(player.Luck)) then
                            local tear = player:FireTear(ent.Position, Vector(0, 0), true, true, false, player, 1)
                            tear:ChangeVariant(TearVariant.GRIDENT)
                            tear.TearFlags = TearFlags.TEAR_HORN
                        end
                        if data.TearFlags & TearFlags.TEAR_SPORE == TearFlags.TEAR_SPORE and rng:RandomInt(100) < 25 then
                            local tear = player:FireTear(ent.Position, Vector(0, 0), true, true, false, player, 1)
                            tear:ChangeVariant(TearVariant.SPORE)
                            tear.TearFlags = TearFlags.TEAR_SPORE
                        end
                        if data.BirdsEye and rng:RandomFloat() < 1 / math.max(2, 12 - math.floor(player.Luck)) then
                            local fire = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.RED_CANDLE_FLAME, 0, ent.Position, Vector(0, 0), player):ToEffect()
                            fire:SetTimeout(300)
                            fire.CollisionDamage = player.Damage * 4
                        end
                        if data.TearFlags & TearFlags.TEAR_JACOBS == TearFlags.TEAR_JACOBS then
                            local tear = player:FireTear(ent.Position, Vector(0, 0), true, true, false, player, 1)
                            tear:ChangeVariant(TearVariant.GRIDENT)
                            tear.TearFlags = TearFlags.TEAR_JACOBS
                        end
                        if data.TearFlags & TearFlags.TEAR_OCCULT == TearFlags.TEAR_OCCULT and rng:RandomFloat() < 1 / math.max(5, 20 - math.floor(player.Luck)) then
                            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.RIFT, 0, ent.Position, Vector(0, 0), player)
                        end
                        if data.RandomEffect then
                            local tear = player:FireTear(ent.Position, Vector(0, 0), true, true, false, player, 1)
                            tear:ChangeVariant(TearVariant.GRIDENT)
                        end
                        if data.TearFlags & TearFlags.TEAR_EXPLOSIVE == TearFlags.TEAR_EXPLOSIVE then
                            local bomb = player:FireBomb(effect.Position, Vector(0, 0), player)
                            bomb:SetExplosionCountdown(0)
                            bomb.Visible = false
                            bomb:AddTearFlags(TearFlags.TEAR_POISON)
                        end
                    end
                    if data.TearFlags & TearFlags.TEAR_POISON == TearFlags.TEAR_POISON and ent:GetPoisonCountdown() == 0 then
                        ent:AddPoison(EntityRef(player), 30, player.Damage)
                    end
                    if data.TearFlags & TearFlags.TEAR_ICE == TearFlags.TEAR_ICE and ent:GetIceCountdown() == 0 then
                        ent:AddIce(EntityRef(player), 30)
                    end
                    if data.TearFlags & TearFlags.TEAR_BURN == TearFlags.TEAR_BURN and ent:GetBurnCountdown() == 0 then
                        ent:AddBurn(EntityRef(player), 30, player.Damage)
                    end
                    if data.TearFlags & TearFlags.TEAR_SLOW == TearFlags.TEAR_SLOW and ent:GetSlowingCountdown() == 0 then
                        ent:AddSlowing(EntityRef(player), 30, 0.8, Color(1, 1, 1.3, 1, 0.156863, 0.156863, 0.156863))
                    end
                    if data.TearFlags & TearFlags.TEAR_MAGNETIZE == TearFlags.TEAR_MAGNETIZE and ent:GetMagnetizedCountdown() == 0 then
                        ent:AddMagnetized(EntityRef(player), 30)
                    end
                    if data.TearFlags & TearFlags.TEAR_BAIT == TearFlags.TEAR_BAIT and ent:GetBaitedCountdown() == 0 then
                        ent:AddBaited(EntityRef(player), 30)
                    end
                    if data.TearFlags & TearFlags.TEAR_CHARM == TearFlags.TEAR_CHARM and ent:GetCharmedCountdown() == 0 then
                        ent:AddCharmed(EntityRef(player), 30)
                    end
                    if data.TearFlags & TearFlags.TEAR_GODS_FLESH == TearFlags.TEAR_GODS_FLESH and ent:GetShrinkCountdown() == 0 then
                        ent:AddShrink(EntityRef(player), 30)
                    end
                    if data.TearFlags & TearFlags.TEAR_FEAR == TearFlags.TEAR_FEAR and ent:GetFearCountdown() == 0 then
                        ent:AddFear(EntityRef(player), 30)
                    end
                    if data.TearFlags & TearFlags.TEAR_FREEZE == TearFlags.TEAR_FREEZE and ent:GetFreezeCountdown() == 0 then
                        ent:AddFreeze(EntityRef(player), 30)
                    end
                    if data.TearFlags & TearFlags.TEAR_CONFUSION == TearFlags.TEAR_CONFUSION and ent:GetConfusionCountdown() == 0 then
                        ent:AddConfusion(EntityRef(player), 30)
                    end
                    if data.TearFlags & TearFlags.TEAR_BACKSTAB == TearFlags.TEAR_BACKSTAB and ent:GetBleedingCountdown() == 0 then
                        ent:AddBleeding(EntityRef(player), 30)
                    end
                    if data.TearFlags & TearFlags.TEAR_KNOCKBACK == TearFlags.TEAR_KNOCKBACK and ent:GetKnockbackCountdown() == 0 then
                        ent:AddKnockback(EntityRef(player), -effect.Velocity:Normalized(), 15, true)
                    end
                end
            end
            for _, ent in pairs(Isaac.FindByType(EntityType.ENTITY_KNIFE, KnifeVariant.MOMS_KNIFE, KnifeSubType.PROJECTILE)) do
                if ent.Parent and GetPtrHash(ent.Parent) == GetPtrHash(effect) then
                    local knife = ent:ToKnife()
                    if data.Timeout <= 10 and not knife:IsFlying() then
                        knife:Shoot(1, 1000)
                    else
                        if ty:GetLibData(knife).OceanusSoul then
                            knife.Rotation = knife.Rotation + 3
                        end
                    end
                end
            end
            if effect.FrameCount % 5 == 0 and data.TearFlags & TearFlags.TEAR_SHIELDED == TearFlags.TEAR_SHIELDED and rng:RandomFloat() < 0.5 then
                for _, ent in pairs(Isaac.FindInRadius(effect.Position, 16 * sprite.Scale.X, EntityPartition.BULLET)) do
                    ent:Die()
                end
            end
            if data.TearFlags & TearFlags.TEAR_GROW == TearFlags.TEAR_GROW then
                sprite.Scale = sprite.Scale + Vector(1 / 300, 1 / 300)
            end
            if data.TearFlags & TearFlags.TEAR_SHRINK == TearFlags.TEAR_SHRINK then
                sprite.Scale = sprite.Scale - Vector(1 / 200, 1 / 200)
            end
            data.Timeout = data.Timeout - 1
        else
            sprite:Play("End", true)
        end
    end
    if sprite:IsFinished("End") then
        effect:Remove()
    end
end
OceanusSoul:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, OceanusSoul.UpdateLaser, ty.CustomEffects.OCEANUSSOULLASER)

function OceanusSoul:EvaluateCache(player, cacheFlag)
    if player:HasCollectible(ty.CustomCollectibles.OCEANUSSOUL) then
        if cacheFlag == CacheFlag.CACHE_FLYING then
            player.CanFly = true
        end
        if cacheFlag == CacheFlag.CACHE_FIREDELAY then
            ty.Stat:AddTearsModifier(player, function(tears) return GetTears(player, tears) end)
        end
    end
end
OceanusSoul:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, OceanusSoul.EvaluateCache)

function OceanusSoul:FamiliarUpdate(familiar)
    local player = familiar:ToFamiliar().Player
    local room = ty.GAME:GetRoom()
    if player:HasCollectible(ty.CustomCollectibles.OCEANUSSOUL) and (familiar.Variant == FamiliarVariant.CAINS_OTHER_EYE or familiar.Variant == FamiliarVariant.INCUBUS or familiar.Variant == FamiliarVariant.TWISTED_BABY or familiar.Variant == FamiliarVariant.BLOOD_BABY or familiar.Variant == FamiliarVariant.UMBILICAL_BABY) and familiar:GetWeapon() == nil then
        if ty:IsPlayerFiring(player) or (player:HasCollectible(CollectibleType.COLLECTIBLE_MARKED) and not room:IsClear()) then
            if not HasChargeBar(familiar) then
                SpawnChargeBar(familiar)
            end
        else
            if HasChargeBar(familiar) then
                local percent = GetChargeBarPercent(familiar)
                if percent >= 0.1 then
                    SpawnLasers(familiar, percent)
                end
                DisappearChargeBar(familiar)
            end
        end
    else
        if not HasChargeBar(familiar) then
            DisappearChargeBar(familiar)
        end
    end
end
OceanusSoul:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, OceanusSoul.FamiliarUpdate)

function OceanusSoul:PostPlayerUpdate(player)
    local room = ty.GAME:GetRoom()
    local data = ty:GetLibData(player)
    local globalData = ty.GLOBALDATA
    if data.Init and player:HasCollectible(ty.CustomCollectibles.OCEANUSSOUL) then
        if (ty.LEVEL:HasAbandonedMineshaft() and ty.LEVEL:GetDimension() ~= Dimension.MINESHAFT) or not ty.LEVEL:HasAbandonedMineshaft() then
            if ty:IsPlayerFiring(player) or (player:HasCollectible(CollectibleType.COLLECTIBLE_MARKED) and not room:IsClear()) then
                if not HasChargeBar(player) then
                    SpawnChargeBar(player)
                end
                if IsInValidRoom(room) then
                    globalData.OceanusSoul.Strength = math.min(1, globalData.OceanusSoul.Strength + 1 / 200)
                end
            else
                if HasChargeBar(player) then
                    local percent = GetChargeBarPercent(player)
                    if percent >= 0.1 then
                        SpawnLasers(player, percent)
                    end
                    DisappearChargeBar(player)
                end
                if IsInValidRoom(room) then
                    globalData.OceanusSoul.Strength = math.max(1 / 1000, globalData.OceanusSoul.Strength - 1 / 400)
                end
            end
        end
        if IsInValidRoom(room) then
            if globalData.OceanusSoul.Strength == 0 then
                room:SetWaterCurrent(Vector(0, 0))
            else
                room:SetWaterCurrent(player:GetLastDirection():Normalized():Resized(globalData.OceanusSoul.Strength ^ 2))
            end
            if room:GetFrameCount() >= 1 and not ty:IsValueInTable(ty.LEVEL:GetCurrentRoomDesc().ListIndex, globalData.OceanusSoul.RoomList) then
                DoFlushEnemies(player)
                table.insert(globalData.OceanusSoul.RoomList, ty.LEVEL:GetCurrentRoomDesc().ListIndex)
            end
            if ty:IsValueInTable(ty.LEVEL:GetCurrentRoomDesc().ListIndex, globalData.OceanusSoul.RoomList) and room:GetWaterAmount() == 0 then
                DoFlushEnemies(player)
            end
        end
        SetPlayerWeapon(player)
    else
        if HasChargeBar(player) then
            DisappearChargeBar(player)
        end
    end
end
OceanusSoul:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, OceanusSoul.PostPlayerUpdate, 0)

function OceanusSoul:PostUpdate()
    if PlayerManager.AnyoneHasCollectible(ty.CustomCollectibles.OCEANUSSOUL) then
        ty.SFXMANAGER:AdjustVolume(SoundEffect.SOUND_WATER_FLOW_LARGE, 0)
    end
end
OceanusSoul:AddCallback(ModCallbacks.MC_POST_UPDATE, OceanusSoul.PostUpdate)

function OceanusSoul:PreSFXPlay(id, volume, frameDelay, loop, pitch, pan)
	if id == SoundEffect.SOUND_FLUSH and stopFlushSound then
        stopFlushSound = false
        return false
    end
    if id == SoundEffect.SOUND_WATER_FLOW_LARGE and PlayerManager.AnyoneHasCollectible(ty.CustomCollectibles.OCEANUSSOUL) then
        return false
    end
end
OceanusSoul:AddCallback(ModCallbacks.MC_PRE_SFX_PLAY, OceanusSoul.PreSFXPlay)

function OceanusSoul:PostNewLevel()
    local globalData = ty.GLOBALDATA
    if globalData.OceanusSoul and PlayerManager.AnyoneHasCollectible(ty.CustomCollectibles.OCEANUSSOUL) then
        globalData.OceanusSoul.RoomList = {}
    end
end
OceanusSoul:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, OceanusSoul.PostNewLevel)

function OceanusSoul:PostNewRoom()
    local globalData = ty.GLOBALDATA
    if globalData.OceanusSoul and PlayerManager.AnyoneHasCollectible(ty.CustomCollectibles.OCEANUSSOUL) then
        globalData.OceanusSoul.Strength = 1 / 1000
    end
    if ty.LEVEL:HasAbandonedMineshaft() and ty.LEVEL:GetDimension() == Dimension.MINESHAFT then
        for _, player in pairs(PlayerManager.GetPlayers()) do
            if player:GetPlayerType() == PlayerType.PLAYER_AZAZEL or player:GetPlayerType() == PlayerType.PLAYER_AZAZEL_B then
                local weapon = Isaac.CreateWeapon(WeaponType.WEAPON_BRIMSTONE, player)
                player:SetWeapon(weapon, 1)
            else
                local weapon = Isaac.CreateWeapon(WeaponType.WEAPON_TEARS, player)
                player:SetWeapon(weapon, 1)
            end
        end
    end
end
OceanusSoul:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, OceanusSoul.PostNewRoom)

function OceanusSoul:PostAddCollectible(type, charge, firstTime, slot, varData, player)
	if type == ty.CustomCollectibles.OCEANUSSOUL then
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BIG_SPLASH, 0, player.Position, Vector(0, 0), nil).DepthOffset = 9999
        ty.GAME:ShakeScreen(15)
        ty.SFXMANAGER:Play(SoundEffect.SOUND_BOSS2INTRO_WATER_EXPLOSION)
        ty.SFXMANAGER:Play(SoundEffect.SOUND_BERSERK_END, 0.8, 2, false, 1.2, 0)
	end
end
OceanusSoul:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, OceanusSoul.PostAddCollectible)

function OceanusSoul:PostTriggerCollectibleRemoved(player, type)
    local room = ty.GAME:GetRoom()
    local count = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_SPIRIT_SWORD)
    for i = 1, count do
        player:RemoveCollectible(CollectibleType.COLLECTIBLE_SPIRIT_SWORD)
    end
    player:AddCollectible(CollectibleType.COLLECTIBLE_SPIRIT_SWORD)
    player:RemoveCollectible(CollectibleType.COLLECTIBLE_SPIRIT_SWORD)
    for i = 1, count do
        player:AddCollectible(CollectibleType.COLLECTIBLE_SPIRIT_SWORD)
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_C_SECTION) then
        player:SetWeapon(Isaac.CreateWeapon(WeaponType.WEAPON_FETUS, player), 1)
    end
    room:SetWaterCurrent(Vector(0, 0))
end
OceanusSoul:AddCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_REMOVED, OceanusSoul.PostTriggerCollectibleRemoved, ty.CustomCollectibles.OCEANUSSOUL)

function OceanusSoul:UpdateChargeBar(effect)
	local player = ty:GetLibData(effect).Owner
    local data = ty:GetLibData(player)
	local sprite = effect:GetSprite()
    if sprite:IsPlaying("Charging") then
        if player:ToPlayer() and player:IsHoldingItem() then
            sprite.PlaybackSpeed = 0
        else
            sprite.PlaybackSpeed = GetPlaybackSpeed(player)
        end
    end
	if sprite:IsFinished("Charging") then
		sprite:Play("Charged", true)
	end
	if sprite:IsFinished("Disappear") or not player:Exists() then
		effect:Remove()
	end
end
OceanusSoul:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, OceanusSoul.UpdateChargeBar, ty.CustomEffects.OCEANUSSOULCHARGEBAR)

function OceanusSoul:NPCUpdate(npc)
    local npc = npc:ToNPC()
    local room = ty.GAME:GetRoom()
    local current = room:GetWaterCurrent()
    if PlayerManager.AnyoneHasCollectible(ty.CustomCollectibles.OCEANUSSOUL) and (npc:IsActiveEnemy() and npc.Type ~= EntityType.ENTITY_FIREPLACE and not npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) and not npc:HasEntityFlags(EntityFlag.FLAG_CHARM)) or npc.Type == EntityType.ENTITY_MOVABLE_TNT then
        if burningEnemies[npc.Type] == true or burningEnemies[npc.Type] == npc.Variant then
            npc:TakeDamage(npc.MaxHitPoints / 3, DamageFlag.DAMAGE_IGNORE_ARMOR, EntityRef(Isaac.GetPlayer()), 0)
        end
        if IsInValidRoom(room) and not npc:IsFlying() then
            npc:AddVelocity(current)
        end
        if IsInValidRoom(room) and room:GetFrameCount() % 5 == 0 and current:Length() > 0.01 and (npc:CollidesWithGrid() or (npc:IsVulnerableEnemy() and (npc.Mass >= 100 or npc:HasEntityFlags(EntityFlag.FLAG_FREEZE) or npc:HasEntityFlags(EntityFlag.FLAG_MIDAS_FREEZE)))) then
            npc:TakeDamage(GetHighestDamageFromAllPlayers() * current:Length(), DamageFlag.DAMAGE_IGNORE_ARMOR, EntityRef(Isaac.GetPlayer()), 0)
        end
    end
end
OceanusSoul:AddCallback(ModCallbacks.MC_NPC_UPDATE, OceanusSoul.NPCUpdate)

return OceanusSoul