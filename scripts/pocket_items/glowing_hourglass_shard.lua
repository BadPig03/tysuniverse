local GlowingHourglassShard = ty:DefineANewClass()

local used = false

function GlowingHourglassShard:PostUseCard(card, player, useFlags)
    used = true
    player:UseActiveItem(CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS, false)
end
GlowingHourglassShard:AddCallback(ModCallbacks.MC_USE_CARD, GlowingHourglassShard.PostUseCard, ty.CustomCards.GLOWINGHOURGLASSSHARD)

function GlowingHourglassShard:PostNewRoom()
    if used then
        for _, player in pairs(PlayerManager.GetPlayers()) do
            for i = ActiveSlot.SLOT_PRIMARY, ActiveSlot.SLOT_POCKET2 do
                local card = player:GetCard(i)
                if card == ty.CustomCards.GLOWINGHOURGLASSSHARD then
                    player:RemovePocketItem(i)
                    break
                end
            end
        end
        used = false
    end
end
GlowingHourglassShard:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, GlowingHourglassShard.PostNewRoom)

function GlowingHourglassShard:PreReviveGlowingHourglassShard(player)
    for i = ActiveSlot.SLOT_PRIMARY, ActiveSlot.SLOT_POCKET2 do
        local card = player:GetCard(i)
        if card == ty.CustomCards.GLOWINGHOURGLASSSHARD then
            player:UseCard(ty.CustomCards.GLOWINGHOURGLASSSHARD, UseFlag.USE_OWNED)
            ty.SFXMANAGER:Play(SoundEffect.SOUND_HELL_PORTAL2)
            break
        end
    end
end
GlowingHourglassShard:AddPriorityCallback("TY_PRE_PLAYER_REVIVE", 5, GlowingHourglassShard.PreReviveGlowingHourglassShard)

return GlowingHourglassShard