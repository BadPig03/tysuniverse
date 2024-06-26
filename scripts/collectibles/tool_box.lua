local ToolBox = ty:DefineANewClass()

local itemOutcomes = WeightedOutcomePicker()

do
    if ty.PERSISTENTGAMEDATA:Unlocked(Achievement.CREDIT_CARD) then
        itemOutcomes:AddOutcomeWeight(Card.CARD_CREDIT, 10)
    end
    if ty.PERSISTENTGAMEDATA:Unlocked(Achievement.ANCIENT_RECALL) then
        itemOutcomes:AddOutcomeWeight(Card.CARD_ANCIENT_RECALL, 10)
    end
    if ty.PERSISTENTGAMEDATA:Unlocked(Achievement.WILD_CARD) then
        itemOutcomes:AddOutcomeWeight(Card.CARD_WILD, 10)
    end
    itemOutcomes:AddOutcomeWeight(Card.CARD_QUESTIONMARK, 8)
    itemOutcomes:AddOutcomeWeight(Card.CARD_DICE_SHARD, 8)
    if ty.PERSISTENTGAMEDATA:Unlocked(Achievement.HOLY_CARD) then
        itemOutcomes:AddOutcomeWeight(Card.CARD_HOLY, 8)
    end
    if ty.PERSISTENTGAMEDATA:Unlocked(Achievement.RED_KEY) then
        itemOutcomes:AddOutcomeWeight(Card.CARD_CRACKED_KEY, 6)
    end
    itemOutcomes:AddOutcomeWeight(ty.CustomCards.GLOWINGHOURGLASSSHARD, 4)
    if ty.PERSISTENTGAMEDATA:Unlocked(Achievement.GET_OUT_OF_JAIL_FREE_CARD) then
        itemOutcomes:AddOutcomeWeight(Card.CARD_GET_OUT_OF_JAIL, 4)
    end
    if ty.PERSISTENTGAMEDATA:Unlocked(Achievement.CHAOS_CARD) then
        itemOutcomes:AddOutcomeWeight(Card.CARD_CHAOS, 4)
    end
    if ty.PERSISTENTGAMEDATA:Unlocked(Achievement.CARD_AGAINST_HUMANITY) then
        itemOutcomes:AddOutcomeWeight(Card.CARD_HUMANITY, 4)
    end
    if ty.PERSISTENTGAMEDATA:Unlocked(Achievement.ERA_WALK) then
        itemOutcomes:AddOutcomeWeight(Card.CARD_ERA_WALK, 2)
    end
    if ty.PERSISTENTGAMEDATA:Unlocked(Achievement.HUGE_GROWTH) then
        itemOutcomes:AddOutcomeWeight(Card.CARD_HUGE_GROWTH, 2)
    end
    itemOutcomes:AddOutcomeWeight(Card.CARD_EMERGENCY_CONTACT, 2)
    if ty.PERSISTENTGAMEDATA:Unlocked(Achievement.RULES_CARD) then
        itemOutcomes:AddOutcomeWeight(Card.CARD_RULES, 1)
    end
end

function ToolBox:EvaluateCache(player, cacheFlag)
    local count = player:GetCollectibleNum(ty.CustomCollectibles.TOOLBOX) + player:GetEffects():GetCollectibleEffectNum(ty.CustomCollectibles.TOOLBOX)
    for _, familiar in pairs(player:CheckFamiliarEx(ty.CustomEntities.TOOLBOX, count, RNG(), ty.ITEMCONFIG:GetCollectible(ty.CustomCollectibles.TOOLBOX))) do
        familiar:GetSprite():Play("Appear", true)
        familiar:AddToFollowers()
    end
end
ToolBox:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, ToolBox.EvaluateCache, CacheFlag.CACHE_FAMILIARS)

function ToolBox:FamiliarUpdate(familiar)
    local familiar = familiar:ToFamiliar()
    local player = familiar.Player
    local sprite = familiar:GetSprite()
    local room = ty.GAME:GetRoom()
    if sprite:IsFinished("Appear") or sprite:IsFinished("Idle") then
        sprite:Play("Float", true)
    end
    if sprite:IsPlaying("Float") then
        familiar:FollowParent()
    end
    local limit = 5
    if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
        limit = 4
    end
    if familiar.Coins >= limit then
        local rng = player:GetCollectibleRNG(ty.CustomCollectibles.TOOLBOX)
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, itemOutcomes:PickOutcome(rng), room:FindFreePickupSpawnPosition(familiar.Position, 0, true, false), Vector(0, 0), nil)
        familiar.Coins = 0
        sprite:Play("Appear", true)
    end
end
ToolBox:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, ToolBox.FamiliarUpdate, ty.CustomEntities.TOOLBOX)

function ToolBox:PreSpawnCleanAward(rng, spawnPosition)
    for _, ent in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, ty.CustomEntities.TOOLBOX)) do
        local familiar = ent:ToFamiliar()
        familiar:AddCoins(1)
    end
end
ToolBox:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, ToolBox.PreSpawnCleanAward)

return ToolBox