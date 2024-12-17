local CancerCells = ty:DefineANewClass()

local stat = ty.Stat

local count = 0
local blocked = false

local function RemoveCancerCells(player, count, block)
    if block then
        blocked = true
    end
    for i = 1, count do
        player:RemoveCollectible(ty.CustomCollectibles.CANCERCELLS)
    end
    if block then
        blocked = false
        ty.SFXMANAGER:Play(SoundEffect.SOUND_BAND_AID_PICK_UP, 0.6)
    end
end

function CancerCells:EvaluateCache(player, cacheFlag)
    local num = player:GetCollectibleNum(ty.CustomCollectibles.CANCERCELLS)
    if num > 0 then
        stat:AddDamageUp(player, 0.5 * num)
    end
end
CancerCells:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, CancerCells.EvaluateCache, CacheFlag.CACHE_DAMAGE)

function CancerCells:PostTriggerCollectibleRemoved(player, type)
    if not blocked then
        count = count + 1
        Isaac.CreateTimer(function()
            player:ResetDamageCooldown()
            local damageFlags = DamageFlag.DAMAGE_INVINCIBLE | DamageFlag.DAMAGE_NO_PENALTIES
            if player:GetHealthType() == HealthType.LOST then
                damageFlags = damageFlags | DamageFlag.DAMAGE_RED_HEARTS
            end
            player:TakeDamage(count * 2, damageFlags, EntityRef(player), 30)
            for i = 0, 1 do
                player:AddCollectible(ty.CustomCollectibles.CANCERCELLS)
            end
            count = 0
        end, 1, 0, false)
    end
end
CancerCells:AddCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_REMOVED, CancerCells.PostTriggerCollectibleRemoved, ty.CustomCollectibles.CANCERCELLS)

function CancerCells:PostAddCollectible(type, charge, firstTime, slot, varData, player)
    local num = player:GetCollectibleNum(ty.CustomCollectibles.CANCERCELLS)
    if num > 0 then
        if ty.ITEMCONFIG:GetCollectible(type):HasTags(ItemConfig.TAG_SYRINGE) then
            RemoveCancerCells(player, math.ceil(num / 2), true)
        end
    end
end
CancerCells:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, CancerCells.PostAddCollectible)

function CancerCells:UsePill(pillEffect, player, useFlags, pillColor)
    local num = player:GetCollectibleNum(ty.CustomCollectibles.CANCERCELLS)
    if num > 0 and pillColor ~= PillColor.PILL_NULL then
        local rng = player:GetCollectibleRNG(ty.CustomCollectibles.CANCERCELLS)
        local pillConfig = ty.ITEMCONFIG:GetPillEffect(pillEffect)
		if pillConfig.EffectSubClass == 1 and rng:RandomInt(100) < 5 then
            RemoveCancerCells(player, 1, true)
		end
    end
end
CancerCells:AddCallback(ModCallbacks.MC_USE_PILL, CancerCells.UsePill)

function CancerCells:UseItem(id, rng, player, useFlags, activeSlot, varData)
    local num = player:GetCollectibleNum(ty.CustomCollectibles.CANCERCELLS)
    if num > 0 then
        if id == CollectibleType.COLLECTIBLE_D4 then
            RemoveCancerCells(player, num)
        elseif id == CollectibleType.COLLECTIBLE_GENESIS then
            RemoveCancerCells(player, num, true)
        end
    end
end
CancerCells:AddCallback(ModCallbacks.MC_USE_ITEM, CancerCells.UseItem)

return CancerCells