local HiddenItemManager = ty:DefineANewClass()

local hiddenPos = Vector(-1024, -1024)

local function InitItemWisp(wisp, player)
    wisp.Position = hiddenPos
    wisp.Velocity = Vector(0, 0)
    wisp.Coins = ty.ConstantValues.HIDDENITEMMANAGERCONSTANT
    wisp.Hearts = ty.ConstantValues.HIDDENITEMMANAGERCONSTANT
    wisp.Keys = ty.ConstantValues.HIDDENITEMMANAGERCONSTANT
    wisp:AddEntityFlags(EntityFlag.FLAG_NO_QUERY | EntityFlag.FLAG_NO_REWARD | EntityFlag.FLAG_DONT_OVERWRITE)
    wisp:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    local data = ty:GetLibData(wisp)
    data.IsHiddenItem = true
    data.PlayerIndex = ty:GetPlayerIndex(player)
end

local function RestoreItemWisp(wisp)
    wisp:AddToOrbit(wisp.OrbitLayer)
    wisp.Coins = 0
    wisp.Hearts = 0
    wisp.Keys = 0
end

local function IsHiddenItemWisp(wisp)
    if wisp and wisp.Coins == ty.ConstantValues.HIDDENITEMMANAGERCONSTANT and wisp.Hearts == ty.ConstantValues.HIDDENITEMMANAGERCONSTANT and wisp.Keys == ty.ConstantValues.HIDDENITEMMANAGERCONSTANT then
        return true
    end
    return false
end

function HiddenItemManager:PostGameStarted(continued)
    if not continued then
        return
    end
    for _, ent in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.ITEM_WISP)) do
        local wisp = ent:ToFamiliar()
        if IsHiddenItemWisp(wisp) then
            for _, player in pairs(PlayerManager.GetPlayers()) do
                local playerData = ty:GetLibData(player)
                if ty:IsValueInTable(tostring(wisp.InitSeed), playerData.HiddenItemManager.ItemList) then
                    InitItemWisp(wisp, player)
                    break
                end
            end
        else
            RestoreItemWisp(wisp)
        end
    end
end
HiddenItemManager:AddPriorityCallback(ModCallbacks.MC_POST_GAME_STARTED, 1, HiddenItemManager.PostGameStarted)

function HiddenItemManager:FamiliarUpdate(familiar)
    local wisp = familiar:ToFamiliar()
    if IsHiddenItemWisp(wisp) then
        wisp.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        wisp.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
        wisp.Visible = false
        wisp.Position = hiddenPos
        wisp.Velocity = Vector(0, 0)
    end
end
HiddenItemManager:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, HiddenItemManager.FamiliarUpdate, FamiliarVariant.ITEM_WISP)

function HiddenItemManager:PreUseItem(collectibleType, rng, player, useFlags, activeSlot, customVarData)
    local playerData = ty:GetLibData(player)
    for _, ent in pairs(Isaac.GetRoomEntities()) do
        if IsHiddenItemWisp(ent:ToFamiliar()) then
            local wisp = ent:ToFamiliar()
            wisp:RemoveFromOrbit()
            wisp.Player = nil
        end
    end
end
HiddenItemManager:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, HiddenItemManager.PreUseItem, CollectibleType.COLLECTIBLE_SACRIFICIAL_ALTAR)

function HiddenItemManager:UseItem(collectibleType, rng, player, useFlags, activeSlot, customVarData)
    if collectibleType == CollectibleType.COLLECTIBLE_SACRIFICIAL_ALTAR then
        local playerData = ty:GetLibData(player)
        for _, ent in pairs(Isaac.GetRoomEntities()) do
            if IsHiddenItemWisp(ent:ToFamiliar()) then
                local wisp = ent:ToFamiliar()
                local data = ty:GetLibData(wisp)
                wisp.Player = Isaac.GetPlayer(data.PlayerIndex)
            end
        end
        player:AddItemWisp(CollectibleType.COLLECTIBLE_DADS_NOTE, hiddenPos, false):Remove()
    end
end
HiddenItemManager:AddCallback(ModCallbacks.MC_USE_ITEM, HiddenItemManager.UseItem)

function HiddenItemManager:PreFamiliarCollision(familiar)
    local wisp = familiar:ToFamiliar()
	if IsHiddenItemWisp(wisp) then
		return true
	end
end
HiddenItemManager:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, HiddenItemManager.PreFamiliarCollision, FamiliarVariant.ITEM_WISP)

function HiddenItemManager:EntityTakeDamage(entity, damage, damageFlags, source, countdown)
	if entity.Type == EntityType.ENTITY_FAMILIAR and entity.Variant == FamiliarVariant.ITEM_WISP and IsHiddenItemWisp(entity:ToFamiliar()) then
		return false
	end
	if source.Type == EntityType.ENTITY_FAMILIAR and source.Variant == FamiliarVariant.ITEM_WISP and IsHiddenItemWisp(source.Entity:ToFamiliar()) then
		return false
	end
end
HiddenItemManager:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, HiddenItemManager.EntityTakeDamage)

function HiddenItemManager:PostTearInit(tear)
	if tear.SpawnerEntity and tear.SpawnerEntity.Type == EntityType.ENTITY_FAMILIAR and tear.SpawnerEntity.Variant == FamiliarVariant.ITEM_WISP and IsHiddenItemWisp(tear.SpawnerEntity:ToFamiliar()) then
		tear:Remove()
		return true
	end
end
HiddenItemManager:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, HiddenItemManager.PostTearInit)

function HiddenItemManager:UseItem(itemID, rng, player, useFlags, activeSlot, varData)
    for _, ent in pairs(Isaac.GetRoomEntities()) do
        if IsHiddenItemWisp(ent:ToFamiliar()) then
            ent:Remove()
        end
    end
    player:AddItemWisp(CollectibleType.COLLECTIBLE_DADS_NOTE, hiddenPos, false):Remove()
end
HiddenItemManager:AddCallback(ModCallbacks.MC_USE_ITEM, HiddenItemManager.UseItem, CollectibleType.COLLECTIBLE_GENESIS)

function HiddenItemManager:RefreshHiddenItem(player)
    player:AddItemWisp(CollectibleType.COLLECTIBLE_DADS_NOTE, hiddenPos, false):Remove()
end

function HiddenItemManager:CreateHiddenItem(player, collectibleType)
    local wisp = player:AddItemWisp(collectibleType, hiddenPos, false)
    local playerData = ty:GetLibData(player)
    table.insert(playerData.HiddenItemManager.ItemList, tostring(wisp.InitSeed))
    InitItemWisp(wisp, player)
end

function HiddenItemManager:RemoveHiddenItem(player, collectibleType)
    local playerData = ty:GetLibData(player)
    if playerData.HiddenItemManager then
        for _, seed in pairs(playerData.HiddenItemManager.ItemList) do
            for _, ent in pairs(Isaac.GetRoomEntities()) do
                if seed == tostring(ent.InitSeed) and IsHiddenItemWisp(ent:ToFamiliar()) and ent.SubType == collectibleType then
                    ent:Remove()
                end
            end
        end
        HiddenItemManager:RefreshHiddenItem(player)
    end
end

function HiddenItemManager:RemoveStrawman(player)
    for _, ent in pairs(Isaac.GetRoomEntities()) do
        if IsHiddenItemWisp(ent:ToFamiliar()) and ent.SubType == CollectibleType.COLLECTIBLE_STRAW_MAN then
            ent:Remove()
        end
    end
    HiddenItemManager:RefreshHiddenItem(player)
end

return HiddenItemManager