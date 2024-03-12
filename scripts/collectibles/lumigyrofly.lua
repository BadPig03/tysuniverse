local Lumigyrofly = ty:DefineANewClass()

local function GetLumigyroflyCount()
    local count = 0
    for _, familiar in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, ty.CustomEntities.LUMIGYROFLY)) do
        count = count + 1
    end
    return count
end

local function GetRotationListInit(count)
    local maxCount = math.max(5, 360 / count)
    local currentCount = 1
    local list = {}
    for i = currentCount, count do
        list[currentCount] = 360 - 360 / count * currentCount
        currentCount = currentCount + 1
    end
    return list
end

local function IsPlayerDying(player)
    local effects = player:GetEffects()
    local function GetLowestHealth(player)
        if ty.LEVEL:GetAbsoluteStage() <= LevelStage.STAGE3_2 or effects:GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_WAFER) > 0 or player:HasCollectible(CollectibleType.COLLECTIBLE_WAFER) then
            return 1
        end
        return 2
    end
	if player:GetPlayerType() == PlayerType.PLAYER_THELOST or player:GetPlayerType() == PlayerType.PLAYER_THELOST_B then
        if effects:GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_HOLY_MANTLE) == 0 and not player:HasInvincibility() then
            return true
        end
    else
        if player:GetHearts() + player:GetBoneHearts() + player:GetSoulHearts() + player:GetEternalHearts() <= GetLowestHealth(player) and not player:HasInvincibility() and effects:GetCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE) == nil then
            return true
        end
    end
    return false
end

local function GetNearestEnemy(position)
	local distance = 192
    local nearestEnemy = nil
    for _, ent in pairs(Isaac.FindInRadius(position, 192, EntityPartition.ENEMY)) do
        if ty:IsValidCollider(ent) and (ent.Position - position):Length() < distance then
            distance = (ent.Position - position):Length()
            nearestEnemy = ent
        end
    end
    return nearestEnemy
end

function Lumigyrofly:EvaluateCache(player, cacheFlag)
    local data = ty:GetLibData(player)
    local count = player:GetCollectibleNum(ty.CustomCollectibles.LUMIGYROFLY) + player:GetEffects():GetCollectibleEffectNum(ty.CustomCollectibles.LUMIGYROFLY)
    if count == 0 then
        count = -2
    end
    for _, familiar in pairs(player:CheckFamiliarEx(ty.CustomEntities.LUMIGYROFLY, count + 2, RNG(), ty.ITEMCONFIG:GetCollectible(ty.CustomCollectibles.LUMIGYROFLY))) do
        local player = familiar.Player
        local sprite = familiar:GetSprite()
        local data = ty:GetLibData(player)
        local familiarData = ty:GetLibData(familiar)
        familiarData.Init = true
        familiarData.Target = player
        sprite:Play("Appear", true)
        familiar.DepthOffset = -1
    end
end
Lumigyrofly:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Lumigyrofly.EvaluateCache, CacheFlag.CACHE_FAMILIARS)

function Lumigyrofly:PostPlayerUpdate(player)
    local data = ty:GetLibData(player)
    if player:HasCollectible(ty.CustomCollectibles.LUMIGYROFLY) and GetLumigyroflyCount() > 0 then
        if IsPlayerDying(player) then
            data.LumigyroFly.InProtect = true
            data.LumigyroFly.Target = player
        else
            data.LumigyroFly.InProtect = false
            if data.LumigyroFly.Target == nil or data.LumigyroFly.Target:IsDead() or not data.LumigyroFly.Target:IsVulnerableEnemy() or data.LumigyroFly.Target:ToPlayer() then
                local tempTarget = GetNearestEnemy((data.LumigyroFly.Target and data.LumigyroFly.Target.Position) or player.Position)
                if tempTarget == nil then
                    data.LumigyroFly.Target = player
                    data.LumigyroFly.DepthOffset = -1     
                elseif tempTarget and data.LumigyroFly.Target and GetPtrHash(tempTarget) ~= GetPtrHash(data.LumigyroFly.Target) then
                    data.LumigyroFly.Target = tempTarget
                    data.LumigyroFly.DepthOffset = 998
                end
            end
        end
        if data.LumigyroFly.Count ~= GetLumigyroflyCount() then
            data.LumigyroFly.Count = GetLumigyroflyCount()
            data.LumigyroFly.RotationList = GetRotationListInit(data.LumigyroFly.Count)
        end
        for i = 1, #data.LumigyroFly.RotationList do
            local rotationAngleDelta = 2
            if data.LumigyroFly.InProtect then
                rotationAngleDelta = 8
            end
            data.LumigyroFly.RotationList[i] = data.LumigyroFly.RotationList[i] + rotationAngleDelta
            if data.LumigyroFly.RotationList[i] > 360 then
                data.LumigyroFly.RotationList[i] = data.LumigyroFly.RotationList[i] - 360
            end
        end
        if data.LumigyroFly.Target then
            local currentCount = 1
            for _, ent in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, ty.CustomEntities.LUMIGYROFLY)) do
                local familiar = ent:ToFamiliar()
                local degree = math.pi * data.LumigyroFly.RotationList[currentCount] / 180
                local size = data.LumigyroFly.Target.Size
                if data.LumigyroFly.Target:ToPlayer() then
                    size = size * 1.8
                end
                if data.LumigyroFly.InProtect then
                    local targetPosition = data.LumigyroFly.Target.Position + size * Vector(math.sin(degree), math.cos(degree))
                    familiar:FollowPosition(targetPosition)
                    if (targetPosition - familiar.Position):Length() > size * 1.2 then
                        familiar:AddVelocity((targetPosition - familiar.Position):Normalized():Resized(1))
                    else
                        familiar.Velocity = targetPosition - familiar.Position
                    end
                else
                    local targetPosition = data.LumigyroFly.Target.Position + size * Vector(math.sin(degree), math.cos(degree))
                    familiar:FollowPosition(targetPosition)
                    if (targetPosition - familiar.Position):Length() > size then
                        familiar:AddVelocity((targetPosition - familiar.Position):Normalized():Resized(3))
                    else
                        familiar.Velocity = targetPosition - familiar.Position
                    end    
                end
                currentCount = currentCount + 1
            end
        end
    end
end
Lumigyrofly:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Lumigyrofly.PostPlayerUpdate)

function Lumigyrofly:FamiliarUpdate(familiar)
    local sprite = familiar:GetSprite()
    local player = familiar.Player
    local playerData = ty:GetLibData(player)
    if familiar.DepthOffset ~= playerData.LumigyroFly.DepthOffset then
        familiar.DepthOffset = playerData.LumigyroFly.DepthOffset
    end
    if sprite:IsFinished("Appear") then
        sprite:Play("FlyAroundPlayer", true)
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_HIVE_MIND) and not player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
        sprite.Scale = Vector(1.25, 1.25)
    end
end
Lumigyrofly:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, Lumigyrofly.FamiliarUpdate, ty.CustomEntities.LUMIGYROFLY)

function Lumigyrofly:PreFamiliarCollision(familiar, collider, low)
    local player = familiar.Player
    local data = ty:GetLibData(player)
    if collider:IsEnemy() then
        if collider.Type == EntityType.ENTITY_ARMYFLY or collider.Type == EntityType.ENTITY_FLY or collider.Type == EntityType.ENTITY_ATTACKFLY or collider.Type == EntityType.ENTITY_RING_OF_FLIES or collider.Type == EntityType.ENTITY_SWARM or collider.Type == EntityType.ENTITY_WILLO then
            collider:Die()
            return nil
        end
        local damage = 3
        if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) or player:HasCollectible(CollectibleType.COLLECTIBLE_HIVE_MIND) then
            damage = damage * 2
        end
        if ty.GAME:GetFrameCount() % 6 == 0 then
            collider:TakeDamage(damage, 0, EntityRef(familiar), 0)
        end
        return nil
    end
    if data.LumigyroFly.InProtect and collider.Type == EntityType.ENTITY_PROJECTILE then
        collider:Die()
    end
end
Lumigyrofly:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, Lumigyrofly.PreFamiliarCollision, ty.CustomEntities.LUMIGYROFLY)

return Lumigyrofly