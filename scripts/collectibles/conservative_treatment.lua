local ConservativeTreatment = ty:DefineANewClass()

local stat = ty.Stat

function ConservativeTreatment:EvaluateCache(player, cacheFlag)
    if player:HasCollectible(ty.CustomCollectibles.CONSERVATIVETREATMENT) then
        if cacheFlag == CacheFlag.CACHE_SPEED and player.MoveSpeed < 1 then
            player.MoveSpeed = 1
        end
        if cacheFlag == CacheFlag.CACHE_FIREDELAY and stat:GetEvaluatedTears(player) < 30 / 11 then
            stat:AddTearsModifier(player, function(tears) return 30 / 11 end, 101)
        end
        if cacheFlag == CacheFlag.CACHE_DAMAGE and player.Damage < 3.5 then
            player.Damage = 3.5
        end
        if cacheFlag == CacheFlag.CACHE_RANGE and player.TearRange < 260 then
            player.TearRange = 260
            player.TearHeight = -23.75
        end
        if cacheFlag == CacheFlag.CACHE_SHOTSPEED and player.ShotSpeed < 1 then
            player.ShotSpeed = 1
        end
        if cacheFlag == CacheFlag.CACHE_LUCK and player.Luck < 0 then
            player.Luck = 0
        end
    end
end
ConservativeTreatment:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, ConservativeTreatment.EvaluateCache)

function ConservativeTreatment:PostAddCollectible(type, charge, firstTime, slot, varData, player)
    if player:GetHealthType() == HealthType.BONE then
        if player:GetBoneHearts() < 3 then
            player:AddBoneHearts(3 - player:GetBoneHearts())
            player:AddHearts(math.max(0, 6 - player:GetHearts()))
        end
    elseif player:GetHealthType() == HealthType.RED or player:GetHealthType() == HealthType.KEEPER then
        if player:GetMaxHearts() < 6 then
            player:AddMaxHearts(6 - player:GetMaxHearts())
            player:AddHearts(math.max(0, 6 - player:GetHearts()))
        end
    elseif player:GetHealthType() == HealthType.SOUL then
        if player:GetSoulHearts() < 6 then
            player:AddSoulHearts(6 - player:GetSoulHearts())
        end
    end
end
ConservativeTreatment:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, ConservativeTreatment.PostAddCollectible, ty.CustomCollectibles.CONSERVATIVETREATMENT)

return ConservativeTreatment