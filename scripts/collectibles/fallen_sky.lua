local FallenSky = ty:DefineANewClass()

local functions = ty.Functions

local chainSprite = Sprite("gfx/effects/fallen_sky_chain.anm2", true)
chainSprite:Play("Idle", true)

local function CanTriggerEffect(player, rng, multiplier)
    rng = rng or player:GetCollectibleRNG(ty.CustomCollectibles.FALLENSKY)
    multiplier = multiplier or 1
    return rng:RandomFloat() < multiplier / math.max(5 / 3, 20 / 3 - math.floor(player.Luck / 2))
end

local function GetChainedEnemies(origin)
    local enemies = {}
    for _, entity in pairs(Isaac.FindInRadius(Vector(0, 0), 8192, EntityPartition.ENEMY)) do
        local data = ty:GetLibData(entity).FallenSky
        if data and data.Parent and data.Parent:ToNPC() and GetPtrHash(data.Parent) == GetPtrHash(origin) then
            table.insert(enemies, entity)
        end
    end
    return enemies
end

local function MarkTheEnemy(enemy, player, parent, multiplier)
    local newData = {}
    newData.Player = player
    newData.Parent = parent
    newData.Timeout = 120
    newData.Multiplier = multiplier
    ty:GetLibData(enemy).FallenSky = newData
end

local function SpawnFallenSword(entity, player, chain, multiplier)
    local sword = Isaac.Spawn(EntityType.ENTITY_EFFECT, ty.CustomEffects.FALLENSKYSWORD, 0, entity.Position - Vector(0, 500), Vector(0, 0), player):ToEffect()
    local swordSprite = sword:GetSprite()
    local rng = sword:GetDropRNG()
    local randomNumber = rng:RandomFloat()
    if randomNumber < 1 / 3 then
        swordSprite:ReplaceSpritesheet(0, "gfx/effects/fallen_sky_sword_alt.png", true)
    elseif randomNumber >= 1 / 3 and randomNumber < 2 / 3 then
        swordSprite:ReplaceSpritesheet(0, "gfx/effects/fallen_sky_sword_alt_2.png", true)
    end
    swordSprite:Play("Fall", true)
    swordSprite.PlaybackSpeed = 1.5
    sword.DepthOffset = entity.DepthOffset + 1
    local swordData = ty:GetLibData(sword)
    swordData.Player = player
    swordData.Target = entity
    swordData.Position = 500
    swordData.Multiplier = multiplier or 1
    swordData.Chain = chain or (player:HasCollectible(CollectibleType.COLLECTIBLE_PARASITE) or player:HasCollectible(CollectibleType.COLLECTIBLE_CRICKETS_BODY))
    swordData.Delay = 0
end

local function SpawnAGroupOfFallenSwords(entity, player)
    local rng = player:GetCollectibleRNG(ty.CustomCollectibles.FALLENSKY)
    local times = rng:RandomInt(6, 11)
    for i = 0, times - 1 do
        local sword = Isaac.Spawn(EntityType.ENTITY_EFFECT, ty.CustomEffects.FALLENSKYSWORD, 0, entity.Position + rng:RandomVector() * rng:RandomInt(60) - Vector(0, 500), Vector(0, 0), player):ToEffect()
        local swordSprite = sword:GetSprite()
        local randomNumber = rng:RandomFloat()
        if randomNumber < 1 / 3 then
            swordSprite:ReplaceSpritesheet(0, "gfx/effects/fallen_sky_sword_alt.png", true)
        elseif randomNumber >= 1 / 3 and randomNumber < 2 / 3 then
            swordSprite:ReplaceSpritesheet(0, "gfx/effects/fallen_sky_sword_alt_2.png", true)
        end
        swordSprite:Play("Fall", true)
        swordSprite.PlaybackSpeed = 0
        sword.DepthOffset = entity.DepthOffset + 1
        local swordData = ty:GetLibData(sword)
        swordData.Player = player
        swordData.Target = entity
        swordData.Position = 500
        swordData.Multiplier = 0.5
        swordData.Chain = false
        swordData.Group = true
        swordData.Delay = i * 2
    end
end

local function HarmTheEnemy(enemy, player, multiplier)
    if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_KNIFE) then
        multiplier = multiplier * 3
    end
    enemy:TakeDamage(2.5 * player.ShotSpeed * player.Damage * multiplier, DamageFlag.DAMAGE_SPIKES, EntityRef(player), 0)
    local countdown = enemy:GetBossStatusEffectCooldown()
    enemy:SetBossStatusEffectCooldown(0)
    enemy:AddBleeding(EntityRef(player), 90)
    enemy:GetBossStatusEffectCooldown(countdown)
    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 0, enemy.Position, Vector(0, 0), nil)
    enemy:BloodExplode()
end

local function HarmNearbyEnemies(effect)
    local effectData = ty:GetLibData(effect)
    local player = effectData.Player
    local target = effectData.Target or player
    local chain = effectData.Chain
    local multiplier = effectData.Multiplier
    local enemyFound = false
    for _, enemy in pairs(Isaac.FindInRadius(effect.Position, player.TearRange / 2, EntityPartition.ENEMY)) do
        if GetPtrHash(enemy) == GetPtrHash(target) then
            HarmTheEnemy(enemy, player, multiplier)
            if chain and ty:GetLibData(enemy).FallenSky == nil then
                MarkTheEnemy(enemy, player, nil, multiplier)
            end
        elseif functions:IsValidEnemy(enemy) then
            if enemy.Position:Distance(effect.Position) <= 24 then
                HarmTheEnemy(enemy, player, multiplier)
                enemyFound = true
            end
            if chain and ty:GetLibData(enemy).FallenSky == nil then
                MarkTheEnemy(enemy, player, target, multiplier)
            end
        end
    end
    ty.SFXMANAGER:Play(SoundEffect.SOUND_GOOATTACH0, 0.6)
    if enemyFound then
        ty.SFXMANAGER:Play(SoundEffect.SOUND_MEATY_DEATHS, 0.6)
    end
end

function FallenSky:PostFireTear(tear)
    local player = functions:GetPlayerFromTear(tear)
    if player and player:HasCollectible(ty.CustomCollectibles.FALLENSKY) then
        if CanTriggerEffect(player) then
            local newTear = Isaac.Spawn(EntityType.ENTITY_TEAR, (tear.Variant == TearVariant.FETUS and TearVariant.FETUS) or TearVariant.SWORD_BEAM, 0, tear.Position - Vector(0, 16), tear.Velocity, tear.SpawnerEntity):ToTear()
            if newTear.Variant == TearVariant.SWORD_BEAM then
                newTear:GetSprite():ReplaceSpritesheet(0, "gfx/effects/fallen_sky_sword_effect.png", true)
            end
            newTear.TearFlags = tear.TearFlags | ty.CustomTearFlags.FALLENSKY
            newTear.FallingSpeed = tear.FallingSpeed
            newTear.FallingAcceleration = tear.FallingAcceleration
            newTear.ContinueVelocity = tear.ContinueVelocity
            newTear.Height = tear.Height
            newTear.CollisionDamage = tear.CollisionDamage
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CRACKED_ORB_POOF, 0, newTear.Position + Vector(0, 20), Vector(0, 0), nil):GetSprite().PlaybackSpeed = 1.5
            tear:Remove()
        end
    end
end
FallenSky:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, FallenSky.PostFireTear)

function FallenSky:UpdateSword(effect)
    local sprite = effect:GetSprite()
    local data = ty:GetLibData(effect)
    if sprite:IsPlaying("Fall") and data.Position > 0 then
        if data.Delay > 0 then
            data.Delay = data.Delay - 1
        else
            if sprite.PlaybackSpeed == 0 then
                sprite.PlaybackSpeed = 1.5
            end
            data.Position = data.Position - 50
            if not data.Group then
                effect.Position = data.Target.Position - Vector(0, data.Position)
            else
                effect.Position = effect.Position + Vector(0, 50)
            end
        end
    end
    if sprite:IsFinished("Fall") then
        sprite.PlaybackSpeed = 1
        sprite:Play("Disappear", true)
    end
    if sprite:IsFinished("Disappear") then
        effect:Remove()
    end
    if sprite:IsEventTriggered("Hit") then
        HarmNearbyEnemies(effect)
    end
end
FallenSky:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, FallenSky.UpdateSword, ty.CustomEffects.FALLENSKYSWORD)

function FallenSky:PostNPCRender(npc, offset)
    local data = ty:GetLibData(npc).FallenSky
    if data and data.Timeout <= 118 then
        local enemyPos = npc.Position
        local parent = data.Parent
        if parent == nil and #GetChainedEnemies(npc) > 0 then
            chainSprite:RenderLayer(0, Isaac.WorldToScreen(enemyPos))
        end
        if parent and parent:ToNPC() and parent:Exists() then
            local differVector = parent.Position - enemyPos
            local beam = Beam(chainSprite, "chain", false, false)
            beam:Add(Isaac.WorldToScreen(enemyPos), 0)
            beam:Add(Isaac.WorldToScreen(parent.Position), differVector:Length())
            beam:Render()
            chainSprite:RenderLayer(0, Isaac.WorldToScreen(enemyPos))
        end
    end
end
FallenSky:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, FallenSky.PostNPCRender)

function FallenSky:PostNPCUpdate(npc)
    local npcData = ty:GetLibData(npc).FallenSky
    if npcData then
        local enemyPos = npc.Position
        local player = npcData.Player
        local parent = npcData.Parent
        local multiplier = npcData.Multiplier
        if npcData.Timeout == 0 then
            if parent then
                SpawnFallenSword(npc, player, nil, multiplier) 
            end
            ty:GetLibData(npc).FallenSky = nil
        end
        if npc.EntityCollisionClass == EntityCollisionClass.ENTCOLL_NONE or (parent and parent:ToNPC() and (not parent:Exists() or ty:GetLibData(parent).FallenSky == nil)) then
            ty:GetLibData(npc).FallenSky = nil
        end
        if npcData.Timeout > 0 then
            if npcData.Timeout < 118 then
                npc:AddBurn(EntityRef(player), 2, player.Damage)
            end
            npcData.Timeout = npcData.Timeout - 1
        end
    end
end
FallenSky:AddCallback(ModCallbacks.MC_NPC_UPDATE, FallenSky.PostNPCUpdate)

function FallenSky:PostTearCollision(tear, collider, low)
    local tearData = ty:GetLibData(tear)
    local player = functions:GetPlayerFromTear(tear)
    if tear:HasTearFlags(TearFlags.TEAR_LUDOVICO) and tear.TearFlags & ty.CustomTearFlags.FALLENSKY ~= ty.CustomTearFlags.FALLENSKY then
        tear.TearFlags = tear.TearFlags | ty.CustomTearFlags.FALLENSKY
    end
    if tear.TearFlags & ty.CustomTearFlags.FALLENSKY == ty.CustomTearFlags.FALLENSKY and functions:IsValidEnemy(collider) then
        if tear.Variant == TearVariant.FETUS and tear.FrameCount % 16 ~= 0 then
            return
        end
        if tear:HasTearFlags(TearFlags.TEAR_LUDOVICO) and not CanTriggerEffect(player, nil, 0.2) then
            return
        end
        if (tear:HasTearFlags(TearFlags.TEAR_STICKY) or tear:HasTearFlags(TearFlags.TEAR_BOOGER) or tear:HasTearFlags(TearFlags.TEAR_SPORE)) and tear.FrameCount % 30 ~= 0 then
            return
        end
        if tear:HasTearFlags(TearFlags.TEAR_BURSTSPLIT) then
            SpawnAGroupOfFallenSwords(collider, player)
        else
            SpawnFallenSword(collider, player, true, tear.CollisionDamage / player.Damage)
        end
    end
end
FallenSky:AddCallback(ModCallbacks.MC_POST_TEAR_COLLISION, FallenSky.PostTearCollision)

function FallenSky:PostBombUpdate(bomb)
	local bomb = bomb:ToBomb()
	local player = bomb.SpawnerEntity and bomb.SpawnerEntity:ToPlayer()
    local bombData = ty:GetLibData(bomb)
	if player and player:HasCollectible(ty.CustomCollectibles.FALLENSKY) and bomb.IsFetus and bomb:GetExplosionCountdown() == 0 and not bombData.Exploded then
        bombData.Exploded = true
        for _, enemy in pairs(Isaac.FindInRadius(bomb.Position, bomb.RadiusMultiplier * player.TearRange / 4, EntityPartition.ENEMY)) do
            if functions:IsValidEnemy(enemy) and CanTriggerEffect(player, bomb:GetDropRNG()) then
                SpawnFallenSword(enemy, player, true)
            end
        end
	end
end
FallenSky:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, FallenSky.PostBombUpdate)

function FallenSky:PostRocketEffectUpdate(rocket)
	local rocket = rocket:ToEffect()
	local player = rocket.SpawnerEntity and rocket.SpawnerEntity:ToPlayer()
	if player and player:HasCollectible(ty.CustomCollectibles.FALLENSKY) and rocket.PositionOffset.Y == 0 then
		for _, enemy in pairs(Isaac.FindInRadius(rocket.Position, player.TearRange / 4, EntityPartition.ENEMY)) do
            if functions:IsValidEnemy(enemy) and CanTriggerEffect(player, rocket:GetDropRNG(), 2) then
                SpawnFallenSword(enemy, player, true)
            end
        end
	end
end
FallenSky:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, FallenSky.PostRocketEffectUpdate, EffectVariant.ROCKET)

function FallenSky:PostLaserCollision(laser, collider, low)
	local laser = laser:ToLaser()
	local player = laser.SpawnerEntity and laser.SpawnerEntity:ToPlayer()
	if player and player:HasCollectible(ty.CustomCollectibles.FALLENSKY) and functions:IsValidEnemy(collider) then
        if CanTriggerEffect(player, laser:GetDropRNG()) then
            SpawnFallenSword(collider, player, true, (not laser:GetDisableFollowParent() and not laser:GetOneHit() and laser.SubType == LaserSubType.LASER_SUBTYPE_LINEAR and 0.13) or 1)
        end
	end
end
FallenSky:AddCallback(ModCallbacks.MC_POST_LASER_COLLISION, FallenSky.PostLaserCollision)

function FallenSky:PostKnifeCollision(knife, collider, low)
	local knife = knife:ToKnife()
	local player = knife.SpawnerEntity and knife.SpawnerEntity:ToPlayer()
	if player and player:HasCollectible(ty.CustomCollectibles.FALLENSKY) and functions:IsValidEnemy(collider) then
        if (knife.Variant == KnifeVariant.MOMS_KNIFE or knife.Variant == KnifeVariant.SUMPTORIUM) then
            if ((knife:IsFlying() and knife:GetKnifeDistance() / knife.MaxDistance < 0.8) and CanTriggerEffect(player, knife:GetDropRNG(), 0.4)) or ((not knife:IsFlying() or knife:GetKnifeDistance() / knife.MaxDistance >= 0.8) and CanTriggerEffect(player, knife:GetDropRNG(), 0.5)) then
                SpawnFallenSword(collider, player, true)
            end
        elseif CanTriggerEffect(player, knife:GetDropRNG()) then
            SpawnFallenSword(collider, player, true)
		end
	end
end
FallenSky:AddCallback(ModCallbacks.MC_POST_KNIFE_COLLISION, FallenSky.PostKnifeCollision)

return FallenSky