local ToolBox = ty:DefineANewClass()

local itemOutcomes = WeightedOutcomePicker()

itemOutcomes:AddOutcomeWeight(Card.CARD_WILD, 10)
itemOutcomes:AddOutcomeWeight(Card.CARD_CRACKED_KEY, 10)
itemOutcomes:AddOutcomeWeight(Card.CARD_CHAOS, 10)
itemOutcomes:AddOutcomeWeight(Card.CARD_CREDIT, 10)
itemOutcomes:AddOutcomeWeight(Card.CARD_RULES, 1)
itemOutcomes:AddOutcomeWeight(Card.CARD_HUMANITY, 10)
itemOutcomes:AddOutcomeWeight(Card.CARD_GET_OUT_OF_JAIL, 10)
itemOutcomes:AddOutcomeWeight(Card.CARD_QUESTIONMARK, 10)
itemOutcomes:AddOutcomeWeight(Card.CARD_DICE_SHARD, 10)
itemOutcomes:AddOutcomeWeight(Card.CARD_EMERGENCY_CONTACT, 10)
itemOutcomes:AddOutcomeWeight(Card.CARD_HOLY, 10)
itemOutcomes:AddOutcomeWeight(Card.CARD_HUGE_GROWTH, 10)
itemOutcomes:AddOutcomeWeight(Card.CARD_ANCIENT_RECALL, 1)
itemOutcomes:AddOutcomeWeight(Card.CARD_ERA_WALK, 10)

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
    local limit = 6
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