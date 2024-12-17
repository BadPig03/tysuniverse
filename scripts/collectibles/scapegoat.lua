local Scapegoat = ty:DefineANewClass()

ty.Revive:SetReviveConfig("TY_SCAPEGOAT_REVIVE", { BeforeVanilla = true })

function Scapegoat:PostReviveScapegoat(player, configKey, reviver)
    local removed = false
    if player:HasCollectible(ty.CustomCollectibles.SCAPEGOAT) then
        player:RemoveCollectible(ty.CustomCollectibles.SCAPEGOAT)
        player:AnimateCollectible(ty.CustomCollectibles.SCAPEGOAT, "UseItem")
        removed = true
    end
    if player:GetPlayerType() ~= PlayerType.PLAYER_AZAZEL and player:GetPlayerType() ~= PlayerType.PLAYER_AZAZEL_B and player:GetPlayerType() ~= PlayerType.PLAYER_ESAU then
        player:ChangePlayerType(PlayerType.PLAYER_AZAZEL)
        player:AddBlackHearts(2)
    elseif player:GetPlayerType() == PlayerType.PLAYER_AZAZEL_B then
        player:QueueItem(ty.ITEMCONFIG:GetCollectible(CollectibleType.COLLECTIBLE_LORD_OF_THE_PIT))
    elseif player:GetPlayerType() == PlayerType.PLAYER_ESAU then
        local player2 = player:GetOtherTwin()
        if player2 and player2:GetPlayerType() == PlayerType.PLAYER_JACOB then
            if not removed then
                player2:RemoveCollectible(ty.CustomCollectibles.SCAPEGOAT)
                player2:AnimateCollectible(ty.CustomCollectibles.SCAPEGOAT, "UseItem")    
            end
            player2:ChangePlayerType(PlayerType.PLAYER_AZAZEL)
            player2:AddBlackHearts(2)
        else
            player:ChangePlayerType(PlayerType.PLAYER_AZAZEL)
            player:AddBlackHearts(2)
        end
    end
    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 3, player.Position, Vector(0, 0), nil)
    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 4, player.Position, Vector(0, 0), nil)
    ty.SFXMANAGER:Play(SoundEffect.SOUND_UNHOLY, 0.6)
    ty.SFXMANAGER:Play(SoundEffect.SOUND_FLASHBACK, 0.6)
end
Scapegoat:AddCallback("TY_POST_PLAYER_REVIVE", Scapegoat.PostReviveScapegoat, "TY_SCAPEGOAT_REVIVE")

function Scapegoat:PreReviveScapegoat(player)
    if not (player:GetCard(ActiveSlot.SLOT_PRIMARY) == Card.CARD_SOUL_LAZARUS or player:GetCard(ActiveSlot.SLOT_SECONDARY) == Card.CARD_SOUL_LAZARUS) and player:HasCollectible(ty.CustomCollectibles.SCAPEGOAT) then
        return "TY_SCAPEGOAT_REVIVE"
    end
end
Scapegoat:AddPriorityCallback("TY_PRE_PLAYER_REVIVE", 10, Scapegoat.PreReviveScapegoat)

return Scapegoat