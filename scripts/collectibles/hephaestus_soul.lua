local HephaestusSoul = ty:DefineANewClass()

local laserCollectibles = {
    [1] = CollectibleType.COLLECTIBLE_TECHNOLOGY,
    [2] = CollectibleType.COLLECTIBLE_TECHNOLOGY_2,
    [3] = CollectibleType.COLLECTIBLE_BRIMSTONE,
    [4] = CollectibleType.COLLECTIBLE_TECH_5,
    [5] = CollectibleType.COLLECTIBLE_TECH_X,
    [6] = CollectibleType.COLLECTIBLE_TECHNOLOGY_ZERO
}

local function GetCircleAttribute(player, type)
	local tearDelay = math.floor(90 / (player.MaxFireDelay + 1)) + 1
	local tearRange = math.sqrt(player.TearRange / 260) * 0.86
	if type == "CircleMaxRange" then
		return math.min(math.max(0.4, tearRange), 1.4) / 2
	elseif type == "CircleRangeDelta" then
		return Vector(tearDelay / 4096 * tearRange, tearDelay / 4096 * tearRange)
	elseif type == "CircleAlphaDelta" then
		return ty.ConstantValues.HEPHAESTUSSOULCIRCLEALPHA / 1024 * tearDelay
	end
end

local function SpawnCircle(player)
	local circle = Isaac.Spawn(EntityType.ENTITY_EFFECT, ty.CustomEffects.HEPHAESTUSSOULCIRCLE, 0, player.Position, player.Velocity, player):ToEffect()
	local circleSprite = circle:GetSprite()
	circle:FollowParent(player)
	circle:AddEntityFlags(EntityFlag.FLAG_PERSISTENT)
	circleSprite.Scale = Vector(0, 0)
	circleSprite.Color = Color(1, 1, 1, 0)
end

local function HasCircle(player)
	for _, effect in pairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, ty.CustomEffects.HEPHAESTUSSOULCIRCLE, 0)) do
		if effect.SpawnerEntity and GetPtrHash(effect.SpawnerEntity) == GetPtrHash(player) then
			return true
		end
	end
	return false
end

local function GetCircle(player)
	for _, effect in pairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, ty.CustomEffects.HEPHAESTUSSOULCIRCLE, 0)) do
		if effect.SpawnerEntity and GetPtrHash(effect.SpawnerEntity) == GetPtrHash(player) then
			return effect:ToEffect()
		end
	end
	return nil
end

local function DisappearCircle(player)
	for _, effect in pairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, ty.CustomEffects.HEPHAESTUSSOULCIRCLE, 0)) do
		if effect.SpawnerEntity and GetPtrHash(effect.SpawnerEntity) == GetPtrHash(player) then
			local sprite = effect:GetSprite()
			if not sprite:IsPlaying("Disappear") then
				sprite:Play("Disappear", true)
			end
		end
	end
end

local function GetFlameType(player)
	local flameType = 1 << 0
	if player:HasCollectible(CollectibleType.COLLECTIBLE_SPOON_BENDER) or player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_TELEPATHY_BOOK) or player.TearFlags & TearFlags.TEAR_HOMING == TearFlags.TEAR_HOMING then
		flameType = flameType | 1 << 1 | 1 << 2
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_GHOST_PEPPER) then
		flameType = flameType | 1 << 1
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRDS_EYE) then
		flameType = flameType | 1 << 3
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_TRISAGION) then
		flameType = flameType | 1 << 4
	end
	return flameType
end

local function DoDamageInCircle(player)
	local circle = GetCircle(player)
	if circle then
		local circleSprite = circle:GetSprite()
		if not circleSprite:IsPlaying("Disappear") then
			for _, entity in pairs(Isaac.FindInRadius(player.Position, circleSprite.Scale.X * 2 * ty.ConstantValues.HEPHAESTUSSOULCIRCLE, EntityPartition.ENEMY)) do
				if entity:IsActiveEnemy() and entity.Type ~= EntityType.ENTITY_FIREPLACE and not entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_CHARM) then
					local fireJet = Isaac.Spawn(EntityType.ENTITY_EFFECT, ty.CustomEffects.HEPHAESTUSSOULFIREJET, 0, entity.Position, Vector(0, 0), player):ToEffect()
					local fireData = ty:GetLibData(fireJet, true)
					fireData.DamageValue = math.sqrt(circle:GetSprite().Scale.X * 2) * player.Damage * 4
					fireData.Owner = player
					fireData.Target = entity
					if GetFlameType(player) & 1 << 2 == 1 << 2 then
						fireJet:GetSprite():Play("IdlePurple")
					end
				end
			end
		end
	end
end

local function DoFireExplosion(target, player, damageValue)
	local explosionDamage = damageValue
	if player:HasCollectible(CollectibleType.COLLECTIBLE_IPECAC) then
		explosionDamage = explosionDamage * 0.2 + 10
	end
	local rng = player:GetCollectibleRNG(ty.CustomCollectibles.HEPHAESTUSSOUL)
	if rng:RandomInt(100) < (100 / math.max(1, 5 - math.floor(player.Luck / 3))) then
		Isaac.Explode(target.Position, player, explosionDamage * 3)
		local explosionFire = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HOT_BOMB_FIRE, 0, target.Position, Vector(0, 0), player):ToEffect()
		explosionFire:SetTimeout(180)
		explosionFire.CollisionDamage = explosionDamage
	end
end

local function SpawnAFlame(player, tear, ludovicoTear)
	local flame = nil
	local flameType = GetFlameType(player)
	if flameType & 1 << 4 == 1 << 4 or tear:HasTearFlags(TearFlags.TEAR_LASERSHOT) then
		return
	end
	if flameType & 1 << 1 == 1 << 1 then
		flame = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLUE_FLAME, 0, tear.Position - Vector(0, 16), tear.Velocity, player):ToEffect()
		if flameType & 1 << 2 == 1 << 2 then
			flame:GetSprite():ReplaceSpritesheet(0, "gfx/effects/effect_005_fire_purple.png", true)
		end
		flame.CollisionDamage = tear.BaseDamage * 0.6
	else
		flame = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLUE_FLAME, 0, tear.Position - Vector(0, 16), tear.Velocity, player):ToEffect()
		flame:GetSprite():ReplaceSpritesheet(0, "gfx/effects/effect_005_fire.png", true)
		flame.CollisionDamage = tear.BaseDamage * 0.4
		if flameType & 1 << 3 == 1 << 3 then
			flame.CollisionDamage = flame.CollisionDamage * 2
		end
	end
	flame:FollowParent(tear)
	flame.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
	if ludovicoTear then
		flame.CollisionDamage = flame.CollisionDamage * 10 / 3
		flame.SpriteScale = Vector(tear.BaseScale * 0.9, tear.BaseScale * 0.9)
		flame.SizeMulti = flame.SpriteScale
		flame.ParentOffset = Vector(0, 14.4 * tear.BaseScale)
		flame:SetTimeout(1 << 16)
	else
		flame.SpriteScale = Vector(tear.BaseScale, tear.BaseScale)
		flame.SizeMulti = flame.SpriteScale
		flame.ParentOffset = Vector(0, 16 * tear.BaseScale)
		flame:SetTimeout(math.ceil(player.TearRange))
	end
	local flameData = ty:GetLibData(flame, true)
	flameData.HephaestusSoul = true
end

function HephaestusSoul:EvaluateCache(player, cacheFlag)
    if player:HasCollectible(ty.CustomCollectibles.HEPHAESTUSSOUL) then
		player.CanFly = true
    end
end
HephaestusSoul:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, HephaestusSoul.EvaluateCache, CacheFlag.CACHE_FLYING)

function HephaestusSoul:PostFireTear(tear)
	local tear = tear:ToTear()
	local player = ty:GetPlayerFromTear(tear)
	if player and player:HasCollectible(ty.CustomCollectibles.HEPHAESTUSSOUL) then
		SpawnAFlame(player, tear, false)
	end
end
HephaestusSoul:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, HephaestusSoul.PostFireTear)

function HephaestusSoul:PostTearUpdate(tear)
	local tear = tear:ToTear()
	local player = ty:GetPlayerFromTear(tear)
	if player and player:HasCollectible(ty.CustomCollectibles.HEPHAESTUSSOUL) and tear:HasTearFlags(TearFlags.TEAR_LUDOVICO) and ty:GetLibData(tear, true).FlameSpawned == nil then
		SpawnAFlame(player, tear, true)
		local tearData = ty:GetLibData(tear, true)
		tearData.FlameSpawned = true
	end
end
HephaestusSoul:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, HephaestusSoul.PostTearUpdate)

function HephaestusSoul:PostFireBomb(bomb)
	local bomb = bomb:ToBomb()
	local player = bomb.SpawnerEntity and bomb.SpawnerEntity:ToPlayer()
	if player and player:HasCollectible(ty.CustomCollectibles.HEPHAESTUSSOUL) then
		bomb:AddTearFlags(TearFlags.TEAR_BURN)
	end
end
HephaestusSoul:AddCallback(ModCallbacks.MC_POST_FIRE_BOMB, HephaestusSoul.PostFireBomb)

function HephaestusSoul:PostLaserCollision(laser, collider, low)
	local laser = laser:ToLaser()
	local player = laser.SpawnerEntity and laser.SpawnerEntity:ToPlayer()
	if player and player:HasCollectible(ty.CustomCollectibles.HEPHAESTUSSOUL) and ty:IsValidCollider(collider) then
		local fireJet = Isaac.Spawn(EntityType.ENTITY_EFFECT, ty.CustomEffects.HEPHAESTUSSOULFIREJET, 0, collider.Position, Vector(0, 0), player):ToEffect()
		local fireData = ty:GetLibData(fireJet, true)
		fireData.DamageValue = laser.CollisionDamage * 2
		fireData.Owner = player
		fireData.Target = collider
	end
end
HephaestusSoul:AddCallback(ModCallbacks.MC_POST_LASER_COLLISION, HephaestusSoul.PostLaserCollision)

function HephaestusSoul:PostKnifeCollision(knife, collider, low)
	local knife = knife:ToKnife()
	local player = knife.SpawnerEntity and knife.SpawnerEntity:ToPlayer()
	if player and player:HasCollectible(ty.CustomCollectibles.HEPHAESTUSSOUL) and ty:IsValidCollider(collider) then
		local fireJet = Isaac.Spawn(EntityType.ENTITY_EFFECT, ty.CustomEffects.HEPHAESTUSSOULFIREJET, 0, collider.Position, Vector(0, 0), player):ToEffect()
		local fireData = ty:GetLibData(fireJet, true)
		fireData.DamageValue = knife.CollisionDamage
		fireData.Owner = player
		fireData.Target = collider
	end
end
HephaestusSoul:AddCallback(ModCallbacks.MC_POST_KNIFE_COLLISION, HephaestusSoul.PostKnifeCollision)

function HephaestusSoul:PostRocketEffectUpdate(rocket)
	local rocket = rocket:ToEffect()
	local player = rocket.SpawnerEntity and rocket.SpawnerEntity:ToPlayer()
	if player and player:HasCollectible(ty.CustomCollectibles.HEPHAESTUSSOUL) and rocket.PositionOffset.Y == 0 then
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HOT_BOMB_FIRE, 0, rocket.Position, Vector(0, 0), player)
	end
end
HephaestusSoul:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, HephaestusSoul.PostRocketEffectUpdate, EffectVariant.ROCKET)

function HephaestusSoul:PostRedCandleFlameEffectUpdate(flame)
	local flame = flame:ToEffect()
	local tear = flame.Parent
	local flameData = ty:GetLibData(flame, true)
	if not flameData.HephaestusSoul then
		return
	end
	if tear and tear:ToTear() then
		local tear = tear:ToTear()
		flame.SpriteScale = Vector(tear.Scale, tear.Scale)
		flame.SizeMulti = flame.SpriteScale
		flame.ParentOffset = Vector(0, 16 * tear.Scale)
	end
	if flame.Timeout > 30 and (not tear or not tear:Exists()) then
		flame:SetTimeout(30)
	end
end
HephaestusSoul:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, HephaestusSoul.PostRedCandleFlameEffectUpdate, EffectVariant.RED_CANDLE_FLAME)

function HephaestusSoul:PostBlueFlameEffectUpdate(flame)
	local flame = flame:ToEffect()
	local tear = flame.Parent
	local flameData = ty:GetLibData(flame, true)
	if not flameData.HephaestusSoul then
		return
	end
	if tear and tear:ToTear() then
		local tear = tear:ToTear()
		flame.SpriteScale = Vector(tear.Scale, tear.Scale)
		flame.SizeMulti = flame.SpriteScale
		flame.ParentOffset = Vector(0, 16 * tear.Scale)
	end
	if flame.Timeout > 45 and (not tear or not tear:Exists()) then
		flame:SetTimeout(45)
	end
end
HephaestusSoul:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, HephaestusSoul.PostBlueFlameEffectUpdate, EffectVariant.BLUE_FLAME)

function HephaestusSoul:PrePlayerTakeDamage(player, amount, flags, source, countdown)
	if player:HasCollectible(ty.CustomCollectibles.HEPHAESTUSSOUL) and flags & DamageFlag.DAMAGE_FIRE == DamageFlag.DAMAGE_FIRE and not (source.Type == EntityType.ENTITY_FIREPLACE and source.Variant == 4) then
		return false
	end
end
HephaestusSoul:AddCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, HephaestusSoul.PrePlayerTakeDamage)

function HephaestusSoul:PostAddCollectible(type, charge, firstTime, slot, varData, player)
	if type == ty.CustomCollectibles.HEPHAESTUSSOUL then
		player:GetEffects():AddNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.HEPHAESTUSSOUL).ID)
		player:SetLaserColor(Color.LaserFireMind)
	end
	if player:HasCollectible(ty.CustomCollectibles.HEPHAESTUSSOUL) and ty:IsValueInTable(type, laserCollectibles) then
		player:SetLaserColor(Color.LaserFireMind)
	end
end
HephaestusSoul:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, HephaestusSoul.PostAddCollectible)

function HephaestusSoul:PostTriggerCollectibleRemoved(player, type)
	player:GetEffects():RemoveNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.HEPHAESTUSSOUL).ID)
	player:SetLaserColor(ty:GetLaserColor(player))
end
HephaestusSoul:AddCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_REMOVED, HephaestusSoul.PostTriggerCollectibleRemoved, ty.CustomCollectibles.HEPHAESTUSSOUL)

function HephaestusSoul:PostPlayerUpdate(player)
    local data = ty:GetLibData(player)
    local playerEffects = player:GetEffects()
    if data.Init and player:HasCollectible(ty.CustomCollectibles.HEPHAESTUSSOUL) then
		if ty:IsPlayerFiring(player) then
			if HasCircle(player) and (player:HasWeaponType(WeaponType.WEAPON_TEARS) or player:HasWeaponType(WeaponType.WEAPON_FETUS) or player:HasWeaponType(WeaponType.WEAPON_BOMBS) or player:HasWeaponType(WeaponType.WEAPON_ROCKETS) or player:HasWeaponType(WeaponType.WEAPON_KNIFE) or player:HasWeaponType(WeaponType.WEAPON_BONE) or player:HasWeaponType(WeaponType.WEAPON_NOTCHED_AXE) or player:HasWeaponType(WeaponType.WEAPON_SPIRIT_SWORD)) then
				local circleSprite = GetCircle(player):GetSprite()
				if circleSprite.Scale.X <= GetCircleAttribute(player, "CircleMaxRange") then
					if player:CanShoot() and player:IsExtraAnimationFinished() then
						circleSprite.Scale = circleSprite.Scale + GetCircleAttribute(player, "CircleRangeDelta")
					end
					circleSprite.Color = Color(1, 1, 1, math.min(circleSprite.Color.A + GetCircleAttribute(player, "CircleAlphaDelta"), ty.ConstantValues.HEPHAESTUSSOULCIRCLEALPHA))
				end
			else
				SpawnCircle(player)
			end
		elseif HasCircle(player) then
			DoDamageInCircle(player)
			DisappearCircle(player)
		end
    end
end
HephaestusSoul:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, HephaestusSoul.PostPlayerUpdate)

function HephaestusSoul:UpdateCircle(effect)
	local player = effect.SpawnerEntity
    local sprite = effect:GetSprite()
	if sprite:IsFinished("Disappear") or (player and not player:Exists()) then
		effect:Remove()
	end
end
HephaestusSoul:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, HephaestusSoul.UpdateCircle, ty.CustomEffects.HEPHAESTUSSOULCIRCLE)

function HephaestusSoul:UpdateFireJet(effect)
	local effectData = ty:GetLibData(effect, true)
	local player = effectData.Owner
	local target = effectData.Target
	local effectSprite = effect:GetSprite()
	if effectSprite:IsFinished("Idle") or effectSprite:IsFinished("IdlePurple") then
		effect:Remove()
	elseif effect.FrameCount < 13 then
		local fireDamage = effectData.DamageValue
		for _, entity in pairs(Isaac.FindInRadius(effect.Position, 14, EntityPartition.ENEMY)) do
			if entity:IsActiveEnemy() and entity.Type ~= EntityType.ENTITY_FIREPLACE and not entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_CHARM) then
				if effect.FrameCount == 1 then
					entity:TakeDamage(fireDamage, DamageFlag.DAMAGE_FIRE, EntityRef(player), 0)
					DoFireExplosion(target, player, effectData.DamageValue)
					entity:AddBurn(EntityRef(player), 60, player.Damage)
					ty.SFXMANAGER:Play(SoundEffect.SOUND_FIREDEATH_HISS)
				end
			end
		end
	end
end
HephaestusSoul:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, HephaestusSoul.UpdateFireJet, ty.CustomEffects.HEPHAESTUSSOULFIREJET)

return HephaestusSoul