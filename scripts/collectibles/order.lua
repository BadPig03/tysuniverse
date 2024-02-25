local Order = ty:DefineANewClass()

local itemPoolFlag = true
local itemPoolCNName = {
    [ItemPoolType.POOL_TREASURE] = "宝箱房",
    [ItemPoolType.POOL_SHOP] = "商店",
    [ItemPoolType.POOL_BOSS] = "头目房", 
    [ItemPoolType.POOL_DEVIL] = "恶魔房",
    [ItemPoolType.POOL_ANGEL] = "天使房",
    [ItemPoolType.POOL_DEMON_BEGGAR] = "恶魔乞丐",
    [ItemPoolType.POOL_SECRET] = "隐藏房",
    [ItemPoolType.POOL_LIBRARY] = "图书馆",
    [ItemPoolType.POOL_RED_CHEST] = "红箱子",
    [ItemPoolType.POOL_CURSE] = "诅咒房",
    [ItemPoolType.POOL_CRANE_GAME] = "夹娃娃机",
    [ItemPoolType.POOL_ULTRA_SECRET] = "究极隐藏房",
    [ItemPoolType.POOL_PLANETARIUM] = "星象房"
}
local itemPoolENName = {
    [ItemPoolType.POOL_TREASURE] = "Treasure Room",
    [ItemPoolType.POOL_SHOP] = "Shop",
    [ItemPoolType.POOL_BOSS] = "Boss Room", 
    [ItemPoolType.POOL_DEVIL] = "Devil Room",
    [ItemPoolType.POOL_ANGEL] = "Angel Room",
    [ItemPoolType.POOL_DEMON_BEGGAR] = "Demon Beggar",
    [ItemPoolType.POOL_SECRET] = "Secret Room",
    [ItemPoolType.POOL_LIBRARY] = "Library",
    [ItemPoolType.POOL_RED_CHEST] = "Red Chest",
    [ItemPoolType.POOL_CURSE] = "Curse Room",
    [ItemPoolType.POOL_CRANE_GAME] = "Crane Game",
    [ItemPoolType.POOL_ULTRA_SECRET] = "Ultra Secret",
    [ItemPoolType.POOL_PLANETARIUM] = "Planetarium"
}

function Order:PostNewLevel()
    if PlayerManager.AnyoneHasCollectible(ty.CustomCollectibles.ORDER) and not PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_CHAOS) then
        local data = ty.GLOBALDATA
        data.Order.Timeout = 30
    end
end
Order:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, Order.PostNewLevel)

function Order:PreGetCollectible(itemPoolType, decrease, seed)
    if PlayerManager.AnyoneHasCollectible(ty.CustomCollectibles.ORDER) and not PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_CHAOS) then
        local data = ty.GLOBALDATA
        if itemPoolFlag and itemPoolType ~= data.Order.ItemPoolList[ty.LEVEL:GetAbsoluteStage()] then
            itemPoolFlag = false
            local id = ty.ITEMPOOL:GetCollectible(data.Order.ItemPoolList[ty.LEVEL:GetAbsoluteStage()], decrease, seed)
            itemPoolFlag = true
            return id
        end
    end
end
Order:AddCallback(ModCallbacks.MC_PRE_GET_COLLECTIBLE, Order.PreGetCollectible)

function Order:PostUpdate()
    if PlayerManager.AnyoneHasCollectible(ty.CustomCollectibles.ORDER) and not PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_CHAOS) then
        local data = ty.GLOBALDATA
        if not data.Order.Set then
            data.Order.Set = true
            data.Order.Timeout = 30
        end
        if data.Order.Timeout and data.Order.Timeout > 0 then
            data.Order.Timeout = data.Order.Timeout - 1
        elseif data.Order.Timeout == 0 then
            data.Order.Timeout = -1
            local language = Options.Language
            if language == "zh" then
                ty.HUD:ShowFortuneText("本层道具池为"..itemPoolCNName[data.Order.ItemPoolList[ty.LEVEL:GetAbsoluteStage()]])
            else                                                                                                                                                    
                ty.HUD:ShowFortuneText("The item pool is", itemPoolENName[data.Order.ItemPoolList[ty.LEVEL:GetAbsoluteStage()]])
            end
        end
    end
end
Order:AddCallback(ModCallbacks.MC_POST_UPDATE, Order.PostUpdate)

return Order