local Absolution = ty:DefineANewClass()

local selfDamageFlags = {
    ['Kamikaze'] = DamageFlag.DAMAGE_EXPLOSION | DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_IGNORE_ARMOR,
    ['BloodRights'] = DamageFlag.DAMAGE_RED_HEARTS | DamageFlag.DAMAGE_INVINCIBLE,
    ['IVBag'] = DamageFlag.DAMAGE_RED_HEARTS | DamageFlag.DAMAGE_INVINCIBLE | DamageFlag.DAMAGE_IV_BAG,
    ['SharpPlug'] = DamageFlag.DAMAGE_NOKILL | DamageFlag.DAMAGE_RED_HEARTS | DamageFlag.DAMAGE_ISSAC_HEART | DamageFlag.DAMAGE_INVINCIBLE | DamageFlag.DAMAGE_IV_BAG | DamageFlag.DAMAGE_NO_MODIFIERS,
    ['BreathOfLife'] = DamageFlag.DAMAGE_INVINCIBLE | DamageFlag.DAMAGE_NO_PENALTIES,
    ['APoundOfFlesh'] = DamageFlag.DAMAGE_SPIKES | DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_INVINCIBLE,
    ['DullRazor'] = DamageFlag.DAMAGE_RED_HEARTS | DamageFlag.DAMAGE_FAKE,
    ['BloodBombs'] = DamageFlag.DAMAGE_RED_HEARTS | DamageFlag.DAMAGE_ISSAC_HEART | DamageFlag.DAMAGE_INVINCIBLE | DamageFlag.DAMAGE_IV_BAG,
    ['Confessional'] = DamageFlag.DAMAGE_RED_HEARTS,
    ['DemonBeggar'] = DamageFlag.DAMAGE_RED_HEARTS,
    ['BloodDonationMachine'] = DamageFlag.DAMAGE_RED_HEARTS,
    ['HellGame'] = DamageFlag.DAMAGE_RED_HEARTS,
    ['CurseRoom'] = DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_CURSED_DOOR,
    ['MausoleumDoor'] = DamageFlag.DAMAGE_SPIKES | DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_INVINCIBLE | DamageFlag.DAMAGE_NO_MODIFIERS,
    ['SacrificeRoom'] = DamageFlag.DAMAGE_SPIKES | DamageFlag.DAMAGE_NO_PENALTIES,
    ['BloodSacrifice'] = DamageFlag.DAMAGE_FAKE | DamageFlag.DAMAGE_SPIKES | DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_INVINCIBLE
}

local function IsDamageSelfDamage(damageFlags)
	for _, flags in pairs(selfDamageFlags) do
		if damageFlags & flags == flags then
			return true
		end
	end
	return false
end

function Absolution:AddAngelRoomChance()
    if PlayerManager.AnyoneHasCollectible(ty.CustomCollectibles.ABSOLUTION) and not PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_DUALITY) and ty.LEVEL:GetAngelRoomChance() ~= 100 then
        ty.LEVEL:AddAngelRoomChance(100 - ty.LEVEL:GetAngelRoomChance())
    end
end
Absolution:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Absolution.AddAngelRoomChance)
Absolution:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, Absolution.AddAngelRoomChance, ty.CustomCollectibles.ABSOLUTION)

function Absolution:PostTriggerCollectibleRemoved()
    if not PlayerManager.AnyoneHasCollectible(ty.CustomCollectibles.ABSOLUTION) and ty.LEVEL:GetAngelRoomChance() == 100 then
        ty.LEVEL:AddAngelRoomChance(-100)
    end
end
Absolution:AddCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_REMOVED, Absolution.PostTriggerCollectibleRemoved, ty.CustomCollectibles.ABSOLUTION)

function Absolution:PostPickupUpdate(pickup)
    local room = ty.GAME:GetRoom()
    local pickup = pickup:ToPickup()
    if PlayerManager.AnyoneHasCollectible(ty.CustomCollectibles.ABSOLUTION) and room:GetType() == RoomType.ROOM_ANGEL and pickup.OptionsPickupIndex ~= 0 then
        pickup.OptionsPickupIndex = 0
    end
end
Absolution:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, Absolution.PostPickupUpdate, PickupVariant.PICKUP_COLLECTIBLE)

function Absolution:EntityTakeDamage(entity, amount, flags, source, countdown)
    local player = entity:ToPlayer()
    if player and player:HasCollectible(ty.CustomCollectibles.ABSOLUTION) then
        if IsDamageSelfDamage(flags) then
            return { Damage = math.max(1, math.floor(amount / 2)) }
        else
            return { DamageFlags = flags | DamageFlag.DAMAGE_NO_PENALTIES }
        end
    end
end
Absolution:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Absolution.EntityTakeDamage, EntityType.ENTITY_PLAYER)

function Absolution:FamiliarUpdate(familiar)
    local familiar = familiar:ToFamiliar()
    local player = familiar.Player
    if player:HasCollectible(ty.CustomCollectibles.ABSOLUTION) and player:HasCollectible(CollectibleType.COLLECTIBLE_DAMOCLES_PASSIVE) and familiar.State == 2 and not player:HasInvincibility() then
        player:UseActiveItem(CollectibleType.COLLECTIBLE_UNICORN_STUMP)
    end
end
Absolution:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, Absolution.FamiliarUpdate, FamiliarVariant.DAMOCLES)

function Absolution:PreDevilApplyItems()
    if PlayerManager.AnyoneHasCollectible(ty.CustomCollectibles.ABSOLUTION) then
        return 0.2
    end
end
Absolution:AddCallback(ModCallbacks.MC_PRE_DEVIL_APPLY_ITEMS, Absolution.PreDevilApplyItems)

return Absolution