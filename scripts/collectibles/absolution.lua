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

function Absolution:PostUpdate()
    if PlayerManager.AnyoneHasCollectible(ty.CustomCollectibles.ABSOLUTION) and ty.LEVEL:GetAngelRoomChance() ~= 100 then
        ty.LEVEL:AddAngelRoomChance(100 - ty.LEVEL:GetAngelRoomChance())
    end
end
Absolution:AddCallback(ModCallbacks.MC_POST_UPDATE, Absolution.PostUpdate)

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

return Absolution