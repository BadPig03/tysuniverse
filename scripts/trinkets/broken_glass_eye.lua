local BrokenGlassEye = ty:DefineANewClass()

local stat = ty.Stat

function BrokenGlassEye:EvaluateCache(player, cacheFlag)
    local multiplier = player:GetTrinketMultiplier(ty.CustomTrinkets.BROKENGLASSEYE)
    if multiplier > 0 then
        if player:HasCollectible(CollectibleType.COLLECTIBLE_INNER_EYE) or player:HasCollectible(CollectibleType.COLLECTIBLE_MUTANT_SPIDER) then
            stat:AddTearsMultiplier(player, math.min(1, 0.1 * multiplier + 0.8))
        else
            stat:AddTearsMultiplier(player, math.min(1, 0.15 * multiplier + 0.45))
        end
    end
end
BrokenGlassEye:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, BrokenGlassEye.EvaluateCache, CacheFlag.CACHE_FIREDELAY)

function BrokenGlassEye:PostPlayerGetMultiShotParams(player)
    local weapon = player:GetWeapon(1)
    if weapon then
        local weaponType = weapon:GetWeaponType()
        local params = player:GetMultiShotParams(weaponType)
        local multiplier = player:GetTrinketMultiplier(ty.CustomTrinkets.BROKENGLASSEYE)
        if multiplier > 0 then
            local totalNum = math.min(16, params:GetNumTears() + 1)
            params:SetNumTears(totalNum)
            params:SetNumLanesPerEye(totalNum)
            params:SetNumEyesActive(params:GetNumEyesActive())
            params:SetMultiEyeAngle(params:GetMultiEyeAngle())
            if weaponType ~= WeaponType.WEAPON_ROCKETS and weaponType ~= WeaponType.WEAPON_MONSTROS_LUNGS and weaponType ~= WeaponType.WEAPON_LUDOVICO_TECHNIQUE and weaponType ~= WeaponType.WEAPON_URN_OF_SOULS and weaponType ~= WeaponType.WEAPON_SPIRIT_SWORD and weaponType ~= WeaponType.WEAPON_UMBILICAL_WHIP then
                params:SetSpreadAngle(weaponType, params:GetSpreadAngle(weaponType))
            end
            return params
        end
    
    end
end
BrokenGlassEye:AddCallback(ModCallbacks.MC_POST_PLAYER_GET_MULTI_SHOT_PARAMS, BrokenGlassEye.PostPlayerGetMultiShotParams)

return BrokenGlassEye