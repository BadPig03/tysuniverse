local Magnifier = ty:DefineANewClass()

local function FindMinHealthEnemy(position)
    local minHealth = 99999
    local minHealthEnemy = nil
    for _, ent in pairs(Isaac.FindInRadius(position, 8192, EntityPartition.ENEMY)) do
        if ty:IsValidCollider(ent) and ent.HitPoints < minHealth then
            minHealth = ent.HitPoints
            minHealthEnemy = ent
        end
    end
    return minHealthEnemy
end

function Magnifier:EvaluateCache(player, cacheFlag)
    local data = ty:GetLibData(player)
    local count = math.min(1, player:GetCollectibleNum(ty.CustomCollectibles.MAGNIFIER) + player:GetEffects():GetCollectibleEffectNum(ty.CustomCollectibles.MAGNIFIER))
    for _, familiar in pairs(player:CheckFamiliarEx(ty.CustomEntities.MAGNIFIER, count, RNG(), ty.ITEMCONFIG:GetCollectible(ty.CustomCollectibles.MAGNIFIER))) do
        local player = familiar.Player
        local familiarData = ty:GetLibData(familiar)
        familiarData.Target = player
        familiar.DepthOffset = 999
    end
end
Magnifier:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Magnifier.EvaluateCache, CacheFlag.CACHE_FAMILIARS)

function Magnifier:FamiliarUpdate(familiar)
    local player = familiar.Player
    local familiarData = ty:GetLibData(familiar)
    local target = FindMinHealthEnemy(familiar.Position)
    if target == nil then
        familiarData.Target = player
    elseif GetPtrHash(target) ~= GetPtrHash(familiarData.Target) then
        familiarData.Target = target
    end
    if familiarData.Target:ToPlayer() then
        familiar:FollowParent()
    else
        familiar:FollowPosition(familiarData.Target.Position - Vector(0, 2 * familiarData.Target.Size))
    end
end
Magnifier:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, Magnifier.FamiliarUpdate, ty.CustomEntities.MAGNIFIER)

function Magnifier:PostFamiliarRender(familiar)
    local familiarData = ty:GetLibData(familiar)
    local player = familiar.Player
    if not familiarData.Target then
        return
    end
    for _, ent in pairs(Isaac.FindInRadius(familiar.Position + Vector(0, 2 * familiarData.Target.Size), 256, EntityPartition.ENEMY)) do
        if ent:ToNPC() and ent:IsActiveEnemy() then
            local npc = ent:ToNPC()
            local npcData = ty:GetLibData(npc)
            local originScale = 1
            if npc:IsChampion() then
                originScale = 1.15
            end
            local scale = 1 + (128 - math.min((familiar.Position + Vector(0, 2 * familiarData.Target.Size) - ent.Position):Length(), 128)) / 128
            npc.Scale = originScale * scale
            npc.SizeMulti = Vector(1, 1) * originScale * math.max(1, scale ^ 0.75)
            npcData.Scale = scale
            if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
                npcData.Bffs = 1.5
            else
                npcData.Bffs = 1
            end
        end
    end
end
Magnifier:AddCallback(ModCallbacks.MC_POST_FAMILIAR_RENDER, Magnifier.PostFamiliarRender, ty.CustomEntities.MAGNIFIER)

function Magnifier:TakeDamage(entity, amount, flags, source, countdown)
    if entity:ToNPC() then
        local npcData = ty:GetLibData(entity)
        if npcData.Scale and npcData.Bffs then
            return { Damage = amount * (npcData.Scale * npcData.Bffs or 1) }
        end
    end
end
Magnifier:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Magnifier.TakeDamage)

return Magnifier