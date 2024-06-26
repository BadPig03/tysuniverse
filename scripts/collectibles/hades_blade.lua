local HadesBlade = ty:DefineANewClass()

local stat = ty.Stat
local functions = ty.Functions

local function IsInventoryFull(player)
    if player:GetPlayerType() == PlayerType.PLAYER_ISAAC_B then
        local count = 0
        local limit = 8
        for itemID, itemCount in pairs(player:GetCollectiblesList()) do
            if ItemConfig.Config.IsValidCollectible(itemID) and not ty.ITEMCONFIG:GetCollectible(itemID):HasTags(ItemConfig.TAG_QUEST) and ty.ITEMCONFIG:GetCollectible(itemID).Type ~= ItemType.ITEM_ACTIVE and itemID ~= CollectibleType.COLLECTIBLE_BIRTHRIGHT then
                count = count + itemCount
            end
        end
        if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
            limit = 12
        end
        return count >= limit
    else
        return false
    end
end

local function GetADevilFamiliar(player, rng)
    local data = ty:GetLibData(player)
    data.HadesBlade.Count = data.HadesBlade.Count + 1
    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 0, player.Position, Vector(0, 0), nil)
    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.LARGE_BLOOD_EXPLOSION, 0, player.Position, Vector(0, 0), nil)
    player:TakeDamage(0, DamageFlag.DAMAGE_FAKE | DamageFlag.DAMAGE_SPIKES | DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_INVINCIBLE, EntityRef(player), 30)
    ty.SFXMANAGER:Play(SoundEffect.SOUND_POWERUP1 + rng:RandomInt(2), 0.6)
    local item = functions:GetFamiliarsFromItemPool(ItemPoolType.POOL_DEVIL, CollectibleType.COLLECTIBLE_DEMON_BABY, rng)
    local itemConfigCollectible = ty.ITEMCONFIG:GetCollectible(item)
    if IsInventoryFull(player) then
        local item = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, item, ty.GAME:GetRoom():FindFreePickupSpawnPosition(player.Position, 0, true), Vector(0, 0), nil):ToPickup()
        item.ShopItemId = -2
        item.Price = 0
        item:RemoveCollectibleCycle()
    else
        player:AnimateCollectible(item)
        player:QueueItem(itemConfigCollectible)    
    end
    ty.HUD:ShowItemText(player, itemConfigCollectible)
    ty.SFXMANAGER:Play(SoundEffect.SOUND_MEATY_DEATHS)
end

function HadesBlade:EvaluateCache(player, cacheFlag)
	local data = ty:GetLibData(player)
	if data.Init and player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL_PASSIVE) then
		stat:AddFlatDamage(player, 0.2 * data.HadesBlade.Count)
	end
end
HadesBlade:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, HadesBlade.EvaluateCache, CacheFlag.CACHE_DAMAGE)

function HadesBlade:UseItem(itemID, rng, player, useFlags, activeSlot, varData)
    if useFlags & UseFlag.USE_CARBATTERY == UseFlag.USE_CARBATTERY then
        return { Discharge = false, Remove = false, ShowAnim = false }
    end
    if player:GetHealthType() == HealthType.LOST then
        GetADevilFamiliar(player, rng)
        return { Discharge = true, Remove = true, ShowAnim = false }
    elseif player:GetHealthType() == HealthType.SOUL then
        if player:GetBoneHearts() > 0 then
            player:AddBoneHearts(-1)
            GetADevilFamiliar(player, rng)
            return { Discharge = true, Remove = false, ShowAnim = false }
        elseif player:GetSoulHearts() > 0 then
            player:AddSoulHearts(-4)
            GetADevilFamiliar(player, rng)
            return { Discharge = true, Remove = false, ShowAnim = false }
        end
    elseif player:GetHealthType() == HealthType.COIN then
        if player:GetNumCoins() >= 20 then
            player:AddCoins(-20)
            GetADevilFamiliar(player, rng)
            return { Discharge = true, Remove = false, ShowAnim = false }
        end
    elseif player:GetHealthType() == HealthType.BONE then
        player:AddBoneHearts(-1)
        GetADevilFamiliar(player, rng)
        return { Discharge = true, Remove = false, ShowAnim = false }
    else
        if player:GetBoneHearts() > 0 then
            player:AddBoneHearts(-1)
            GetADevilFamiliar(player, rng)
            return { Discharge = true, Remove = false, ShowAnim = false }
        elseif player:GetMaxHearts() > 0 then
            player:AddMaxHearts(-2)
            GetADevilFamiliar(player, rng)
            return { Discharge = true, Remove = false, ShowAnim = false }
        end
    end
    return { Discharge = false, Remove = false, ShowAnim = true }
end
HadesBlade:AddCallback(ModCallbacks.MC_USE_ITEM, HadesBlade.UseItem, ty.CustomCollectibles.HADESBLADE)

return HadesBlade