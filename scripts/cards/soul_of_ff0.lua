local SoulOfFF0 = ty:DefineANewClass()

local function PostUse(healthType, player, soul)
    local maxHearts = player:GetMaxHearts()
    local hearts = player:GetHearts()
    if healthType == HealthType.SOUL then
        player:AddMaxHearts(-maxHearts)
        if not soul then
            player:AddHearts(-maxHearts)    
        end
        if player:GetPlayerType() == PlayerType.PLAYER_BLACKJUDAS or player:GetPlayerType() == PlayerType.PLAYER_JUDAS_B then
            player:AddBlackHearts(maxHearts)
        else
            player:AddSoulHearts(maxHearts)
        end
    elseif healthType == HealthType.LOST then
        player:AddMaxHearts(-maxHearts)
        player:AddBoneHearts(-player:GetBoneHearts())
        player:AddSoulHearts(-player:GetSoulHearts())
        player:AddSoulHearts(1)
    elseif healthType == HealthType.BONE then
        player:AddMaxHearts(-maxHearts)
        player:AddBoneHearts(maxHearts / 2)
    end
end

function SoulOfFF0:PostUseCard(card, player, useFlags)
    local data = ty:GetLibData(player)
    local healthType = player:GetHealthType()
    if data.Warfarin.Original == -1 then
        if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
            player = player:GetOtherTwin()
        end
        data.Warfarin.Original = healthType
        player:AddMaxHearts(4)
        player:AddHearts(4)
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 3, player.Position, Vector(0, 0), nil)
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 4, player.Position, Vector(0, 0), nil)
        ty.SFXMANAGER:Play(SoundEffect.SOUND_ANGEL_BEAM, 0.6, 2, false, 1.3) 
    end
end
SoulOfFF0:AddCallback(ModCallbacks.MC_USE_CARD, SoulOfFF0.PostUseCard, ty.CustomCards.SOULOFFF0)

function SoulOfFF0:PlayerGetHealthType(player)
    local data = ty:GetLibData(player)
    if data.Warfarin and data.Warfarin.Original ~= -1 then
        return HealthType.RED
    end
end
SoulOfFF0:AddCallback(ModCallbacks.MC_PLAYER_GET_HEALTH_TYPE, SoulOfFF0.PlayerGetHealthType)

function SoulOfFF0:PostNewLevel()
    for _, player in pairs(PlayerManager.GetPlayers()) do
        local data = ty:GetLibData(player)
        if data.Warfarin.Original ~= -1 then
            if player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN then
                PostUse(HealthType.BONE, player)
                player:SwapForgottenForm(true, true)
                PostUse(HealthType.SOUL, player, true)
                player:SwapForgottenForm(true, false)
            elseif player:GetPlayerType() == PlayerType.PLAYER_THESOUL then
                player:SwapForgottenForm(true, true)
                PostUse(HealthType.BONE, player)
                player:SwapForgottenForm(true, true)
                PostUse(HealthType.SOUL, player, true)
                player:SwapForgottenForm(true, false)
            else
                PostUse(data.Warfarin.Original, player)
            end
            data.Warfarin.Original = -1    
        end
    end
end
SoulOfFF0:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, SoulOfFF0.PostNewLevel)

function SoulOfFF0:PostUpdate()
    if not PlayerManager.AnyoneIsPlayerType(PlayerType.PLAYER_BLUEBABY) then
        return
    end
    local flag = false
    for _, player in pairs(PlayerManager.GetPlayers()) do
        if player:GetPlayerType() == PlayerType.PLAYER_BLUEBABY and player:GetHealthType() == HealthType.RED then
            flag = true
            break
        end
    end
    if not flag then
        return
    end
    local flag2 = false
    for _, player in pairs(PlayerManager.GetPlayers()) do
        if player:GetPlayerType() == PlayerType.PLAYER_BLUEBABY and player:GetHealthType() == HealthType.RED and player:GetMaxHearts() > 0 then
            flag2 = true
            break
        end
    end
    for _, ent in pairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)) do
        local pickup = ent:ToPickup()
        if pickup:IsShopItem() and pickup.Price < 0 and pickup.Price ~= PickupPrice.PRICE_FREE then
            if flag2 then
                if pickup.Price == PickupPrice.PRICE_ONE_SOUL_HEART then
                    pickup.AutoUpdatePrice = false
                    pickup.Price = PickupPrice.PRICE_ONE_HEART
                elseif pickup.Price == PickupPrice.PRICE_TWO_SOUL_HEARTS then
                    pickup.AutoUpdatePrice = false
                    pickup.Price = PickupPrice.PRICE_TWO_HEARTS
                end
            elseif not pickup.AutoUpdatePrice then
                pickup.AutoUpdatePrice = true
            end    
        end
    end
end
SoulOfFF0:AddCallback(ModCallbacks.MC_POST_UPDATE, SoulOfFF0.PostUpdate)

return SoulOfFF0