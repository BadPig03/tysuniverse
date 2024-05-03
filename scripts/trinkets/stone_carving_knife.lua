local StoneCarvingKnife = ty:DefineANewClass()

function StoneCarvingKnife:PostGridRockDestroy(rock, type, immediate)
    local multiplier = PlayerManager.GetTotalTrinketMultiplier(ty.CustomTrinkets.STONECARVINGKNIFE)
    if rock:ToRock() and multiplier > 0 then
        local seed = rock.Desc.SpawnSeed
        local rng = RNG(seed)
        if rng:RandomFloat() < multiplier * 0.03 then
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, ty.ITEMPOOL:GetCard(seed, false, true, true), rock.Position, rng:RandomVector() * rng:RandomInt(2, 5), nil)
        end
    end
end
StoneCarvingKnife:AddCallback(ModCallbacks.MC_POST_GRID_ROCK_DESTROY, StoneCarvingKnife.PostGridRockDestroy)

return StoneCarvingKnife