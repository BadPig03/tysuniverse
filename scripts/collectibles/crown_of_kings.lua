local CrownOfKings = ty:DefineANewClass()

local function HasCrown(player)
    for _, effect in pairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, ty.CustomEffects.CROWNOFKINGS)) do
        local effectData = ty:GetLibData(effect)
        if effectData.Owner and GetPtrHash(effectData.Owner) == GetPtrHash(player) then
            return true
        end
    end
    return false
end

local function GetCrownMask(player)
    local mask = 1 << 0
    if player:HasCollectible(CollectibleType.COLLECTIBLE_CROWN_OF_LIGHT) then
        mask = mask | 1 << 1
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_DARK_PRINCES_CROWN) then
        mask = mask | 1 << 2
    end
    if player:HasCollectible(ty.CustomCollectibles.CROWNOFKINGS) then
        mask = mask | 1 << 3
    end
    return mask
end

local function SpawnCrown(player)
    local crown = Isaac.Spawn(EntityType.ENTITY_EFFECT, ty.CustomEffects.CROWNOFKINGS, 0, player.Position, Vector(0, 0), player):ToEffect()
    local crownData = ty:GetLibData(crown)
    local crownSprite = crown:GetSprite()
    local data = ty:GetLibData(player)
    local mask = GetCrownMask(player)
    local flyOffset = Vector(0, 0)
    if player.CanFly then
        flyOffset = Vector(0, -4)
    end
    local scale = data.PlayerSize.Scale
    crownSprite.Scale = Vector(1, 1) * scale
    crown.DepthOffset = 0.1
    if mask & 1 << 1 == 1 << 1 and mask & 1 << 2 == 1 << 2 then
        crown.Position = crown.Position + Vector(0, -21) + flyOffset
    elseif (mask & 1 << 1 == 1 << 1 and mask & 1 << 2 ~= 1 << 2) or (mask & 1 << 1 ~= 1 << 1 and mask & 1 << 2 == 1 << 2) then
        crown.Position = crown.Position + Vector(0, -10.5) + flyOffset
    else
        crown.Position = crown.Position + flyOffset
    end
    if data.CrownOfKings.CanSpawn then
        crownSprite:Play("FloatGlow")
    else
        crownSprite:Play("FloatNoGlow")
    end
    crown:FollowParent(player)
    crownData.Owner = player
end

local function GetCollectibleQualityFromRandomPool(lowQuality, highQuality, rng)
	for itemID = 1, ty.ITEMCONFIG:GetCollectibles().Size - 1 do
		if ItemConfig.Config.IsValidCollectible(itemID) and (ty.ITEMCONFIG:GetCollectible(itemID).Quality > highQuality or ty.ITEMCONFIG:GetCollectible(itemID).Quality < lowQuality) then
			ty.ITEMPOOL:AddRoomBlacklist(itemID)
		end
	end
	local itemID = ty.ITEMPOOL:GetCollectible(rng:RandomInt(ItemPoolType.NUM_ITEMPOOLS), false, rng:Next(), CollectibleType.COLLECTIBLE_BREAKFAST)
    ty.ITEMPOOL:RemoveCollectible(itemID)
    ty.ITEMPOOL:ResetRoomBlacklist()
    return itemID
end

function CrownOfKings:PostPlayerUpdate(player)
    local data = ty:GetLibData(player)
    local mask = GetCrownMask(player)
    if data.Init and mask & 1 << 3 == 1 << 3 and not HasCrown(player) then
        SpawnCrown(player)
    end
end
CrownOfKings:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, CrownOfKings.PostPlayerUpdate)

function CrownOfKings:PostNewRoom()
    local room = ty.GAME:GetRoom()
    for _, player in pairs(PlayerManager.GetPlayers()) do
        local data = ty:GetLibData(player)
        if player:HasCollectible(ty.CustomCollectibles.CROWNOFKINGS) then
            for _, ent in pairs(Isaac.GetRoomEntities()) do
                if ent:IsBoss() then
                    data.CrownOfKings.CanSpawn = true
                    return
                end
            end
            if room:GetType() == RoomType.ROOM_CHALLENGE and ty.LEVEL:HasBossChallenge() and not room:IsAmbushDone() then
                data.CrownOfKings.CanSpawn = true
                data.CrownOfKings.IsBossChallenge = true
                return
            end
            if room:GetType() == RoomType.ROOM_BOSSRUSH and not room:IsAmbushDone() then
                data.CrownOfKings.CanSpawn = true
                data.CrownOfKings.IsBossrush = true
                return
            end
        end
        data.CrownOfKings.CanSpawn = false
    end
end
CrownOfKings:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, CrownOfKings.PostNewRoom)

function CrownOfKings:PreSpawnCleanAward(rng, spawnPosition)
    local room = ty.GAME:GetRoom()
    for _, player in pairs(PlayerManager.GetPlayers()) do
        local data = ty:GetLibData(player)
        if player:HasCollectible(ty.CustomCollectibles.CROWNOFKINGS) and data.CrownOfKings.CanSpawn then
            local collectibleID = CollectibleType.COLLECTIBLE_BREAKFAST
            if room:GetType() == RoomType.ROOM_CHALLENGE and data.CrownOfKings.IsBossChallenge then
                collectibleID = GetCollectibleQualityFromRandomPool(1, 3, rng)
                data.CrownOfKings.IsBossChallenge = false
            elseif room:GetType() == RoomType.ROOM_BOSSRUSH and data.CrownOfKings.IsBossrush then
                collectibleID = GetCollectibleQualityFromRandomPool(3, 3, rng)
                data.CrownOfKings.IsBossrush = false
            else
                collectibleID = GetCollectibleQualityFromRandomPool(0, 3, rng)
            end
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, collectibleID, room:FindFreePickupSpawnPosition(room:GetCenterPos(), 0, true), Vector(0, 0), nil) 
            data.CrownOfKings.CanSpawn = false
            player:AnimateHappy()
        end
    end
end
CrownOfKings:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, CrownOfKings.PreSpawnCleanAward)

function CrownOfKings:PostTakeDamage(entity, amount, flags, source, countdown)
    local player = entity:ToPlayer()
    local data = ty:GetLibData(player)
    if player:HasCollectible(ty.CustomCollectibles.CROWNOFKINGS) and data.CrownOfKings.CanSpawn then
        data.CrownOfKings.CanSpawn = false
        data.CrownOfKings.IsBossChallenge = false
        data.CrownOfKings.IsBossrush = false
        player:AnimateSad()
    end
end
CrownOfKings:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, CrownOfKings.PostTakeDamage, EntityType.ENTITY_PLAYER)

function CrownOfKings:PostPlayerRender(player)
    if player:HasCollectible(ty.CustomCollectibles.CROWNOFKINGS) then
        local data = ty:GetLibData(player)
        data.CrownOfKings.CanRender = true
    end
end
CrownOfKings:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, CrownOfKings.PostPlayerRender)

function CrownOfKings:UpdateCrownOfKingsEffect(effect)
    local effectData = ty:GetLibData(effect)
    local sprite = effect:GetSprite()
    local player = effectData.Owner
    local data = ty:GetLibData(player)
    local mask = GetCrownMask(player)
    if mask & 1 << 3 ~= 1 << 3 then
        effect:Remove()
    end
    if not data.CrownOfKings.CanRender or not player:IsExtraAnimationFinished() then
        effect.Visible = false
    else
        effect.Visible = true
    end 
    local flyOffset = Vector(0, 0)
    if player.CanFly then
        flyOffset = Vector(0, -4)
    end
    local scale = data.PlayerSize.Scale
    sprite.Scale = Vector(1, 1) * scale
    if mask & 1 << 1 == 1 << 1 and mask & 1 << 2 == 1 << 2 then
        effect.ParentOffset = Vector(0, -21) + flyOffset
    elseif (mask & 1 << 1 == 1 << 1 and mask & 1 << 2 ~= 1 << 2) or (mask & 1 << 1 ~= 1 << 1 and mask & 1 << 2 == 1 << 2) then
        effect.ParentOffset = Vector(0, -10.5) + flyOffset
    else
        effect.ParentOffset = Vector(0, 0) + flyOffset
    end
    if data.CrownOfKings.CanSpawn then
        sprite:Play("FloatGlow")
    else
        sprite:Play("FloatNoGlow")
    end
    data.CrownOfKings.CanRender = false
end
CrownOfKings:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, CrownOfKings.UpdateCrownOfKingsEffect, ty.CustomEffects.CROWNOFKINGS)

return CrownOfKings