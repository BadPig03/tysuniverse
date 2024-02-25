local HadesBlade = ty:DefineANewClass()

local function GetDevilFamiliarCollectible(rng)
	for itemID = 1, ty.ITEMCONFIG:GetCollectibles().Size - 1 do
		if ItemConfig.Config.IsValidCollectible(itemID) and ty.ITEMCONFIG:GetCollectible(itemID).Type ~= ItemType.ITEM_FAMILIAR then
			ty.ITEMPOOL:AddRoomBlacklist(itemID)
		end
	end
	local itemID = ty.ITEMPOOL:GetCollectible(ItemPoolType.POOL_DEVIL, false, rng:Next(), CollectibleType.COLLECTIBLE_DEMON_BABY)
    ty.ITEMPOOL:RemoveCollectible(itemID)
    ty.ITEMPOOL:ResetRoomBlacklist()
    return itemID
end

local function GetADevilFamiliar(player, rng)
    local data = ty:GetLibData(player)
    data.HadesBlade.Count = data.HadesBlade.Count + 1
    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 0, player.Position, Vector(0, 0), nil)
    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.LARGE_BLOOD_EXPLOSION, 0, player.Position, Vector(0, 0), nil)
    player:TakeDamage(0, DamageFlag.DAMAGE_FAKE | DamageFlag.DAMAGE_SPIKES | DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_INVINCIBLE, EntityRef(player), 30)
    ty.SFXMANAGER:Play(SoundEffect.SOUND_POWERUP1 + rng:RandomInt(2), 0.6)
    local item = GetDevilFamiliarCollectible(rng)
    local itemConfigCollectible = ty.ITEMCONFIG:GetCollectible(item)
    player:AnimateCollectible(item)
    player:QueueItem(itemConfigCollectible)
    ty.HUD:ShowItemText(player, itemConfigCollectible)
    ty.SFXMANAGER:Play(SoundEffect.SOUND_MEATY_DEATHS)
end

function HadesBlade:EvaluateCache(player, cacheFlag)
	local data = ty:GetLibData(player)
	if data.Init and player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL_PASSIVE) then
		ty.Stat:AddFlatDamage(player, 0.2 * data.HadesBlade.Count)
	end
end
HadesBlade:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, HadesBlade.EvaluateCache, CacheFlag.CACHE_DAMAGE)

function HadesBlade:UseItem(itemID, rng, player, useFlags, activeSlot, varData)
    if useFlags & UseFlag.USE_CARBATTERY == UseFlag.USE_CARBATTERY then
        return { Discharge = false, Remove = false, ShowAnim = false }
    end
    if player:GetPlayerType() == PlayerType.PLAYER_THELOST or player:GetPlayerType() == PlayerType.PLAYER_THELOST_B then
        GetADevilFamiliar(player, rng)
        return { Discharge = true, Remove = true, ShowAnim = false }
    elseif player:GetPlayerType() == PlayerType.PLAYER_BLUEBABY or player:GetPlayerType() == PlayerType.PLAYER_BLACKJUDAS or player:GetPlayerType() == PlayerType.PLAYER_BLUEBABY_B or player:GetPlayerType() == PlayerType.PLAYER_BETHANY_B or player:GetPlayerType() == PlayerType.PLAYER_THESOUL or player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B or player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN_B then
        if player:GetBoneHearts() > 0 then
            player:AddBoneHearts(-1)
            GetADevilFamiliar(player, rng)
            return { Discharge = true, Remove = false, ShowAnim = false }
        elseif player:GetSoulHearts() > 0 then
            player:AddSoulHearts(-4)
            GetADevilFamiliar(player, rng)
            return { Discharge = true, Remove = false, ShowAnim = false }
        end
    elseif player:GetPlayerType() == PlayerType.PLAYER_KEEPER or player:GetPlayerType() == PlayerType.PLAYER_KEEPER_B then
        if player:GetNumCoins() >= 20 then
            player:AddCoins(-20)
            GetADevilFamiliar(player, rng)
            return { Discharge = true, Remove = false, ShowAnim = false }
        end
    elseif player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN then
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