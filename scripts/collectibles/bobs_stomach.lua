local BobsStomach = ty:DefineANewClass()

local function SpawnChargeBar(player)
	local chargeBar = Isaac.Spawn(EntityType.ENTITY_EFFECT, ty.CustomEffects.BOBSSTOMACHCHARGEBAR, 0, Vector(player.Position.X + 39, player.Position.Y - (player.SpriteScale.Y * 33) - 27), player.Velocity, nil):ToEffect()
	local chargeBarSprite = chargeBar:GetSprite()
	local chargeBarData = ty:GetLibData(chargeBar)
	chargeBarData.Owner = player
	chargeBar:FollowParent(player)
	chargeBar:AddEntityFlags(EntityFlag.FLAG_PERSISTENT)
	chargeBarSprite.PlaybackSpeed = 1
	chargeBarSprite:Play("Charging")
	chargeBar.DepthOffset = 101
end

local function HasChargeBar(player)
	for _, effect in pairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, ty.CustomEffects.BOBSSTOMACHCHARGEBAR, 0)) do
		local effectData = ty:GetLibData(effect)
		if effectData.Owner and GetPtrHash(effectData.Owner) == GetPtrHash(player) then
			return true
		end
	end
	return false
end

local function GetChargeBar(player)
	for _, effect in pairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, ty.CustomEffects.BOBSSTOMACHCHARGEBAR, 0)) do
		local effectData = ty:GetLibData(effect)
		if effectData.Owner and GetPtrHash(effectData.Owner) == GetPtrHash(player) then
			return effect:ToEffect()
		end
	end
	return nil
end

local function DisappearChargeBar(player)
	for _, effect in pairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, ty.CustomEffects.BOBSSTOMACHCHARGEBAR, 0)) do
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

local function FireTear(player)
    local data = ty:GetLibData(player)
    data.BobsStomach.Fired = true
    data.BobsStomach.CanFire = false
    local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.BLUE, 0, player.Position, Vector(data.BobsStomach.LastDirectionX, data.BobsStomach.LastDirectionY):Normalized():Resized(10) + player:GetTearMovementInheritance(Vector(data.BobsStomach.LastDirectionX, data.BobsStomach.LastDirectionY)), player):ToTear()
    local tearData = ty:GetLibData(tear)
    tearData.BobsStomach = true
    tearData.Owner = player
    tear.TearFlags = tear.TearFlags | player.TearFlags | TearFlags.TEAR_EXPLOSIVE | TearFlags.TEAR_POISON
	if tear:HasTearFlags(TearFlags.TEAR_ABSORB) then
        tear:ClearTearFlags(TearFlags.TEAR_ABSORB)
    end
    tear.Color = Color(0.5, 0.9, 0.4, 1, 0, 0, 0)
    tear.Scale = 1.25
    tear.FallingAcceleration = 0
    tear.FallingSpeed = 0
    tear.Height = player.TearHeight
    tear.CollisionDamage = 15 + 2.5 * player.Damage
end

function BobsStomach:PostPlayerUpdate(player)
	local data = ty:GetLibData(player)
	if data.Init and player:HasCollectible(ty.CustomCollectibles.BOBSSTOMACH) then
		if ty.Functions:IsPlayerFiring(player) then
            local shootingInput = player:GetShootingInput()
            data.BobsStomach.LastDirectionX = shootingInput.X
            data.BobsStomach.LastDirectionY = shootingInput.Y
			if not HasChargeBar(player) then
				SpawnChargeBar(player)
                data.BobsStomach.Fired = false
			end
		elseif HasChargeBar(player) then
            if not data.BobsStomach.Fired and data.BobsStomach.CanFire then
                FireTear(player)
            end
			DisappearChargeBar(player)
		end
    end
end
BobsStomach:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, BobsStomach.PostPlayerUpdate)

function BobsStomach:UpdateChargeBar(effect)
	local player = ty:GetLibData(effect).Owner
    local data = ty:GetLibData(player)
	local sprite = effect:GetSprite()
    if sprite:IsPlaying("Charging") then
        if player:IsHoldingItem() then
            sprite.PlaybackSpeed = 0
        else
            sprite.PlaybackSpeed = 1
        end
    end
	if sprite:IsFinished("Charging") then
		sprite.PlaybackSpeed = 1
		sprite:Play("StartCharged", true)
        data.BobsStomach.CanFire = true
		ty.SFXMANAGER:Play(SoundEffect.SOUND_BEEP)
	end
	if sprite:IsFinished("StartCharged") then
        sprite:Play("Charged", true)
	end
	if sprite:IsFinished("Disappear") or not player:Exists() then
		effect:Remove()
	end
end
BobsStomach:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, BobsStomach.UpdateChargeBar, ty.CustomEffects.BOBSSTOMACHCHARGEBAR)

function BobsStomach:PostTearUpdate(tear)
	local data = ty:GetLibData(tear)
    if data.BobsStomach then
        local player = data.Owner
        local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_GREEN, 0, tear.Position, Vector(0, 0), player):ToEffect()
        creep.Color = tear.Color
        creep:SetDamageSource(EntityType.ENTITY_PLAYER)
        creep.CollisionDamage = 1
        creep:SetTimeout(15)
        creep:Update()
    end
end
BobsStomach:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, BobsStomach.PostTearUpdate, TearVariant.BLUE)

return BobsStomach