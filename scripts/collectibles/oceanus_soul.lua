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

local function GetLastDirection(player)
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_ANALOG_STICK) then
        local headDirection = player:GetHeadDirection()
        if headDirection == Direction.LEFT then
            return Vector(-1, 0)
        elseif headDirection == Direction.UP then
            return Vector(0, -1)
        elseif headDirection == Direction.RIGHT then
            return Vector(1, 0)
        else
            return Vector(0, 1)
        end
    end
    return player:GetLastDirection()
end

local function GetPlaybackSpeed(player)
    local playbackSpeed = 27.5 / (player.MaxFireDelay + 1)
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

local function GetDefaultLaserColor(player)
    local laserColor = player:GetLaserColor()
    local laserColorize = laserColor:GetColorize()
    local laserOffset = laserColor:GetOffset()
    if math.abs(laserColorize.R) + math.abs(laserColorize.G) + math.abs(laserColorize.B) + math.abs(laserOffset.R) + math.abs(laserOffset.G) + math.abs(laserOffset.B) == 0 then
        laserColor = Color(1, 1, 1, 1, 0.1, 0.1, 0.1, 4.5, 4.5, 6, 1)
    end
    return laserColor
end

local function SpawnLaser(player, index, percent)
    local laser = Isaac.Spawn(EntityType.ENTITY_EFFECT, ty.CustomEffects.OCEANUSSOULLASER, 0, player.Position, Vector(0, 0), player)
    local laserSprite = laser:GetSprite()
    local laserData = ty:GetLibData(laser)
    laserData.Owner = player
    laserData.Timeout = math.ceil(player.TearRange / 2)
    laserData.Delay = index * 4
    laserData.RotationAngle = 0
    laserData.TearFlags = 1 << -1
    laserData.Weapon = 1 << 1
    laserData.BombTimeout = -1
    laserData.IpecacTimeout = -1
    laserData.Percent = percent or 0.4
    if player:HasCollectible(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK) then
        laserData.ChocolateMilk = true
        local scale = (percent + 0.6) ^ 0.8
        laserSprite.Scale = Vector(scale, scale)
        ty.SFXMANAGER:Play(SoundEffect.SOUND_LASERRING_STRONG, 0.6, 2, false, 1 / scale, 0)
    else
        ty.SFXMANAGER:Play(SoundEffect.SOUND_LASERRING_STRONG, 0.6, 2, false, 0.7, 0)
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) then
        laserData.Weapon = laserData.Weapon | 1 << 2
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY) then
        laserData.Weapon = laserData.Weapon | 1 << 3
        laserSprite:Load("gfx/effects/oceanus_soul_tech_laser.anm2", true)
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_KNIFE) then
        laserData.Weapon = laserData.Weapon | 1 << 4
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_DR_FETUS) then
        laserData.BombTimeout = 30
        laserData.Weapon = laserData.Weapon | 1 << 5
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_X) then
        laserData.Weapon = laserData.Weapon | 1 << 9
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
    if player:HasCollectible(CollectibleType.COLLECTIBLE_SULFURIC_ACID) then
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
            local brimstone = player:FireDelayedBrimstone(i * 180, laser)
            brimstone:SetActiveRotation(0, 360, 360 / laserData.Timeout, true)
            brimstone:GetSprite().Color = GetDefaultLaserColor(player)
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
        for i = 0, 7 do
            local brimstone = player:FireDelayedBrimstone(i * 45, laser)
            brimstone:SetActiveRotation(0, 360, 360 / laserData.Timeout, true)
            brimstone:GetSprite().Color = GetDefaultLaserColor(player)
        end
    end
    laser:GetSprite().Color = GetDefaultLaserColor(player)
    laserSprite:Play("Start", true)
end

local function SpawnLasers(player, percent)
    local num = player:GetMultiShotParams(WeaponType.WEAPON_TEARS):GetNumTears() + player:GetCollectibleNum(CollectibleType.COLLECTIBLE_MONSTROS_LUNG) * 3
    local rng = player:GetCollectibleRNG(ty.CustomCollectibles.OCEANUSSOUL)
    if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_EYE) and rng:RandomInt(100) < 50 + 10 * player.Luck then
        num = num + 1
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_LOKIS_HORNS) and rng:RandomInt(100) < 25 + 5 * player.Luck then
        num = num + 3
    end
    for i = 0, num - 1 do
        SpawnLaser(player, i, percent)
    end
end

local function GetNearestEnemyInOrder(position)
	local distance = 8192
    local nearestEnemy = nil
    for _, ent in pairs(Isaac.FindInRadius(position, 8192, EntityPartition.ENEMY)) do
        if ty:IsValidCollider(ent) and ent:IsFlying() and (ent.Position - position):Length() < distance then
            distance = (ent.Position - position):Length()
            nearestEnemy = ent
        end
    end
    if nearestEnemy then
        return nearestEnemy
    end
    for _, ent in pairs(Isaac.FindInRadius(position, 8192, EntityPartition.ENEMY)) do
        if ty:IsValidCollider(ent) and not ent:IsFlying() and (ent.Position - position):Length() < distance then
            distance = (ent.Position - position):Length()
            nearestEnemy = ent
        end
    end
    return nearestEnemy
end

local function SetPlayerWeapon(player)
    local mainWeapon = player:GetWeapon(1)
    if mainWeapon then
        if mainWeapon:GetWeaponType() ~= WeaponType.WEAPON_BONE and mainWeapon:GetWeaponType() ~= WeaponType.WEAPON_NOTCHED_AXE and mainWeapon:GetWeaponType() ~= WeaponType.WEAPON_URN_OF_SOULS and mainWeapon:GetWeaponType() ~= WeaponType.WEAPON_UMBILICAL_WHIP then
            Isaac.DestroyWeapon(mainWeapon)
        end
    end
end

local function DoFlushEnemies(player)
    local room = ty.GAME:GetRoom()
    for _, ent in pairs(Isaac.FindInRadius(Vector(0, 0), 8192, EntityPartition.ENEMY)) do
        if ent:IsVulnerableEnemy() then
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
    if player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_X) then
        tears = tears * 0.5
    end
    return tears * 0.6
end

function OceanusSoul:UpdateLaser(effect)
    local room = ty.GAME:GetRoom()
    local sprite = effect:GetSprite()
    local data = ty:GetLibData(effect)
    local player = data.Owner
    local rng = player:GetCollectibleRNG(ty.CustomCollectibles.OCEANUSSOUL)
    if sprite:IsFinished("Start") then
        sprite:Play("Loop", true)
    end
    if sprite:IsPlaying("Loop") then
        data.RotationAngle = data.RotationAngle + math.pi / 60
        if data.TearFlags & TearFlags.TEAR_ORBIT == TearFlags.TEAR_ORBIT then
            data.RotationAngle = data.RotationAngle + math.pi / 10
        end
        if data.RotationAngle > 2 * math.pi then
            data.RotationAngle = data.RotationAngle - 2 * math.pi
        end
        if data.Timeout > 0 then
            local enemy = nil
            if data.TearFlags & TearFlags.TEAR_BOOMERANG == TearFlags.TEAR_BOOMERANG then
                enemy = GetNearestEnemyInOrder(player.Position) or player
            else
                enemy = GetNearestEnemyInOrder(effect.Position) or player
            end
            if data.TearFlags & TearFlags.TEAR_BOUNCE == TearFlags.TEAR_BOUNCE then
                if (not room:IsPositionInRoom(effect.Position + Vector(0, 8), 0) and room:IsPositionInRoom(effect.Position + Vector(0, -8), 0)) or (not room:IsPositionInRoom(effect.Position + Vector(0, -8), 0) and room:IsPositionInRoom(effect.Position + Vector(0, 8), 0)) then
                    effect.Velocity = Vector(effect.Velocity.X, -effect.Velocity.Y)
                end
                if (not room:IsPositionInRoom(effect.Position + Vector(8, 0), 0) and room:IsPositionInRoom(effect.Position + Vector(-8, 0), 0)) or (not room:IsPositionInRoom(effect.Position + Vector(-8, 0), 0) and room:IsPositionInRoom(effect.Position + Vector(8, 0), 0)) then
                    effect.Velocity = Vector(-effect.Velocity.X, effect.Velocity.Y)
                end
            end
            if data.Delay == 0 then
                if effect.Velocity:Length() < player.ShotSpeed * 6 then
                    local targetPosition = enemy.Position
                    if data.TearFlags & TearFlags.TEAR_HOMING ~= TearFlags.TEAR_HOMING then
                        targetPosition = targetPosition + Vector(math.sin(data.RotationAngle), math.cos(data.RotationAngle)) * enemy.Size * 0.75
                    end
                    effect:AddVelocity((targetPosition - effect.Position):Normalized():Resized(player.ShotSpeed / 1.35))
                else
                    effect:AddVelocity(-effect.Velocity:Resized(0.85))
                end
            else
                data.Delay = data.Delay - 1
            end
            if effect.FrameCount % 5 == 0 and data.TearFlags & TearFlags.TEAR_MYSTERIOUS_LIQUID_CREEP == TearFlags.TEAR_MYSTERIOUS_LIQUID_CREEP then
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_GREEN, 0, effect.Position, Vector(0, 0), player)
            end
            if effect.FrameCount % 3 == 0 and data.Aquarius then
                local creep = player:SpawnAquariusCreep()
                creep.Position = effect.Position
            end
            if data.TearFlags & TearFlags.TEAR_ACID == TearFlags.TEAR_ACID then
                room:DestroyGrid(room:GetGridIndex(effect.Position))
            end
            for _, ent in pairs(Isaac.FindInRadius(effect.Position, 16 * sprite.Scale.X, EntityPartition.ENEMY)) do
                if ty:IsValidCollider(ent) then
                    if ent.FrameCount % 3 == 0 then
                        local damage = player.Damage * sprite.Scale.X
                        if data.Weapon & 1 << 3 == 1 << 3 then
                            damage = damage * 1.5
                        end
                        if data.ChocolateMilk then
                            damage = damage * (data.Percent + 0.6) ^ 2
                        end
                        if player:HasCollectible(CollectibleType.COLLECTIBLE_APPLE) and rng:RandomFloat() < 1 / math.max(1, 15 - math.floor(player.Luck)) then
                            damage = damage * 4
                        elseif player:HasCollectible(CollectibleType.COLLECTIBLE_TOUGH_LOVE) and rng:RandomFloat() < 1 / math.max(1, 10 - math.floor(player.Luck)) then
                            damage = damage * 3.2
                        end
                        ent:TakeDamage(damage, 0, EntityRef(ent), 0)
                        if player:HasCollectible(CollectibleType.COLLECTIBLE_HEAD_OF_THE_KEEPER) and rng:RandomInt(100) < 5 then
                            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY, ent.Position, Vector(0, 0), nil)
                        end
                    end
                    if data.Weapon & 1 << 5 == 1 << 5 then
                        if data.BombTimeout == 0 then
                            local bomb = player:FireBomb(effect.Position, Vector(0, 0), player)
                            bomb:SetExplosionCountdown(bomb:GetExplosionCountdown() // 2)
                            data.BombTimeout = 90
                        else
                            data.BombTimeout = data.BombTimeout - 1
                        end
                    end
                    if data.TearFlags & TearFlags.TEAR_EXPLOSIVE == TearFlags.TEAR_EXPLOSIVE then
                        if data.IpecacTimeout == 0 then
                            local bomb = player:FireBomb(effect.Position, Vector(0, 0), player)
                            bomb:SetExplosionCountdown(0)
                            bomb.Visible = false
                            bomb:AddTearFlags(TearFlags.TEAR_POISON)
                            data.IpecacTimeout = 30
                        else
                            data.IpecacTimeout = data.IpecacTimeout - 1
                        end
                    end
                    if data.TearFlags & TearFlags.TEAR_POISON == TearFlags.TEAR_POISON and ent:GetPoisonCountdown() == 0 then
                        ent:AddPoison(EntityRef(player), 30, player.Damage)
                        ent:SetPoisonCountdown(60)
                    end
                    if data.TearFlags & TearFlags.TEAR_ICE == TearFlags.TEAR_ICE and ent:GetIceCountdown() == 0 then
                        ent:AddIce(EntityRef(player), 30)
                        ent:SetIceCountdown(60)
                    end
                    if data.TearFlags & TearFlags.TEAR_BURN == TearFlags.TEAR_BURN and ent:GetBurnCountdown() == 0 then
                        ent:AddBurn(EntityRef(player), 30, player.Damage)
                        ent:SetBurnCountdown(60)
                    end
                    if data.TearFlags & TearFlags.TEAR_SLOW == TearFlags.TEAR_SLOW and ent:GetSlowingCountdown() == 0 then
                        ent:AddSlowing(EntityRef(player), 30, 0.8, Color(1, 1, 1.3, 1, 0.156863, 0.156863, 0.156863))
                        ent:SetSlowingCountdown(60)
                    end
                    if data.TearFlags & TearFlags.TEAR_MAGNETIZE == TearFlags.TEAR_MAGNETIZE and ent:GetMagnetizedCountdown() == 0 then
                        ent:AddMagnetized(EntityRef(player), 30)
                        ent:SetMagnetizedCountdown(60)
                    end
                    if data.TearFlags & TearFlags.TEAR_BAIT == TearFlags.TEAR_BAIT and ent:GetBaitedCountdown() == 0 then
                        ent:AddBaited(EntityRef(player), 30)
                        ent:SetBaitedCountdown(60)
                    end
                    if data.TearFlags & TearFlags.TEAR_CHARM == TearFlags.TEAR_CHARM and ent:GetCharmedCountdown() == 0 then
                        ent:AddCharmed(EntityRef(player), 30)
                        ent:SetCharmedCountdown(60)
                    end
                    if data.TearFlags & TearFlags.TEAR_GODS_FLESH == TearFlags.TEAR_GODS_FLESH and ent:GetShrinkCountdown() == 0 then
                        ent:AddShrink(EntityRef(player), 30)
                        ent:SetShrinkCountdown(60)
                    end
                    if data.TearFlags & TearFlags.TEAR_FEAR == TearFlags.TEAR_FEAR and ent:GetFearCountdown() == 0 then
                        ent:AddFear(EntityRef(player), 30)
                        ent:SetFearCountdown(60)
                    end
                    if data.TearFlags & TearFlags.TEAR_FREEZE == TearFlags.TEAR_FREEZE and ent:GetFreezeCountdown() == 0 then
                        ent:AddFreeze(EntityRef(player), 30)
                        ent:SetFreezeCountdown(60)
                    end
                    if data.TearFlags & TearFlags.TEAR_CONFUSION == TearFlags.TEAR_CONFUSION and ent:GetConfusionCountdown() == 0 then
                        ent:AddConfusion(EntityRef(player), 30)
                        ent:SetConfusionCountdown(60)
                    end
                    if data.TearFlags & TearFlags.TEAR_BACKSTAB == TearFlags.TEAR_BACKSTAB and ent:GetBleedingCountdown() == 0 then
                        ent:AddBleeding(EntityRef(player), 30)
                        ent:SetBleedingCountdown(60)
                    end
                    if data.TearFlags & TearFlags.TEAR_KNOCKBACK == TearFlags.TEAR_KNOCKBACK and ent:GetKnockbackCountdown() == 0 then
                        ent:AddKnockback(EntityRef(player), -effect.Velocity:Normalized(), 15, true)
                        ent:SetKnockbackCountdown(60)
                    end
                end
            end
            for _, ent in pairs(Isaac.FindByType(EntityType.ENTITY_KNIFE, KnifeVariant.MOMS_KNIFE, 0)) do
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
            if effect.FrameCount % 15 == 0 then
                if player:HasCollectible(CollectibleType.COLLECTIBLE_HOLY_LIGHT) and rng:RandomFloat() < 1 / math.max(2, 10 - math.floor(0.9 * player.Luck)) then
                    local tear = player:FireTear(effect.Position, Vector(0, 0), true, true, false, player, 1)
                    tear:ChangeVariant(TearVariant.GRIDENT)
                    tear.TearFlags = TearFlags.TEAR_LIGHT_FROM_HEAVEN
                end
                if data.TearFlags & TearFlags.TEAR_SPLIT == TearFlags.TEAR_SPLIT then
                    local tear = player:FireTear(effect.Position, Vector(0, 0), true, true, false, player, 1)
                    tear.TearFlags = TearFlags.TEAR_SPLIT
                end
                if data.TearFlags & TearFlags.TEAR_QUADSPLIT == TearFlags.TEAR_QUADSPLIT then
                    local tear = player:FireTear(effect.Position, Vector(0, 0), true, true, false, player, 0.5)
                    tear.TearFlags = TearFlags.TEAR_QUADSPLIT
                end
                if data.TearFlags & TearFlags.TEAR_MULLIGAN == TearFlags.TEAR_MULLIGAN and rng:RandomInt(100) < 17 then
                    local tear = player:FireTear(effect.Position, Vector(0, 0), true, true, false, player, 1)
                    tear:ChangeVariant(TearVariant.GRIDENT)
                    tear.TearFlags = TearFlags.TEAR_MULLIGAN
                end
                if data.TearFlags & TearFlags.TEAR_STICKY == TearFlags.TEAR_STICKY and rng:RandomInt(100) < 25 then
                    local tear = player:FireTear(effect.Position, Vector(0, 0), true, true, false, player, 1)
                    tear:ChangeVariant(TearVariant.EXPLOSIVO)
                    tear.TearFlags = TearFlags.TEAR_STICKY
                end
                if data.TearFlags & TearFlags.TEAR_EGG == TearFlags.TEAR_EGG and rng:RandomFloat() < 1 / math.max(2, 7 - math.floor(player.Luck)) then
                    local tear = player:FireTear(effect.Position, Vector(0, 0), true, true, false, player, 1)
                    tear:ChangeVariant(TearVariant.EGG)
                    tear.TearFlags = TearFlags.TEAR_EGG
                end
                if data.TearFlags & TearFlags.TEAR_BOOGER == TearFlags.TEAR_BOOGER and rng:RandomInt(100) < 20 then
                    local tear = player:FireTear(effect.Position, Vector(0, 0), true, true, false, player, 1)
                    tear:ChangeVariant(TearVariant.BOOGER)
                    tear.TearFlags = TearFlags.TEAR_BOOGER
                end
                if data.GhostPepper and rng:RandomFloat() < 1 / math.max(2, 12 - math.floor(player.Luck)) then
                    local fire = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLUE_FLAME, 0, effect.Position, Vector(0, 0), player):ToEffect()
                    fire:SetTimeout(60)
                    fire.CollisionDamage = player.Damage * 6
                end
                if data.TearFlags & TearFlags.TEAR_NEEDLE == TearFlags.TEAR_NEEDLE and rng:RandomFloat() < 1 / math.max(4, 30 - math.floor(2 * player.Luck)) then
                    local tear = player:FireTear(effect.Position, Vector(0, 0), true, true, false, player, 1)
                    tear:ChangeVariant(TearVariant.NEEDLE)
                    tear.TearFlags = TearFlags.TEAR_NEEDLE
                end
                if data.TearFlags & TearFlags.TEAR_HORN == TearFlags.TEAR_HORN and rng:RandomFloat() < 1 / math.max(5, 20 - math.floor(player.Luck)) then
                    local tear = player:FireTear(effect.Position, Vector(0, 0), true, true, false, player, 1)
                    tear:ChangeVariant(TearVariant.GRIDENT)
                    tear.TearFlags = TearFlags.TEAR_HORN
                end
                if data.TearFlags & TearFlags.TEAR_SPORE == TearFlags.TEAR_SPORE and rng:RandomInt(100) < 25 then
                    local tear = player:FireTear(effect.Position, Vector(0, 0), true, true, false, player, 1)
                    tear:ChangeVariant(TearVariant.SPORE)
                    tear.TearFlags = TearFlags.TEAR_SPORE
                end
                if data.BirdsEye and rng:RandomFloat() < 1 / math.max(2, 12 - math.floor(player.Luck)) then
                    local fire = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.RED_CANDLE_FLAME, 0, effect.Position, Vector(0, 0), player):ToEffect()
                    fire:SetTimeout(300)
                    fire.CollisionDamage = player.Damage * 4
                end
                if data.TearFlags & TearFlags.TEAR_JACOBS == TearFlags.TEAR_JACOBS then
                    local tear = player:FireTear(effect.Position, Vector(0, 0), true, true, false, player, 1)
                    tear:ChangeVariant(TearVariant.GRIDENT)
                    tear.TearFlags = TearFlags.TEAR_JACOBS
                end
            end
            if data.TearFlags & TearFlags.TEAR_GROW == TearFlags.TEAR_GROW then
                sprite.Scale = Vector(1, 1) + Vector(0.05, 0.05) * effect.FrameCount / 30
            end
            if data.TearFlags & TearFlags.TEAR_SHRINK == TearFlags.TEAR_SHRINK then
                sprite.Scale = Vector(1.5, 1.5) - Vector(0.1, 0.1) * effect.FrameCount / 30
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

function OceanusSoul:PostPlayerUpdate(player)
    local room = ty.GAME:GetRoom()
    local data = ty:GetLibData(player)
    local globalData = ty.GLOBALDATA
    if data.Init and player:HasCollectible(ty.CustomCollectibles.OCEANUSSOUL) then
        if room:GetType() ~= RoomType.ROOM_DUNGEON and not ty:IsValueInTable(ty.LEVEL:GetCurrentRoomIndex(), bannedGridRooms) then
            if ty:IsPlayerFiring(player) or (player:HasCollectible(CollectibleType.COLLECTIBLE_MARKED) and not room:IsClear()) then
                globalData.OceanusSoul.Strength = math.min(1, globalData.OceanusSoul.Strength + 1 / 200)
                if not HasChargeBar(player) then
                    SpawnChargeBar(player)
                end
            else
                globalData.OceanusSoul.Strength = math.max(1 / 1000, globalData.OceanusSoul.Strength - 1 / 100)
                if HasChargeBar(player) then
                    if player:HasCollectible(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK) then
                        local percent = GetChargeBarPercent(player)
                        if percent >= 0.1 then
                            SpawnLasers(player, percent)
                        end
                    end
                    DisappearChargeBar(player)
                end
            end
            if room:GetWaterAmount() < 1 then
                room:SetWaterAmount(1) 
            end
            if globalData.OceanusSoul.Strength == 0 then
                room:SetWaterCurrent(Vector(0, 0))
            else
                room:SetWaterCurrent(GetLastDirection(player):Normalized():Resized(globalData.OceanusSoul.Strength ^ 2)) 
            end
            if room:GetFrameCount() >= 1 and not ty:IsValueInTable(ty.LEVEL:GetCurrentRoomDesc().ListIndex, globalData.OceanusSoul.RoomList) then
                DoFlushEnemies(player)
                table.insert(globalData.OceanusSoul.RoomList, ty.LEVEL:GetCurrentRoomDesc().ListIndex)
            end
        else
            if HasChargeBar(player) then
                DisappearChargeBar(player)
            end
        end
        SetPlayerWeapon(player)
    end
end
OceanusSoul:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, OceanusSoul.PostPlayerUpdate)

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
    if PlayerManager.AnyoneHasCollectible(ty.CustomCollectibles.OCEANUSSOUL) then
        globalData.OceanusSoul.RoomList = {}
    end
end
OceanusSoul:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, OceanusSoul.PostNewLevel)

function OceanusSoul:PostNewRoom()
    local globalData = ty.GLOBALDATA
    if PlayerManager.AnyoneHasCollectible(ty.CustomCollectibles.OCEANUSSOUL) then
        globalData.OceanusSoul.Strength = 1 / 1000
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

function OceanusSoul:UpdateChargeBar(effect)
	local player = ty:GetLibData(effect).Owner
    local data = ty:GetLibData(player)
	local sprite = effect:GetSprite()
    if sprite:IsPlaying("Charging") then
        if player:IsHoldingItem() then
            sprite.PlaybackSpeed = 0
        else
            sprite.PlaybackSpeed = GetPlaybackSpeed(player)
        end
    end
	if sprite:IsFinished("Charging") then
		sprite:Play("Charging", true)
        SpawnLasers(player, 1)
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
    if PlayerManager.AnyoneHasCollectible(ty.CustomCollectibles.OCEANUSSOUL) and ty:IsValidCollider(npc) and not npc:IsFlying() then
        npc:AddVelocity(current)
        if burningEnemies[npc.Type] == true or burningEnemies[npc.Type] == npc.Variant then
            npc:TakeDamage(npc.MaxHitPoints / 3, 0, EntityRef(nil), 0)
        end
        if current:Length() > 0.01 and (npc:CollidesWithGrid() or npc.Mass == 100 or npc:HasEntityFlags(EntityFlag.FLAG_FREEZE) or npc:HasEntityFlags(EntityFlag.FLAG_MIDAS_FREEZE)) and room:GetFrameCount() % 10 == 0 then
            npc:TakeDamage(GetHighestDamageFromAllPlayers() * current:Length() * 2, 0, EntityRef(nil), 0)
        end
    end
end
OceanusSoul:AddCallback(ModCallbacks.MC_NPC_UPDATE, OceanusSoul.NPCUpdate)

return OceanusSoul