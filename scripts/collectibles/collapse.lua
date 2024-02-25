local Collapse = ty:DefineANewClass()

function Collapse:PostPlayerUpdate(player)
    local data = ty:GetLibData(player)
    if data.Init and player:HasCollectible(ty.CustomCollectibles.COLLAPSE) then
        for _, entity in pairs(Isaac.FindInRadius(player.Position, ty.ConstantValues.COLLAPSERANGE, EntityPartition.BULLET | EntityPartition.TEAR | EntityPartition.ENEMY | EntityPartition.PICKUP)) do
            local velocityModifier = (ty.ConstantValues.COLLAPSERANGE - (player.Position - entity.Position):Length()) / ty.ConstantValues.COLLAPSERANGE
            if entity:ToKnife() then
                velocityModifier = 0
            elseif entity:ToProjectile() then
                velocityModifier = velocityModifier * 0.08
            elseif entity:ToTear() then
                local entityData = ty:GetLibData(entity)
                local tear = entity:ToTear()
                tear:AddTearFlags(TearFlags.TEAR_ACCELERATE | TearFlags.TEAR_MAGNETIZE)
                velocityModifier = velocityModifier * 4
                if entityData.IsCollapseColored == nil then
                    tear:GetSprite().Color:SetColorize(0.3, 0.3, 0.3, 1, 0, 0, 0)
                    entityData.IsCollapseColored = true
                end
            elseif entity:ToPickup() then
                local pickup = entity:ToPickup()
                if pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE or pickup.Variant == PickupVariant.PICKUP_BIGCHEST or pickup.Variant >= PickupVariant.PICKUP_TROPHY or pickup:IsShopItem() then
                    velocityModifier = 0
                else
                	velocityModifier = velocityModifier * 0.3
                end
			elseif entity:ToBomb() then
                velocityModifier = velocityModifier * 0.3
            elseif entity:ToNPC() then
                local npc = entity:ToNPC()
                if npc:IsActiveEnemy() and npc.Mass ~= 100 then
                    velocityModifier = velocityModifier * 0.5
                else
                    velocityModifier = 0
                end
            elseif entity:ToSlot() then
                velocityModifier = 0
            end
            entity:AddVelocity((player.Position - entity.Position):Normalized():Resized(velocityModifier))
        end
    end
    for _, entity in pairs(Isaac.FindInRadius(player.Position, 8192, EntityPartition.ENEMY)) do
        if entity:HasEntityFlags(EntityFlag.FLAG_MAGNETIZED) then
            entity:TakeDamage(10 + 2.5 * player.Damage, DamageFlag.DAMAGE_COUNTDOWN, EntityRef(player), 15)
        end
    end
end
Collapse:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Collapse.PostPlayerUpdate)

function Collapse:PrePlayerTakeDamage(player, amount, flags, source, countdown)
    if player:HasCollectible(ty.CustomCollectibles.COLLAPSE) and not (source.Type == EntityType.ENTITY_FIREPLACE and source.Variant == 4) and ((source.Entity and source.Entity:ToNPC()) or flags & DamageFlag.DAMAGE_LASER == DamageFlag.DAMAGE_LASER) then
        return false
    end
end
Collapse:AddCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, Collapse.PrePlayerTakeDamage)

return Collapse