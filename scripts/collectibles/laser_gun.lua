local LaserGun = ty:DefineANewClass()

local function GetRotationAngle(player)
    local direction = player:GetShootingInput()
    if direction.X == 0 and direction.Y == 0 then
        return math.pi * 0.5
    elseif direction.X == 0 and direction.Y == -1 then
        return math.pi * 1.5
    elseif direction.X == 1 and direction.Y == -1 then
        return math.pi * 1.75
    elseif direction.X == 1 and direction.Y == 0 then
        return 0
    elseif direction.X == 1 and direction.Y == 1 then
        return math.pi * 0.25
    elseif direction.X == 0 and direction.Y == 1 then
        return math.pi * 0.5
    elseif direction.X == -1 and direction.Y == 1 then
        return math.pi * 0.75
    elseif direction.X == -1 and direction.Y == 0 then
        return math.pi
    elseif direction.X == -1 and direction.Y == -1 then
        return math.pi * 1.25
    end
end

local function SetColor(sprite, laser)
    local laserColor = laser.Color:GetColorize()
    if math.abs(laserColor.R) + math.abs(laserColor.G) + math.abs(laserColor.B) > 0 then
        sprite.Color = Color(laserColor.R / 3, laserColor.G / 3, laserColor.B / 3, 1)
    end
end

local function SpawnPlasmaBall(player, direction, delay)
    ty.SFXMANAGER:Play(SoundEffect.SOUND_BLOOD_LASER_LARGER, 0.6, 0, false, 1.1)
    local plasmaBall = Isaac.Spawn(EntityType.ENTITY_EFFECT, ty.CustomEffects.LASERSWIRL, 0, player.Position, Vector(0, 0), player):ToEffect()
    local ballData = ty:GetLibData(plasmaBall, true)
    local sprite = plasmaBall:GetSprite()
    local laser = player:FireTechXLaser(plasmaBall.Position, Vector(0, 0), 0, player, 1)
    laser.Parent = plasmaBall
    laser.ParentOffset = Vector(0, 24)
    laser.SubType = LaserSubType.LASER_SUBTYPE_RING_FOLLOW_PARENT
    laser:SetTimeout(0)
    laser:Update()
    ballData.Owner = player
    ballData.Remove = false
    ballData.Laser = laser
    ballData.MaxVelocity = direction:Normalized():Resized(math.sqrt(player.ShotSpeed * 4))
    ballData.Acceleration = ballData.MaxVelocity:Resized(0.02)
    ballData.DamageScale = 0.04
    ballData.RotationSpeed = 0
    ballData.RotationAngle = 0
    ballData.Time = 0
    ballData.Cooldown = 0
    ballData.MaxCooldown = 100
    ballData.MovingCooldown = delay or 0
    ballData.Type = 1 << -1
    sprite.Color = Color(1, 0, 0, 1)
    sprite.Scale = Vector(0.8, 0.8)
    if player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY_2) then
        ballData.Type = ballData.Type | 1 << 0
        ballData.MaxCooldown = ballData.MaxCooldown * 0.7
        ballData.DamageScale = ballData.DamageScale - 0.01
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY) then
        ballData.Type = ballData.Type | 1 << 0
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_SPOON_BENDER) or player:HasCollectible(CollectibleType.COLLECTIBLE_GODHEAD) or player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_TELEPATHY_BOOK) then
        ballData.Type = ballData.Type | 1 << 1
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_MY_REFLECTION) then
        ballData.Type = ballData.Type | 1 << 2
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK) then
        ballData.Type = ballData.Type | 1 << 3
        ballData.MaxCooldown = ballData.MaxCooldown * 2
        ballData.DamageScale = ballData.DamageScale + 0.01
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_KNIFE) then
        ballData.Type = ballData.Type | 1 << 4
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) then
        ballData.Type = ballData.Type | 1 << 5
        ballData.MaxCooldown = ballData.MaxCooldown * 3
        ballData.DamageScale = ballData.DamageScale - 0.01
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_LUMP_OF_COAL) then
        ballData.Type = ballData.Type | 1 << 6
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_IPECAC) then
        ballData.MaxCooldown = ballData.MaxCooldown * 3
        ballData.DamageScale = ballData.DamageScale - 0.01
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_POLYPHEMUS) then
        ballData.Type = ballData.Type | 1 << 7
        ballData.MaxCooldown = ballData.MaxCooldown * 2.5
        ballData.DamageScale = ballData.DamageScale - 0.01
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_SACRED_HEART) then
        ballData.MaxCooldown = ballData.MaxCooldown * 1.5
        ballData.DamageScale = ballData.DamageScale - 0.01
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_RUBBER_CEMENT) then
        ballData.Type = ballData.Type | 1 << 8
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_ANTI_GRAVITY) then
        ballData.MovingCooldown = 60
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_TINY_PLANET) then
        ballData.Type = ballData.Type | 1 << 9
        ballData.RotationSpeed = math.pi / 90
        ballData.RotationAngle = GetRotationAngle(player)
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_5) then
        ballData.DamageScale = ballData.DamageScale + 0.005
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_PROPTOSIS) then
        ballData.Type = ballData.Type | 1 << 10
        ballData.DamageScale = ballData.DamageScale - 0.02
        sprite.Scale = Vector(1.6, 1.6)
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_STRANGE_ATTRACTOR) then
        plasmaBall:AddEntityFlags(EntityFlag.FLAG_MAGNETIZED)
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE) or player:HasCollectible(CollectibleType.COLLECTIBLE_EYE_OF_THE_OCCULT) then
        ballData.Type = ballData.Type | 1 << 11
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_SOY_MILK) or player:HasCollectible(CollectibleType.COLLECTIBLE_ALMOND_MILK) then
        ballData.MaxCooldown = ballData.MaxCooldown * 0.1
        ballData.DamageScale = ballData.DamageScale - 0.02
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_CONTINUUM) then
        ballData.Type = ballData.Type | 1 << 12
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_X) then
        ballData.Type = ballData.Type | 1 << 13
        laser.Radius = laser.Radius + 32
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_JACOBS_LADDER) then
        ballData.Type = ballData.Type | 1 << 13
        laser.Radius = laser.Radius + 16
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_PLAYDOUGH_COOKIE) then
        ballData.Type = ballData.Type | 1 << 14
    end
    SetColor(sprite, laser)
    ballData.DamageScale = math.max(0.005, ballData.DamageScale)
    ballData.MaxCooldown = math.ceil(math.sqrt(ballData.MaxCooldown))
end

local function DoAttack(effect, player)
    local entityList = {}
    local scaleX = effect:GetSprite().Scale.X
    for _, entity in pairs(Isaac.FindInRadius(effect.Position, ty.ConstantValues.LASERGUNPLASMABALLRANGE * scaleX, EntityPartition.ENEMY)) do
        if ty:IsValidCollider(entity) then
            local entityData = ty:GetLibData(entity, true)
            if entityData.PlasmaDamageScale == nil then
                entityData.PlasmaDamageScale = 1
            end
            table.insert(entityList, entity)
        end
    end
    for i = 1, #entityList do
        local entityData = ty:GetLibData(entityList[i], true)
        local effectData = ty:GetLibData(effect, true)
        local entityPosition = entityList[i].Position
        local damageScale = entityData.PlasmaDamageScale or 1
        if effectData.Type & 1 << 3 == 1 << 3 then
            damageScale = damageScale * 2
        end
        if effectData.Type & 1 << 10 == 1 << 10 then
            damageScale = damageScale * math.sqrt(scaleX)
        end
        if effectData.Type & 1 << 5 == 1 << 5 then
            local laser = Isaac.Spawn(EntityType.ENTITY_LASER, LaserVariant.BRIM_TECH, LaserSubType.LASER_SUBTYPE_LINEAR, effect.Position, effect.Velocity, player):ToLaser()
            laser.Color = ty:GetLaserColor(player)
            laser.AngleDegrees = (entityList[i].Position - effect.Position):GetAngleDegrees()
            laser.Timeout = 9
            laser.CollisionDamage = player.Damage * 1.5 * damageScale
            laser.Parent = effect
            laser.TearFlags = laser.TearFlags | player.TearFlags | TearFlags.TEAR_SPECTRAL
        else
            local laser = player:FireTechLaser(effect.Position + Vector(0, 16), LaserOffset.LASER_TRACTOR_BEAM_OFFSET,entityPosition - effect.Position - Vector(0, 16), false, true, player, damageScale)
            laser.TearFlags = laser.TearFlags | player.TearFlags | TearFlags.TEAR_SPECTRAL
            if effectData.Type & 1 << 0 ~= 1 << 0 then
                laser:SetMaxDistance((effect.Position - entityPosition):Length() * 1.2)
            end
        end
        if effectData.Type & 1 << 4 == 1 << 4 then
            local knife = player:FireKnife(effect, (entityPosition - effect.Position):GetAngleDegrees(), false)
            local knifeData = ty:GetLibData(knife, true)
            knife:Shoot(1, 1000)
            knife.CollisionDamage = player.Damage / 3
            knifeData.RemoveOnReturn = true
        end
        if entityData.PlasmaDamageScale < 10 then
            entityData.PlasmaDamageScale = entityData.PlasmaDamageScale * (1 + effectData.DamageScale)
        else
            entityData.PlasmaDamageScale = 10
        end
    end
end

local function RemoveChargeLaserGun(player)
    local activeSlot = player:GetActiveItemSlot(ty.CustomCollectibles.LASERGUN)
    local maxCharge = ty.ITEMCONFIG:GetCollectible(ty.CustomCollectibles.LASERGUN).MaxCharges
    local mainCharge = player:GetActiveCharge(activeSlot)
    local subCharge = player:GetBatteryCharge(activeSlot)
    if mainCharge + subCharge >= maxCharge then
        player:SetActiveCharge(mainCharge + subCharge - maxCharge, activeSlot)
    elseif mainCharge < maxCharge then
        if player:GetPlayerType() == PlayerType.PLAYER_BETHANY then
            player:SetSoulCharge(math.max(player:GetSoulCharge() - 1, 0))
        elseif player:GetPlayerType() == PlayerType.PLAYER_BETHANY_B then
            player:SetBloodCharge(math.max(player:GetBloodCharge() - 1, 0))
        end
        player:SetActiveCharge(0, activeSlot)
    end
end

function LaserGun:UseItem(itemID, rng, player, useFlags, activeSlot, varData)
    local data = ty:GetLibData(player)
    if useFlags & UseFlag.USE_CARBATTERY == UseFlag.USE_CARBATTERY or useFlags & UseFlag.USE_OWNED ~= UseFlag.USE_OWNED then
        return { Discharge = false, Remove = false, ShowAnim = false }
    end
    if useFlags & UseFlag.USE_VOID == UseFlag.USE_VOID then
        SpawnPlasmaBall(player, player:GetRecentMovementVector())
        return { Discharge = false, Remove = false, ShowAnim = false }
    end
    if not data.Laser.IsHolding then
        player:AnimateCollectible(ty.CustomCollectibles.LASERGUN, "LiftItem")
        data.Laser.IsHolding = true
    else
        player:AnimateCollectible(ty.CustomCollectibles.LASERGUN, "HideItem")
        data.Laser.IsHolding = false
    end
    return { Discharge = false, Remove = false, ShowAnim = false }
end
LaserGun:AddCallback(ModCallbacks.MC_USE_ITEM, LaserGun.UseItem, ty.CustomCollectibles.LASERGUN)

function LaserGun:PostPlayerUpdate(player)
    local data = ty:GetLibData(player)
    if player:HasCollectible(ty.CustomCollectibles.LASERGUN) and data.Laser.IsHolding then
        local direction = player:GetShootingInput()
        if not (direction.X == 0 and direction.Y == 0) then
            SpawnPlasmaBall(player, direction)
            if player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) then
                SpawnPlasmaBall(player, direction, 30)
            end
            RemoveChargeLaserGun(player)
            player:AnimateCollectible(ty.CustomCollectibles.LASERGUN, "HideItem")
            data.Laser.IsHolding = false
        end
        if not player:IsHoldingItem() then
            player:AnimateCollectible(ty.CustomCollectibles.LASERGUN, "HideItem")
            data.Laser.IsHolding = false
        end
    end
end
LaserGun:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, LaserGun.PostPlayerUpdate)

function LaserGun:UpdateLaserSwirlEffect(effect)
    local sprite = effect:GetSprite()
    local room = ty.GAME:GetRoom()
    local effectData = ty:GetLibData(effect, true)
    local player = effectData.Owner
    if sprite:IsFinished("BeginLoop") then
        sprite:Play("Loop", true)
    end
    if sprite:IsPlaying("Loop") then
        if effectData.Cooldown == 0 then
            DoAttack(effect, player)
            effectData.Cooldown = effectData.MaxCooldown
        else
            effectData.Cooldown = effectData.Cooldown - 1
        end
        effectData.Time = effectData.Time + 1
    end
    if ((effectData.Type & 1 << 12 ~= 1 << 12 and not room:IsPositionInRoom(effect.Position, 0)) or effectData.Time >= 600 or sprite.Scale:Length() < math.sqrt(2) * 0.1) and not effectData.Remove then
        ty.SFXMANAGER:Play(SoundEffect.SOUND_BLOOD_LASER_LARGER, 0.6, 0, false, 0.7)
        sprite:Play("EndLoop", true)
        effectData.Remove = true
    end
    if effectData.Remove then
        if sprite:IsFinished("EndLoop") then
            effect:Remove()
        end
        effect.Velocity = Vector(0, 0)
    else
        if effectData.MovingCooldown > 0 then
            effectData.MovingCooldown = effectData.MovingCooldown - 1
        else
            if effectData.Type & 1 << 1 == 1 << 1 then
                local target = ty:GetNearestEnemy(effect.Position)
                if target then
                    effect:AddVelocity((target.Position - effect.Position):Resized(0.02))
                end
            elseif effectData.Type & 1 << 2 == 1 << 2 then
                effect:AddVelocity((player.Position - effect.Position):Resized(0.02))
            elseif effectData.Type & 1 << 11 == 1 << 11 then
                local shootingInput = player:GetShootingInput()
                if not (shootingInput.X == 0 and shootingInput.Y == 0) then
                    effect.Velocity = shootingInput:Resized(6)
                else
                    effect.Velocity = effect.Velocity:Resized(0.99)
                    if effect.Velocity:Length() < 1 then
                        effect.Velocity = Vector(0, 0)
                    end
                end 
            end
            if effectData.Type & 1 << 12 == 1 << 12 then
                local roomSize = room:GetGridSize()
                local roomWidth = room:GetGridWidth()
                if room:GetGridIndex(effect.Position) == -1 and not effectData.Continuum then
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
                    effectData.Continuum = true
                elseif room:GetGridIndex(effect.Position) ~= -1 and effectData.Continuum then
                    effectData.Continuum = false
                end
                if (effect.Position.X < -40 or effect.Position.X > room:GetGridPosition(roomSize - 1).X + 40 or effect.Position.Y < -40 or effect.Position.Y > room:GetGridPosition(roomSize - 1).Y + 40) and not effectData.Remove then
                    ty.SFXMANAGER:Play(SoundEffect.SOUND_BLOOD_LASER_LARGER, 0.6, 0, false, 0.7)
                    sprite:Play("EndLoop", true)            
                    effectData.Remove = true
                end
            end
            if effectData.Type & 1 << 11 ~= 1 << 11 then
                if effectData.Type & 1 << 8 == 1 << 8 then
                    if (not room:IsPositionInRoom(effect.Position + Vector(0, 8), 0) and room:IsPositionInRoom(effect.Position + Vector(0, -8), 0)) or (not room:IsPositionInRoom(effect.Position + Vector(0, -8), 0) and room:IsPositionInRoom(effect.Position + Vector(0, 8), 0)) then
                        effect.Velocity = Vector(effect.Velocity.X, -effect.Velocity.Y)
                        effectData.MaxVelocity = Vector(effectData.MaxVelocity.X, -effectData.MaxVelocity.Y)
                        effectData.Acceleration = effectData.MaxVelocity:Resized(0.02)
                    end
                    if (not room:IsPositionInRoom(effect.Position + Vector(8, 0), 0) and room:IsPositionInRoom(effect.Position + Vector(-8, 0), 0)) or (not room:IsPositionInRoom(effect.Position + Vector(-8, 0), 0) and room:IsPositionInRoom(effect.Position + Vector(8, 0), 0)) then
                        effect.Velocity = Vector(-effect.Velocity.X, effect.Velocity.Y)
                        effectData.MaxVelocity = Vector(-effectData.MaxVelocity.X, effectData.MaxVelocity.Y)
                        effectData.Acceleration = effectData.MaxVelocity:Resized(0.02)
                    end
                end
                if effectData.Type & 1 << 9 == 1 << 9 then
                    if effectData.RotationAngle < 2 * math.pi then
                        effectData.RotationAngle = effectData.RotationAngle + effectData.RotationSpeed
                    else
                        effectData.RotationAngle = effectData.RotationAngle + effectData.RotationSpeed - 2 * math.pi
                    end
                    effect.Velocity = Vector(math.cos(effectData.RotationAngle), math.sin(effectData.RotationAngle)):Resized(ty.ConstantValues.LASERGUNPLASMABALLRANGE / 2) + player.Position + player.Velocity - effect.Position
                end
                if effect.Velocity:Length() < effectData.MaxVelocity:Length() then
                    effect:AddVelocity(effectData.Acceleration)
                elseif not effect:HasEntityFlags(EntityFlag.FLAG_MAGNETIZED) then
                    effectData.Acceleration = Vector(0, 0)
                end
            end
        end
    end
    if effectData.Type & 1 << 6 == 1 << 6 then
        sprite.Scale = Vector(1, 1):Resized((0.8 + effectData.Time * 0.002) * math.sqrt(2))
    end
    if effectData.Type & 1 << 10 == 1 << 10 then
        if effectData.Type & 1 << 6 == 1 << 6 then
            sprite.Scale = Vector(1, 1):Resized(math.max(0, (1.6 - effectData.Time * 0.004)) * math.sqrt(2))
        else
            sprite.Scale = Vector(1, 1):Resized(math.max(0, (1.6 - effectData.Time * 0.006)) * math.sqrt(2))
        end
    end
    SetColor(sprite, effectData.Laser)
    for _, entity in pairs(Isaac.FindInRadius(effect.Position, effect.Size * sprite.Scale.X, EntityPartition.ENEMY)) do
        if ty:IsValidCollider(entity) then
            entity:TakeDamage(player.Damage, DamageFlag.DAMAGE_LASER, EntityRef(player), 0)
        end
    end
end
LaserGun:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, LaserGun.UpdateLaserSwirlEffect, ty.CustomEffects.LASERSWIRL)

function LaserGun:PostKnifeUpdate(knife)
    local knife = knife:ToKnife()
    local knifeData = ty:GetLibData(knife, true)
    local player = knife.SpawnerEntity
	if player and player:ToPlayer() and knifeData.RemoveOnReturn then
        if knife:GetKnifeDistance() > knife.MaxDistance * 0.9 then
            knife:Remove()
        end
	end
end
LaserGun:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, LaserGun.PostKnifeUpdate)

function LaserGun:PostLaserUpdate(laser)
    local parent = laser.Parent
    local data = ty:GetLibData(laser, true)
	if parent and parent:ToEffect() and parent:GetSprite():IsPlaying("EndLoop") and not data.Remove then
        laser:ToLaser():SetTimeout(14)
        data.Remove = true
	end
end
LaserGun:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, LaserGun.PostLaserUpdate)

return LaserGun