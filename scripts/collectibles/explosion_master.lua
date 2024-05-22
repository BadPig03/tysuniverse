local ExplosionMaster = ty:DefineANewClass()

function ExplosionMaster:PostProjectileUpdate(projectile)
    if PlayerManager.AnyoneHasCollectible(ty.CustomCollectibles.EXPLOSIONMASTER) and projectile:GetDropRNG():RandomInt(100) < 40 and projectile.FrameCount <= 1 then
        local bomb = Isaac.Spawn(EntityType.ENTITY_BOMB, BombVariant.BOMB_SAD_BLOOD, 0, projectile.Position, projectile.Velocity * 2, nil):ToBomb()
        bomb.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
        bomb:SetExplosionCountdown(bomb:GetExplosionCountdown() * 2)
        bomb.SpriteScale = Vector(0.85, 0.85)
        bomb.RadiusMultiplier = 0.85
        bomb.ExplosionDamage = 40
        ty:GetLibData(bomb).ExplosionMaster = true
        local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, bomb.Position, Vector(0, 0), nil)
        poof.SpriteScale = projectile.SpriteScale
        projectile:Remove()
    end
end
ExplosionMaster:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, ExplosionMaster.PostProjectileUpdate)

function ExplosionMaster:PreRoomExit()
    for _, ent in pairs(Isaac.FindByType(EntityType.ENTITY_BOMB)) do
        if ent:ToBomb() and ty:GetLibData(ent).ExplosionMaster then
            ent:Remove()
        end
    end
end
ExplosionMaster:AddCallback(ModCallbacks.MC_PRE_ROOM_EXIT, ExplosionMaster.PreRoomExit)

function ExplosionMaster:PrePlayerTakeDamage(player, amount, flags, source, countdown)
	if source and source.Entity and source.Entity:ToBomb() and ty:GetLibData(source.Entity).ExplosionMaster then
        return false
    end
end
ExplosionMaster:AddCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, ExplosionMaster.PrePlayerTakeDamage)

return ExplosionMaster