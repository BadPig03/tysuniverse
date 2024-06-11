local KeepersCore = ty:DefineANewClass()

local chestTable = {
    PickupVariant.PICKUP_CHEST,
    PickupVariant.PICKUP_BOMBCHEST,
    PickupVariant.PICKUP_SPIKEDCHEST,
    PickupVariant.PICKUP_ETERNALCHEST,
    PickupVariant.PICKUP_MIMICCHEST,
    PickupVariant.PICKUP_OLDCHEST,
    PickupVariant.PICKUP_WOODENCHEST,
    PickupVariant.PICKUP_MEGACHEST,
    PickupVariant.PICKUP_HAUNTEDCHEST,
    PickupVariant.PICKUP_LOCKEDCHEST,
    PickupVariant.PICKUP_GRAB_BAG,
    PickupVariant.PICKUP_REDCHEST,
    PickupVariant.PICKUP_MOMSCHEST
}

function KeepersCore:PostPickupInit(pickup)
    local globalData = ty.GLOBALDATA
    if ty:IsValueInTable(chestTable, pickup.Variant) and not globalData.KeepersCore[tostring(pickup.InitSeed)] then
        local lootList = pickup:GetLootList():GetEntries()
        local lootTable = {}
        for _, lootListEntry in pairs(lootList) do
            local rng = lootListEntry:GetRNG()
            if rng then
                rng = rng:GetSeed()
            else
                rng = -1
            end
            table.insert(lootTable, {Type = lootListEntry:GetType(), Variant = lootListEntry:GetVariant(), SubType = lootListEntry:GetSubType(), Seed = lootListEntry:GetSeed(), RNG = rng})
        end
        globalData.KeepersCore[tostring(pickup.InitSeed)] = lootTable
        pickup:UpdatePickupGhosts()
    end
end
KeepersCore:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, KeepersCore.PostPickupInit)

function KeepersCore:PrePickupGetLootList(pickup, shouldAdvance)
    local globalData = ty.GLOBALDATA
    local multiplier = PlayerManager.GetTotalTrinketMultiplier(ty.CustomTrinkets.KEEPERSCORE)
    if multiplier > 0 and ty:IsValueInTable(chestTable, pickup.Variant) and globalData.KeepersCore[tostring(pickup.InitSeed)] then
        local lootList = LootList()
        for _, lootListEntry in pairs(globalData.KeepersCore[tostring(pickup.InitSeed)]) do
            local rng = lootListEntry.RNG
            if rng == -1 then
                rng = nil
            else
                rng = RNG(rng)
            end
            lootList:PushEntry(lootListEntry.Type, lootListEntry.Variant, lootListEntry.SubType, lootListEntry.Seed, rng)
        end
        for i = 1, multiplier do
            lootList:PushEntry(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY)
        end
        return lootList
    end
end
KeepersCore:AddCallback(ModCallbacks.MC_PRE_PICKUP_GET_LOOT_LIST, KeepersCore.PrePickupGetLootList)

function KeepersCore:PostTriggerTrinketChanged(player, trinket, _)
    if trinket == ty.CustomTrinkets.KEEPERSCORE or trinket == ty.CustomTrinkets.KEEPERSCORE | TrinketType.TRINKET_GOLDEN_FLAG then
        local room = ty.GAME:GetRoom()
        room:InvalidatePickupVision() 
    end
end
KeepersCore:AddCallback(ModCallbacks.MC_POST_TRIGGER_TRINKET_ADDED, KeepersCore.PostTriggerTrinketChanged)
KeepersCore:AddCallback(ModCallbacks.MC_POST_TRIGGER_TRINKET_REMOVED, KeepersCore.PostTriggerTrinketChanged)

function KeepersCore:PostNewLevel()
    local globalData = ty.GLOBALDATA
    globalData.KeepersCore = {}
end
KeepersCore:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, KeepersCore.PostNewLevel)

return KeepersCore