local Revive = ty:DefineANewClass()

local function IsOnlyRedHeartPlayer(playerType)
    local OnlyRedHeartPlayers = {
        [PlayerType.PLAYER_KEEPER] = true,
        [PlayerType.PLAYER_BETHANY] = true,
        [PlayerType.PLAYER_KEEPER_B] = true,
        [ty.CustomPlayerType.WARFARIN] = true
    }
    return OnlyRedHeartPlayers[playerType] ~= nil
end

local function AddRawSoulHearts(player, value)
    if player:HasCollectible(CollectibleType.COLLECTIBLE_ALABASTER_BOX, true) then
        local alabasterCharges = {}
        for slot = ActiveSlot.SLOT_PRIMARY, ActiveSlot.SLOT_POCKET do   
            if player:GetActiveItem(slot) == CollectibleType.COLLECTIBLE_ALABASTER_BOX then
                alabasterCharges[slot] = player:GetActiveCharge(slot) + player:GetBatteryCharge(slot)
                if value > 0 then
                    player:SetActiveCharge(12, slot)
                else
                    player:SetActiveCharge(0, slot)
                end
            end
        end
        player:AddSoulHearts(value)
        for slot = ActiveSlot.SLOT_PRIMARY, ActiveSlot.SLOT_POCKET do   
            if player:GetActiveItem(slot) == CollectibleType.COLLECTIBLE_ALABASTER_BOX then
                player:SetActiveCharge(alabasterCharges[slot], slot)
            end
        end
    else
        player:AddSoulHearts(value)
    end
end

function Revive:IsReviving(player)
    local data = ty:GetLibData(player)
    return data.ReviveTable.IsDead
end

function Revive:GetVanillaReviveAnimation(player)
    local playerType = player:GetPlayerType()
    if playerType == PlayerType.PLAYER_THELOST or playerType == PlayerType.PLAYER_THELOST_B or playerType == PlayerType.PLAYER_THESOUL or playerType == PlayerType.PLAYER_THESOUL_B then
        return "LostDeath"
    end
    if player:GetEffects():HasNullEffect(NullItemID.ID_LOST_CURSE) then
        return "LostDeath"
    end
    return "Death"
end

function Revive:GetPlayerReviveFrame(player)
    if Revive:GetVanillaReviveAnimation(player) == "LostDeath" then
        return 37
    end
    return 56
end

do
    local function CanSinglePlayerRevive(player, result)
        return result.BeforeVanilla or not player:WillPlayerRevive()
    end
    local function CanResultRevive(player, result)
        local playerType = player:GetPlayerType()
        local reviver = player
        if CanSinglePlayerRevive(player, result) then
            return true, player
        elseif result.CanBorrowLife then
            if playerType == PlayerType.PLAYER_JACOB or playerType == PlayerType.PLAYER_ESAU then
                local twin = player:GetOtherTwin()
                if twin and CanSinglePlayerRevive(twin, result) then
                    return true, twin
                end
            end
        end
        return false, nil
    end
    function Revive:CanPlayerRevive(player)
        local canRevive = false
        local info = nil
        local resultReviver = nil
        local callbacks = Isaac.GetCallbacks("TY_PRE_PLAYER_REVIVE")
        for _, callback in pairs(callbacks) do
            local result = callback.Function(callback.Mod, player)
            if result and type(result) == "table" then
                if result.CanBorrowLife == nil then 
                    result.CanBorrowLife = true
                end
                if result.BeforeVanilla == nil then
                    result.BeforeVanilla = false
                end
                local can, reviver = CanResultRevive(player, result)
                if can then
                    canRevive = can
                    info = result
                    resultReviver = reviver
                    break
                end
            end
        end
        return { CanRevive = canRevive, Info = info, Reviver = resultReviver }
    end
end

local function RevivePlayer(player)
    local data = ty:GetLibData(player).ReviveTable
    local playerType = player:GetPlayerType()
    local maxHearts = player:GetMaxHearts()
    local hearts = player:GetHearts()
    if playerType == PlayerType.PLAYER_THEFORGOTTEN_B and player.EntityCollisionClass == 0 then
        player.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
    end
    if IsOnlyRedHeartPlayer(playerType) then
        if maxHearts <= 0 then
            player:AddMaxHearts(2 - maxHearts)
        end
        if hearts <= 0 then
            player:AddHearts(1)
        end
    elseif playerType == PlayerType.PLAYER_THEFORGOTTEN then
        local boneHearts = player:GetBoneHearts()
        if boneHearts <= 0 then
            player:AddBoneHearts(1)
        end
    else
        if maxHearts > 0 then
            if hearts <= 0 then
                player:AddHearts(1 - hearts)
            end
        else
            if player:GetSoulHearts() <= 0 then
                AddRawSoulHearts(player, 1)
            end
        end
    end
    local info = data.ReviveInfo
    local callback = info.Callback
    if callback then
        callback(player, data.Reviver)
    end
    Isaac.RunCallback("TY_PRE_PLAYER_REVIVE", player, info)
end

local function ReviveUpdate(player) 
    local type = player:GetPlayerType()
    local data = ty:GetLibData(player).ReviveTable
    local info = data.ReviveInfo
    local spr = player:GetSprite()
    local frame = spr:GetFrame()
    local canRevive = false
    local anim = spr:GetAnimation()
    if player:IsExtraAnimationFinished() then
        player:PlayExtraAnimation(info.Animation)
    else
        canRevive = frame >= info.ReviveFrame
    end
    if canRevive or data.ReviveTime >= 60 then
        data.IsDead = false
        data.ReviveTime = 0
        player:StopExtraAnimation()
        player:ClearEntityFlags(EntityFlag.FLAG_NO_DAMAGE_BLINK)
        RevivePlayer(player)
        return true
    end
    return false
end

do
    local function PostPlayerKilled(mod, entity)
        local player = entity:ToPlayer()
        if entity.Variant ~= 0 then
            return
        end
        local playerType = player:GetPlayerType()
        local twin = player:GetOtherTwin()
        local data = ty:GetLibData(player).ReviveTable
        local reviveInfoData = Revive:CanPlayerRevive(player)
        local canRevive = reviveInfoData.CanRevive
        local info = reviveInfoData.Info
        local reviver = reviveInfoData.Reviver
        if canRevive then
            local shouldHasHeart = player:GetBoneHearts() + player:GetSoulHearts() + player:GetHearts() > 0
            local addedHeartContainers = 0
            local onlyRedHearts = IsOnlyRedHeartPlayer(playerType)
            if not shouldHasHeart then
                if playerType == PlayerType.PLAYER_THEFORGOTTEN then
                    player:AddBoneHearts(1)
                elseif onlyRedHearts then
                    if player:GetMaxHearts() <= 0 then
                        player:AddMaxHearts(2)
                        addedHeartContainers = addedHeartContainers + 2
                    end
                    player:AddHearts(2)
                end
            end
            player:Revive()
            if playerType == PlayerType.PLAYER_THEFORGOTTEN_B then
                if not player.Visible then
                    player.Visible = true
                end
            end
            if onlyRedHearts then
                player:AddMaxHearts(-addedHeartContainers)
            else
                player:AddSoulHearts(-1)
            end
            info.Animation = info.Animation or Revive:GetVanillaReviveAnimation(player)
            info.ReviveFrame = info.ReviveFrame or Revive:GetPlayerReviveFrame(player)
            data.ReviveTime = 0
            data.IsDead = true
            data.ReviveInfo = info
            data.AnimationCountdown = -1
            data.PlayingAnimation = info.Animation
            data.Reviver = reviver
            if not shouldHasHeart then
                local redHearts = player:GetHearts()
                if redHearts > 0 then
                    player:AddHearts(-redHearts)
                end
                local boneHearts = player:GetBoneHearts()
                if boneHearts > 0 then
                    player:AddBoneHearts(-boneHearts)
                end
            end
        end
    end
    Revive:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, PostPlayerKilled, EntityType.ENTITY_PLAYER)

    local function PostPlayerUpdate(mod, player)
        local playerType = player:GetPlayerType()
        local data = ty:GetLibData(player).ReviveTable
        if not data then
            return
        end
        if data.PlayingAnimation then
            data.AnimationCountdown = data.AnimationCountdown or -1
            if data.AnimationCountdown < 0 then
                player:PlayExtraAnimation(data.PlayingAnimation)
                data.PlayingAnimation = nil
            else
                data.AnimationCountdown = data.AnimationCountdown - 1
            end
        end
        if Revive:IsReviving(player) then
            player:SetMinDamageCooldown(120)
            player:AddEntityFlags(EntityFlag.FLAG_NO_DAMAGE_BLINK)
            if player:GetSprite():IsEventTriggered("DeathSound") then
                ty.SFXMANAGER:Play(SoundEffect.SOUND_ISAACDIES)
            end
            player.ControlsCooldown = math.max(player.ControlsCooldown, 1)
            player.Velocity = Vector(0, 0)
            ReviveUpdate(player)
        end
    end
    Revive:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, PostPlayerUpdate)

    local function PostPlayerEffect(mod, player)
        if Revive:IsReviving(player) then
            local data = ty:GetLibData(player).ReviveTable
            data.ReviveTime = data.ReviveTime + 1
        end
    end
    Revive:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, PostPlayerEffect)

    local function PrePlayerCollision(mod, player, other, low)
        if Revive:IsReviving(player) then
            return true
        end
    end
    Revive:AddCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, PrePlayerCollision)

    local function PreOtherCollision(mod, _, other, low)
        if other.Type == EntityType.ENTITY_PLAYER then
            local player = other:ToPlayer()
            local data = ty:GetLibData(player).ReviveTable
            if Revive:IsReviving(player) then
                return true
            end
        end
    end
    Revive:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, PreOtherCollision)
    Revive:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, PreOtherCollision)
end

return Revive