local Revive = ty:DefineANewClass()

local Private = {}

do
    Private.PlayerActions = {
        [ButtonAction.ACTION_LEFT] = true,
        [ButtonAction.ACTION_RIGHT] = true,
        [ButtonAction.ACTION_UP] = true,
        [ButtonAction.ACTION_DOWN] = true,
        [ButtonAction.ACTION_SHOOTLEFT] = true,
        [ButtonAction.ACTION_SHOOTRIGHT] = true,
        [ButtonAction.ACTION_SHOOTUP] = true,
        [ButtonAction.ACTION_SHOOTDOWN] = true,
        [ButtonAction.ACTION_BOMB] = true,
        [ButtonAction.ACTION_ITEM] = true,
        [ButtonAction.ACTION_PILLCARD] = true,
        [ButtonAction.ACTION_DROP] = true
    }
    Private.OnlyRedHeartPlayers = {
        [PlayerType.PLAYER_KEEPER] = true,
        [PlayerType.PLAYER_BETHANY] = true,
        [PlayerType.PLAYER_KEEPER_B] = true,
        [ty.CustomPlayerType.WARFARIN] = true
    }
    Private.OnlyBoneHeartPlayers = {
        [PlayerType.PLAYER_THEFORGOTTEN] = true
    }
    Private.OnlySoulHeartPlayers = {
        [PlayerType.PLAYER_BETHANY_B] = true,
        [PlayerType.PLAYER_BLACKJUDAS] = true,
        [PlayerType.PLAYER_BLUEBABY] = true,
        [PlayerType.PLAYER_BLUEBABY_B] = true,
        [PlayerType.PLAYER_THEFORGOTTEN_B] = true,
        [PlayerType.PLAYER_THESOUL] = true,
        [PlayerType.PLAYER_JUDAS_B] = true,
        [PlayerType.PLAYER_BETHANY_B] = true,
        [PlayerType.PLAYER_THESOUL_B] = true
    }
    
    function Private.IsOnlyRedHeartPlayer(player)
        if type(player) == "number" then
            return Private.OnlyRedHeartPlayers[player]
        else
            return Private.OnlyRedHeartPlayers[player:GetPlayerType()]
        end
    end
    
    function Private.IsOnlyBoneHeartPlayer(player)
        if type(player) == "number" then
            return Private.OnlyBoneHeartPlayers[player]
        else
            return player:GetHealthType() == HealthType.BONE
        end
    end
    
    function Private.AddRawSoulHearts(player, value)
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
    
    function Private.TableFirst(list, predicate)
        for k, v in pairs(list) do
            if not predicate or predicate(v, k) then
                return v
            end
        end
        return nil
    end
    
    function Private.GetSubPlayerParent(subPlayer)
        local subPlayerPtrHash = GetPtrHash(subPlayer)
        local players = PlayerManager.GetPlayers()
        return Private.TableFirst(players, function(player)
            local sub = player:GetSubPlayer()
            if not sub then
                return false
            end
            local subHash = GetPtrHash(sub)
            return subHash == subPlayerPtrHash
        end)
    end
    
    function Private.GetPlayerId(player, diffForgottenSoul)
        diffForgottenSoul = diffForgottenSoul or false
        local p = player:ToPlayer()
        if player:IsSubPlayer() then
            local playerParent = Private.GetSubPlayerParent(player)
            if playerParent then
                p = playerParent
            end
        end
        if diffForgottenSoul and player:GetPlayerType() == PlayerType.PLAYER_THESOUL then
            return p:GetCollectibleRNG(3):GetSeed()
        end
        return p:GetCollectibleRNG(1):GetSeed()
    end
    
    function Private.GetPlayerById(id)
        local players = PlayerManager.GetPlayers()
        return Private.TableFirst(players, function(player)
            return Private.GetPlayerId(player) == id
        end)
    end
end

do
    do
        do 
            local function CanSinglePlayerReviveFromConfig(player, config)
                local beforeVanilla = config.BeforeVanilla
                if beforeVanilla == nil then
                    beforeVanilla = true
                end
                return beforeVanilla or not player:WillPlayerRevive()
            end

            function Private:GetPlayerReviveConfigKey(player)
                local callbacks = Isaac.GetCallbacks("TY_PRE_PLAYER_REVIVE")
                local playerType = player:GetPlayerType()
                for _, callback in pairs(callbacks) do
                    local lifeBorrowed = false
                    local configKey = callback.Function(callback.Mod, player)
                    local reviver = player
                    if not configKey then
                        if playerType == PlayerType.PLAYER_JACOB or playerType == PlayerType.PLAYER_ESAU then
                            local twin = player:GetOtherTwin()
                            if twin then
                                configKey = callback.Function(callback.Mod, twin)
                                lifeBorrowed = true
                                reviver = twin
                            end
                        end
                    end
                    if not configKey then 
                        goto continue
                    end
                    local config = Revive:GetReviveConfig(configKey)
                    if not config then
                        goto continue
                    end
                    local canBorrowLife = config.CanBorrowLife
                    if canBorrowLife == nil then
                        canBorrowLife = true
                    end
                    if not canBorrowLife and lifeBorrowed then
                        goto continue
                    end
                    if CanSinglePlayerReviveFromConfig(player, config) then
                        return true, configKey, reviver
                    end
                    ::continue::
                end
                return false, nil, nil
            end
        end
    end
    do
        function Private:StartRevive(player)
            local playerType = player:GetPlayerType()
            local shouldHasHeart = player:GetBoneHearts() + player:GetSoulHearts() + player:GetHearts() > 0
            local addedBoneHearts = 0
            local addedHeartContainers = 0
            local onlyRedHearts = Private.IsOnlyRedHeartPlayer(player)
            local onlyBoneHearts = Private.IsOnlyBoneHeartPlayer(player)
            if not shouldHasHeart then
                if onlyBoneHearts then
                    player:AddBoneHearts(1)
                    addedBoneHearts = addedBoneHearts + 1
                elseif onlyRedHearts then
                    if player:GetMaxHearts() <= 0 then
                        player:AddMaxHearts(2)
                        addedHeartContainers = addedHeartContainers + 2
                    end
                    player:AddHearts(2)
                end
            end
            player:Revive()
            if not shouldHasHeart then
                if onlyBoneHearts then
                    player:AddBoneHearts(-addedBoneHearts)
                elseif onlyRedHearts then
                    player:AddMaxHearts(-addedHeartContainers)
                end
                local redHearts = player:GetHearts()
                if redHearts > 0 then
                    player:AddHearts(-redHearts)
                end
                local boneHearts = player:GetBoneHearts()
                if boneHearts > 0 then
                    player:AddBoneHearts(-boneHearts)
                end
                local soulHearts = player:GetSoulHearts()
                if soulHearts > 0 then
                    Private.AddRawSoulHearts(player, -soulHearts)
                end
            end
            if playerType == PlayerType.PLAYER_THEFORGOTTEN_B then
                if not player.Visible then
                    player.Visible = true
                end
            end
        end
        function Private:GetVanillaReviveAnimation(player)
            local playerType = player:GetPlayerType()
            if playerType == PlayerType.PLAYER_THELOST or playerType == PlayerType.PLAYER_THELOST_B or playerType == PlayerType.PLAYER_THESOUL or playerType == PlayerType.PLAYER_THESOUL_B then
                return "LostDeath"
            end
            if player:GetEffects():HasNullEffect(NullItemID.ID_LOST_CURSE) then
                return "LostDeath"
            end
            return "Death"
        end
        function Private:GetPlayerReviveFrame(player)
            if self:GetVanillaReviveAnimation(player) == "LostDeath" then
                return 37
            end
            return 56
        end
    end

    do
        function Private:GetAnimationAndReviveFrame(player)
            local configKey = ty:GetLibData(player)._REVIVE.ReviveConfigKey
            local animation, reviveFrame
            if configKey then
                local config = Revive:GetReviveConfig(configKey)
                if config then
                    animation = config.Animation
                    reviveFrame = config.ReviveFrame
                end
            end
            return animation or Private:GetVanillaReviveAnimation(player), reviveFrame or Private:GetPlayerReviveFrame(player)
        end
        function Private:IsAtReviveTime(player)
            local spr = player:GetSprite()
            local frame = spr:GetFrame()
            local canRevive = false
            local anim = spr:GetAnimation()
            local animation, reviveFrame = Private:GetAnimationAndReviveFrame(player)
            if player:IsExtraAnimationFinished() then
                player:PlayExtraAnimation(animation)
            else
                canRevive = frame >= reviveFrame
            end
            local reviveTime = ty:GetLibData(player)._REVIVE.ReviveTime or 0
            return canRevive or reviveTime >= 60
        end
        function Private:ReviveUpdate(player) 
            player:SetMinDamageCooldown(120)
            player:AddEntityFlags(EntityFlag.FLAG_NO_DAMAGE_BLINK)
            if player:GetSprite():IsEventTriggered("DeathSound") then
                ty.SFXMANAGER:Play(SoundEffect.SOUND_ISAACDIES)
            end
            player.ControlsCooldown = math.max(player.ControlsCooldown, 1)
            player.Velocity = Vector.Zero
            local atTime = self:IsAtReviveTime(player)
            if not atTime then
                return false
            end
            self:FinishRevive(player)
            return true
        end
    end
    do
        function Private:PreventPlayerDeath(player)
            local playerType = player:GetPlayerType()
            local maxHearts = player:GetMaxHearts()
            local hearts = player:GetHearts()
            if playerType == PlayerType.PLAYER_THEFORGOTTEN_B and player.EntityCollisionClass == 0 then
                player.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
            end
            local healthType = player:GetHealthType()
            if healthType == HealthType.KEEPER then
                if maxHearts <= 0 then
                    player:AddMaxHearts(2 - maxHearts)
                end
                if hearts <= 0 then
                    player:AddHearts(2)
                end
            elseif Private.IsOnlyRedHeartPlayer(player) then
                if maxHearts <= 0 then
                    player:AddMaxHearts(2 - maxHearts)
                end
                if hearts <= 0 then
                    player:AddHearts(1)
                end
            elseif Private.IsOnlyBoneHeartPlayer(player) then
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
                        Private.AddRawSoulHearts(player, 1)
                    end
                end
            end
        end

        function Private:FinishRevive(player)
            local data = ty:GetLibData(player)._REVIVE
            player:StopExtraAnimation()
            player:ClearEntityFlags(EntityFlag.FLAG_NO_DAMAGE_BLINK)
            self:PreventPlayerDeath(player)
            local configKey = data.ReviveConfigKey
            if configKey then
                local config = Revive:GetReviveConfig(configKey)
                if config then
                    local reviverID = data.ReviverID
                    local reviver = Private.GetPlayerById(reviverID)
                    Isaac.RunCallbackWithParam("TY_POST_PLAYER_REVIVE", configKey, player, configKey, reviver)
                end
            end
            data.ReviveConfigKey = nil
            data.ReviverID = nil
            data.DeathAnimation = nil
            data.ReviveTime = nil
        end
    end

    do 
        function Private:CheckPlayerRevive(player)
            local data = ty:GetLibData(player)._REVIVE
            if not player or player.Variant ~= 0 then
                return
            end
            local configRevive, configKey, configReviver = Private:GetPlayerReviveConfigKey(player)
            if configRevive then
                Private:StartRevive(player)
                data.ReviveConfigKey = configKey
                data.ReviverID = Private.GetPlayerId(configReviver)
                local animation, _ = Private:GetAnimationAndReviveFrame(player)
                data.DeathAnimation = animation
                data.ReviveTime = 0
                return
            end
        end
    end
end

do
    Revive.Configs = {}
end

do
    function Revive:SetReviveConfig(key, config)
        Revive.Configs[key] = config
        config.Key = key
    end
    function Revive:GetReviveConfig(key)
        return Revive.Configs[key]
    end
    function Revive:IsReviving(player)
        return ty:GetLibData(player)._REVIVE and ty:GetLibData(player)._REVIVE.ReviveConfigKey
    end
end

do
    local function PostPlayerKilled(mod, entity)
        local player = entity:ToPlayer()
        Private:CheckPlayerRevive(player)
    end
    Revive:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, PostPlayerKilled, EntityType.ENTITY_PLAYER)
    local function PostPlayerUpdate(mod, player)
        local deathAnimation = ty:GetLibData(player)._REVIVE.DeathAnimation
        if deathAnimation then
            player:PlayExtraAnimation(deathAnimation)
            ty:GetLibData(player)._REVIVE.DeathAnimation = nil
        end
        if Revive:IsReviving(player) then
            Private:ReviveUpdate(player)
        end
    end
    Revive:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, PostPlayerUpdate)
    local function PostPlayerEffect(mod, player)
        if not Revive:IsReviving(player) then
            return
        end
        local reviveTime = ty:GetLibData(player)._REVIVE.ReviveTime or 0
        ty:GetLibData(player)._REVIVE.ReviveTime = reviveTime + 1
    end
    Revive:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, PostPlayerEffect)
    local function InputAction(mod, entity, hook, action)
        local player = entity and entity:ToPlayer()
        if not player or not Revive:IsReviving(player) then
            return
        end
        if not Private.PlayerActions[action] then
            return
        end
        if hook == InputHook.GET_ACTION_VALUE then
            return 0
        else
            return false
        end
    end
    Revive:AddCallback(ModCallbacks.MC_INPUT_ACTION, InputAction)
    local function PrePlayerCollision(mod, player, other, low)
        if Revive:IsReviving(player) then
            return true
        end
    end
    Revive:AddCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, PrePlayerCollision)
    local function PlayerTakeDamage(mod, entity, amount, flags, source, countdown)
        local player = entity:ToPlayer()
        if Revive:IsReviving(player) then
            Private:FinishRevive(player)
        end
    end
    Revive:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, 1000000, PlayerTakeDamage, EntityType.ENTITY_PLAYER)
    local function PreOtherCollision(mod, _, other, low)
        local player = other:ToPlayer()
        if player and Revive:IsReviving(player) then
            return true
        end
    end
    Revive:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, PreOtherCollision)
    Revive:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, PreOtherCollision)
    
    local function onGameStarted(_, isContinued)
        if isContinued then
            for _, p in pairs(PlayerManager.GetPlayers()) do
                if p:IsDead() then
                    Private:CheckPlayerRevive(p)
                end
            end
        end
    end
    Revive:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, onGameStarted)
end

return Revive