local LostSoul = ty:DefineANewClass()

local stat = ty.Stat

local function HasLostSoul(player)
    return player:GetEffects():HasNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.LOSTSOUL).ID)
end

function LostSoul:EvaluateCache(player, cacheFlag)
    if HasLostSoul(player) then
        stat:MultiplyDamage(player, 0.2)
    end
end
LostSoul:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, LostSoul.EvaluateCache, CacheFlag.CACHE_DAMAGE)

function LostSoul:PrePlayerTakeDamage(player, amount, flags, source, countdown)
	if HasLostSoul(player) then
		return false
	end
end
LostSoul:AddCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, LostSoul.PrePlayerTakeDamage)

function LostSoul:PostPlayerUpdate(player)
    if HasLostSoul(player) then
        if player:GetPlayerType() ~= PlayerType.PLAYER_THELOST then
            player:ChangePlayerType(PlayerType.PLAYER_THELOST)
        elseif not player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE) then
            player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE)
        end
    end
end
LostSoul:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, LostSoul.PostPlayerUpdate)

function LostSoul:PreSlotCollision(slot, collider, low)
    local player = collider:ToPlayer()
    if player and HasLostSoul(player) then
        return { Collide = true, SkipCollisionEffects = true }
    end
end
LostSoul:AddCallback(ModCallbacks.MC_PRE_SLOT_COLLISION, LostSoul.PreSlotCollision)

function LostSoul:PrePickupCollision(pickup, collider, low)
    local player = collider:ToPlayer()
    if (pickup.Variant == PickupVariant.PICKUP_HEART or pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE) and player and HasLostSoul(player) then
        return { Collide = true, SkipCollisionEffects = true }
    end
end
LostSoul:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, LostSoul.PrePickupCollision)

return LostSoul