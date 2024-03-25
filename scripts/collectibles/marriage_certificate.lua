local MarriageCertificate = ty:DefineANewClass()

local bannedCollectibles = {
    CollectibleType.COLLECTIBLE_1UP,
    CollectibleType.COLLECTIBLE_DEAD_CAT,
    CollectibleType.COLLECTIBLE_GUPPYS_COLLAR,
    CollectibleType.COLLECTIBLE_JUDAS_SHADOW,
    CollectibleType.COLLECTIBLE_LAZARUS_RAGS,
    CollectibleType.COLLECTIBLE_DIVORCE_PAPERS,
    CollectibleType.COLLECTIBLE_STRAW_MAN,
    CollectibleType.COLLECTIBLE_INNER_CHILD,
    ty.CustomCollectibles.SCAPEGOAT,
    ty.CustomCollectibles.NOTICEOFCRITICALCONDITION,
    ty.CustomCollectibles.MARRIAGECERTIFICATE,
    ty.CustomCollectibles.OCEANUSSOUL
}

local allowCopying = false
local extraBlackHearts = false
local itemCount = 0


local function GetPlayerFromInitSeed(seed)
    for _, player in pairs(PlayerManager.GetPlayers()) do
        if player.InitSeed == seed then
            return player
        end
    end
    return nil
end

local function GetCollectiblesList(player)
    local list = {}
    for itemID, count in pairs(player:GetCollectiblesList()) do
        if count > 0 and ItemConfig.Config.IsValidCollectible(itemID) and not ty:IsValueInTable(itemID, bannedCollectibles) and not ty.ITEMCONFIG:GetCollectible(itemID):HasTags(ItemConfig.TAG_QUEST) and ty.ITEMCONFIG:GetCollectible(itemID).Type % ItemType.ITEM_ACTIVE == ItemType.ITEM_PASSIVE and not ty.ITEMCONFIG:GetCollectible(itemID).Hidden then
            table.insert(list, itemID)
        end
    end
    return list
end

local function CopyCollectiblesFromPlayer(player, init)
    local origin = GetCollectiblesList(player)
    local rng = player:GetCollectibleRNG(ty.CustomCollectibles.MARRIAGECERTIFICATE)
    local list = {}
    if #origin > 0 then
        repeat
            local number = rng:RandomInt(#origin) + 1
            table.insert(list, origin[number])
            table.remove(origin, number)
        until #list > math.min(3, #origin)    
    end
    if init then
        table.insert(list, CollectibleType.COLLECTIBLE_WHORE_OF_BABYLON)
        table.insert(list, CollectibleType.COLLECTIBLE_DEAD_BIRD)
        table.insert(list, CollectibleType.COLLECTIBLE_MAGGYS_BOW)
    end
    return list
end

local function InitSubPlayer(player)
    local subPlayer = Isaac.GetPlayer(#PlayerManager.GetPlayers() - 1)
    local subPlayerData = ty:GetLibData(subPlayer)
    local playerData = ty:GetLibData(player)
    subPlayerData.MarriageCertificate.MainPlayerSeed = player.InitSeed
    subPlayerData.MarriageCertificate.IsAlive = true
    playerData.MarriageCertificate.MainPlayerSeed = -1
    playerData.MarriageCertificate.IsAlive = true
    subPlayer:ChangePlayerType(PlayerType.PLAYER_EVE)
    subPlayer:AddMaxHearts(-2)
    if extraBlackHearts then
        subPlayer:AddBlackHearts(6)
        extraBlackHearts = false
    end
    allowCopying = false
    for _, itemID in pairs(CopyCollectiblesFromPlayer(player, true)) do
        subPlayer:AddCollectible(itemID)
    end
    subPlayer:AnimateCollectible(ty.CustomCollectibles.MARRIAGECERTIFICATE)
    allowCopying = true
end 

local function GetMainPlayer(player)
    local data = ty:GetLibData(player)
    return GetPlayerFromInitSeed(data.MarriageCertificate.MainPlayerSeed)
end

local function IsSubPlayer(player)
    local data = ty:GetLibData(player)
    return data.MarriageCertificate.MainPlayerSeed ~= -1
end

function MarriageCertificate:PreAddCollectible(type, charge, firstTime, slot, varData, player)
    if allowCopying and IsSubPlayer(player) and type ~= CollectibleType.COLLECTIBLE_DOGMA then
        GetMainPlayer(player):AddCollectible(type)
        return false
    end
    if type == ty.CustomCollectibles.MARRIAGECERTIFICATE then
        if player:GetPlayerType() == PlayerType.PLAYER_ESAU then
            player:GetOtherTwin():AddCollectible(ty.CustomCollectibles.MARRIAGECERTIFICATE)
            return false
        elseif player:GetPlayerType() == PlayerType.PLAYER_LAZARUS_B or player:GetPlayerType() == PlayerType.PLAYER_LAZARUS2_B then
            return CollectibleType.COLLECTIBLE_BIRTHRIGHT
        end
        if PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_STRAW_MAN) then
            player:AddBlackHearts(6)
            return false
        end
        if player:HasCollectible(CollectibleType.COLLECTIBLE_DIVORCE_PAPERS) then
            for i = 1, player:GetCollectibleNum(CollectibleType.COLLECTIBLE_DIVORCE_PAPERS) do
                player:RemoveCollectible(CollectibleType.COLLECTIBLE_DIVORCE_PAPERS)
            end
            extraBlackHearts = true
        end
        if (PlayerManager.GetEsauJrState(ty:GetPlayerIndex(player)) or player:HasCollectible(CollectibleType.COLLECTIBLE_ESAU_JR)) then
            return CollectibleType.COLLECTIBLE_DIVORCE_PAPERS
        end
    elseif type == CollectibleType.COLLECTIBLE_DIVORCE_PAPERS and player:HasCollectible(ty.CustomCollectibles.MARRIAGECERTIFICATE) then
        for i = 1, player:GetCollectibleNum(ty.CustomCollectibles.MARRIAGECERTIFICATE) do
            player:RemoveCollectible(ty.CustomCollectibles.MARRIAGECERTIFICATE)
        end
        player:AddBlackHearts(6)
    elseif type == CollectibleType.COLLECTIBLE_ESAU_JR and player:HasCollectible(ty.CustomCollectibles.MARRIAGECERTIFICATE) then
        allowCopying = false
        for _, player2 in pairs(PlayerManager.GetPlayers()) do
            if IsSubPlayer(player) then
                player2:AddCollectible(CollectibleType.COLLECTIBLE_C_SECTION)
            end
        end
        allowCopying = true
        return false
    end
end
MarriageCertificate:AddCallback(ModCallbacks.MC_PRE_ADD_COLLECTIBLE, MarriageCertificate.PreAddCollectible)

function MarriageCertificate:PostAddCollectible(type, charge, firstTime, slot, varData, player)
    if type == ty.CustomCollectibles.MARRIAGECERTIFICATE and player:GetCollectibleNum(ty.CustomCollectibles.MARRIAGECERTIFICATE) == 1 then
        player:GetEffects():AddNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.MARRIAGECERTIFICATEHEARTS).ID)
        ty.HiddenItemManager:CreateHiddenItem(player, CollectibleType.COLLECTIBLE_STRAW_MAN)
        InitSubPlayer(player)
        ty.ITEMPOOL:RemoveCollectible(CollectibleType.COLLECTIBLE_STRAW_MAN)
    end
    if type == CollectibleType.COLLECTIBLE_STRAW_MAN then
        ty.ITEMPOOL:RemoveCollectible(ty.CustomCollectibles.MARRIAGECERTIFICATE)
    end
end
MarriageCertificate:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, MarriageCertificate.PostAddCollectible)

function MarriageCertificate:PostTriggerCollectibleRemoved(player, type)
    player:GetEffects():RemoveNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.MARRIAGECERTIFICATEHEARTS).ID)
    ty.HiddenItemManager:RemoveHiddenItem(player, CollectibleType.COLLECTIBLE_STRAW_MAN)
end
MarriageCertificate:AddCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_REMOVED, MarriageCertificate.PostTriggerCollectibleRemoved, ty.CustomCollectibles.MARRIAGECERTIFICATE)

function MarriageCertificate:PostNewLevel()
    if not PlayerManager.AnyoneHasCollectible(ty.CustomCollectibles.MARRIAGECERTIFICATE) then
        return
    end
    for _, player in pairs(PlayerManager.GetPlayers()) do
        if IsSubPlayer(player) then
            local data = ty:GetLibData(player)
            if data.MarriageCertificate.IsAlive then
                allowCopying = false
                for _, itemID in pairs(CopyCollectiblesFromPlayer(GetMainPlayer(player), false)) do
                    player:AddCollectible(itemID)
                end
                allowCopying = true
            else
                local effects = player:GetEffects()
                effects:RemoveNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.LOSTSOUL).ID)
                effects:RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE, -1)
                player:ChangePlayerType(PlayerType.PLAYER_EVE)
                player:AddMaxHearts(4)
                player:AddHearts(2)
                player:AddSoulHearts(-1)
                data.MarriageCertificate.IsAlive = true
            end
        end
    end
end
MarriageCertificate:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, MarriageCertificate.PostNewLevel)

function MarriageCertificate:PreTriggerPlayerDeath(player)
    local data = ty:GetLibData(player)
    if IsSubPlayer(player) and data.MarriageCertificate.IsAlive then
        data.MarriageCertificate.IsAlive = false
        player:GetEffects():AddNullEffect(ty.ITEMCONFIG:GetCollectible(ty.CustomNullItems.LOSTSOUL).ID)
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 3, player.Position, Vector(0, 0), nil)
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 4, player.Position, Vector(0, 0), nil)    
        return false
    end
end
MarriageCertificate:AddCallback(ModCallbacks.MC_PRE_TRIGGER_PLAYER_DEATH, MarriageCertificate.PreTriggerPlayerDeath)

function MarriageCertificate:PreNewRoom(room, roomDesc)
    if PlayerManager.AnyoneHasCollectible(ty.CustomCollectibles.MARRIAGECERTIFICATE) and ty.LEVEL:HasAbandonedMineshaft() and ty.LEVEL:GetDimension() == Dimension.KNIFE_PUZZLE then
        itemCount = 0
        for _, player in pairs(PlayerManager.GetPlayers()) do
            for i = 1, player:GetCollectibleNum(ty.CustomCollectibles.MARRIAGECERTIFICATE) do
                player:RemoveCollectible(ty.CustomCollectibles.MARRIAGECERTIFICATE)
                itemCount = itemCount + 1
            end
        end
    end
end
MarriageCertificate:AddCallback(ModCallbacks.MC_PRE_NEW_ROOM, MarriageCertificate.PreNewRoom)

function MarriageCertificate:PostNewRoom()
    if ty.LEVEL:HasAbandonedMineshaft() and ty.LEVEL:GetDimension() == Dimension.NORMAL and itemCount > 0 then
        for i = 1, itemCount do
            local item = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_DIVORCE_PAPERS, ty.GAME:GetRoom():FindFreePickupSpawnPosition(Vector(200, 520), 0, true), Vector(0, 0), nil):ToPickup()
            item.ShopItemId = -2
            item.Price = 0
            item:RemoveCollectibleCycle()
        end
        itemCount = 0
    end
    if PlayerManager.AnyoneHasCollectible(ty.CustomCollectibles.MARRIAGECERTIFICATE) then
        for _, player in pairs(PlayerManager.GetPlayers()) do
            if player:HasCollectible(ty.CustomCollectibles.MARRIAGECERTIFICATE) then
                ty.HiddenItemManager:RefreshHiddenItem(player)
            end
        end
    end
end
MarriageCertificate:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, MarriageCertificate.PostNewRoom)

return MarriageCertificate