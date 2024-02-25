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

function Magnifier:PostUsePill(pillEffect, player, useFlags, pillColor)
    local data = ty:GetLibData(player)
    local giantFlag = 1
    if pillColor & PillColor.PILL_GIANT_FLAG == PillColor.PILL_GIANT_FLAG then
        giantFlag = 2
    end
    if pillEffect == PillEffect.PILLEFFECT_LARGER then
        data.PlayerSize.Larger = data.PlayerSize.Larger + giantFlag
    elseif pillEffect == PillEffect.PILLEFFECT_SMALLER then
        data.PlayerSize.Smaller = data.PlayerSize.Smaller + giantFlag
    end
end
Magnifier:AddCallback(ModCallbacks.MC_USE_PILL, Magnifier.PostUsePill)

function Magnifier:PostUseHugeGrowthCard(card, player, useFlags)
    local data = ty:GetLibData(player)
    if data.PlayerSize.HugeGrowth == 0 then
        data.PlayerSize.HugeGrowth = 1
    end
end
Magnifier:AddCallback(ModCallbacks.MC_USE_CARD, Magnifier.PostUseHugeGrowthCard, Card.CARD_HUGE_GROWTH)

function Magnifier:ResetHugeGrowthScale()
    for _, player in pairs(PlayerManager.GetPlayers()) do
        local data = ty:GetLibData(player)
        if data.Init and data.PlayerSize.HugeGrowth == 1 then
            data.PlayerSize.HugeGrowth = 0
        end    
    end
end
Magnifier:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Magnifier.ResetHugeGrowthScale)

function Magnifier:PostPlayerUpdate(player)
    local data = ty:GetLibData(player)
    if data.Init then
        local size = 1
        local effects = player:GetEffects()
        size = size * 0.5 ^ (player:GetCollectibleNum(CollectibleType.COLLECTIBLE_PLUTO) + effects:GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_INNER_CHILD))
        size = size * 0.8 ^ (player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BINKY) + player:GetCollectibleNum(CollectibleType.COLLECTIBLE_MINI_MUSH) + data.PlayerSize.Smaller)
        size = size * 1.2 ^ player:GetCollectibleNum(CollectibleType.COLLECTIBLE_LEO)
        size = size * 1.25 ^ (player:GetCollectibleNum(CollectibleType.COLLECTIBLE_MAGIC_MUSHROOM) + data.PlayerSize.Larger)
        size = size * 1.6 ^ data.PlayerSize.HugeGrowth
        data.PlayerSize.Scale = size
    end
end
Magnifier:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Magnifier.PostPlayerUpdate)

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
    familiar:FollowPosition(familiarData.Target.Position - Vector(0, 2 * familiarData.Target.Size))
end
Magnifier:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, Magnifier.FamiliarUpdate, ty.CustomEntities.MAGNIFIER)

function Magnifier:PostRender()
    local flag = false
    for _, familiar in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, ty.CustomEntities.MAGNIFIER)) do
        local familiarData = ty:GetLibData(familiar)
        if familiarData.Target then
            for _, ent in pairs(Isaac.FindInRadius(familiar.Position + Vector(0, 2 * familiarData.Target.Size), 256, EntityPartition.ENEMY | EntityPartition.PLAYER)) do
                if ent:ToNPC() and ty:IsValidCollider(ent) then
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
                end
                if ent:ToPlayer() then
                    local player = ent:ToPlayer()
                    local playerData = ty:GetLibData(player)
                    local originScale = playerData.PlayerSize.Scale
                    local scale = 1 + (128 - math.min((familiar.Position + Vector(0, 2 * familiarData.Target.Size) - ent.Position):Length(), 128)) / 256
                    player.SpriteScale = Vector(1, 1) * originScale * scale
                    player.SizeMulti = Vector(1, 1) * originScale * math.max(1, scale ^ 0.95)
                    playerData.Magnifier.Scale = scale
                end
            end
        end
        flag = true
    end
    if not flag then
        for _, player in pairs(PlayerManager.GetPlayers()) do
            local data = ty:GetLibData(player)
            if data.Init and data.Magnifier.Scale ~= 1 then
                local originScale = data.PlayerSize.Scale
                player.SpriteScale = Vector(1, 1) * originScale
                player.SizeMulti = Vector(1, 1) * originScale
                data.Magnifier.Scale = 1
            end
        end
    end
end
Magnifier:AddCallback(ModCallbacks.MC_POST_RENDER, Magnifier.PostRender)

function Magnifier:TakeDamage(entity, amount, flags, source, countdown)
    if entity:ToNPC() then
        local npc = entity:ToNPC()
        local npcData = ty:GetLibData(npc)
        return { Damage = amount * (npcData.Scale or 1) }
    end
end
Magnifier:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Magnifier.TakeDamage)

return Magnifier