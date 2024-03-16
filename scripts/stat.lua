local Stat = ty:DefineANewClass()

local function GetPlayerData(player, init)
    local data = ty:GetLibData(player)
    if init then
        data.Stat = data.Stat or { Damage = { Multiplier = 1, DamageUp = 0, Flat = 0 }, Speed = { Limit = -1 }, Tears = { TearsUp = 0, Modifiers = {} } }
    end
    return data.Stat
end

local function ResetDamageCaches(player)
    local data = GetPlayerData(player, true)
    data.Damage.Multiplier = 1
    data.Damage.DamageUp = 0
    data.Damage.Flat = 0
end

local function ResetTearsCaches(player)
    local data = GetPlayerData(player, true)
    data.Tears.TearsUp = 0
    data.Tears.Modifiers = {}
end

function Stat:GetVanillaCharacterDamage(player)
    local damage = 3.5
    local playerType = player:GetPlayerType()
    local playerMulti = ty.CharacterMultipliers[playerType]
    if playerMulti then
        if type(playerMulti)== "function" then
            damage = damage * playerMulti(player)
        else
            damage = damage * playerMulti
        end
    end
    return damage
end

function Stat:GetVanillaDamageMultiplier(player)
    local multiplier = 1
    for id, multi in pairs(ty.CollectibleMultipliers) do
        if multi then
            if player:HasCollectible(id) then
                if type(multi)== "function" then
                    multiplier = multiplier * multi(player)
                else
                    multiplier = multiplier * multi
                end
            end
        end
    end
    return multiplier
end

function Stat:GetVanillaFlatDamage(player)
    local damage = 0
    for id, flat in pairs(ty.CollectibleFlatDamages) do
        if flat then
            local num = player:GetCollectibleNum(id)
            if num > 0 then
                if type(flat)== "function" then
                    damage = damage + flat(player, num)
                else
                    damage = damage + flat * num
                end
            end
        end
    end
    for id, flat in pairs(ty.TrinketFlatDamages) do
        if flat then
            local num = player:GetTrinketMultiplier(id)
            if num > 0 then
                if type(flat)== "function" then
                    damage = damage + flat(player, num)
                else
                    damage = damage + flat * num
                end
            end
        end
    end
    return damage
end

function Stat:GetAddFireRate(firedelay, addition)
    return 30 / (30 / (firedelay + 1) + addition) - 1
end

function Stat:GetDamageUp(player)
    local data = GetPlayerData(player, false)
    return (data and data.Damage.DamageUp) or 0
end

function Stat:SetDamageUp(player, value)
    local data = GetPlayerData(player, true)
    data.Damage.DamageUp = value
end

function Stat:AddDamageUp(player, value)
    local data = GetPlayerData(player, true)
    data.Damage.DamageUp = data.Damage.DamageUp + value
end

function Stat:GetFlatDamage(player)
    local data = GetPlayerData(player, false)
    return (data and data.Damage.Flat) or 0
end

function Stat:SetFlatDamage(player, value)
    local data = GetPlayerData(player, true)
    data.Damage.Flat = value
end

function Stat:AddFlatDamage(player, value)
    local data = GetPlayerData(player, true)
    data.Damage.Flat = data.Damage.Flat + value
end

function Stat:GetDamageMultiplier(player)
    local data = GetPlayerData(player, false)
    return (data and data.Damage.Multiplier) or 1
end

function Stat:SetDamageMultiplier(player, value)
    local data = GetPlayerData(player, true)
    data.Damage.Multiplier = value
end

function Stat:MultiplyDamage(player, value)
    local data = GetPlayerData(player, true)
    data.Damage.Multiplier = data.Damage.Multiplier * value
end

function Stat:GetTearsUp(player)
    local data = GetPlayerData(player, false)
    return (data and data.Tears.TearsUp) or 0
end

function Stat:SetTearsUp(player, value)
    local data = GetPlayerData(player, true)
    data.Tears.TearsUp = value
end

function Stat:AddTearsUp(player, value)
    local data = GetPlayerData(player, true)
    data.Tears.TearsUp = data.Tears.TearsUp + value
end

function Stat:AddTearsModifier(player, func, priority)
    priority = priority or 0
    local data = GetPlayerData(player, true)
    table.insert(data.Tears.Modifiers, {Func = func, Priority = priority} )
end

function Stat:GetSpeedLimit(player)
    local data = GetPlayerData(player, false)
    if data then
        return data.Speed.Limit
    end
    return -1
end

function Stat:SetSpeedLimit(player, value)
    local data = GetPlayerData(player, true)
    data.Speed.Limit = value
end

function Stat:AddSpeed(player, value)
    player.MoveSpeed = player.MoveSpeed + value
end

function Stat:MultiplySpeed(player, value)
    player.MoveSpeed = player.MoveSpeed * value
end

function Stat:GetEvaluatedDamage(player)
    local data = GetPlayerData(player, false)
    local originDamage = player.Damage
    local characterDamage = Stat:GetVanillaCharacterDamage(player)
    local oMulti = Stat:GetVanillaDamageMultiplier(player)
    local oFlat = Stat:GetVanillaFlatDamage(player)
    local oDamageUps = (((originDamage / oMulti - oFlat) / characterDamage) ^ 2 - 1 ) / 1.2
    local totalDamage = oDamageUps
    local flat = oFlat
    local multiplier = oMulti
    if data then
        totalDamage = totalDamage + data.Damage.DamageUp
        flat = flat + data.Damage.Flat
        multiplier = multiplier * data.Damage.Multiplier
    end
    return (characterDamage * (totalDamage * 1.2 + 1) ^ 0.5 + flat) * multiplier
end

function Stat:GetEvaluatedTears(player)
    local data = GetPlayerData(player, false)
    local origin = 30 / (player.MaxFireDelay + 1)
    local tears = origin
    if data then
        local modMultiplier = 1
        local maxTearsUp = 2
        local maxMultiplier = 1.4
        local minMultiplier = 0.6
        local modTearsUp = data.Tears.TearsUp
        if modTearsUp > maxTearsUp then
            modMultiplier = maxMultiplier
        elseif modTearsUp > 0 then
            modMultiplier = -((maxMultiplier - 1) / maxTearsUp ^ 2) * (modTearsUp - maxTearsUp) ^ 2 + maxMultiplier
        else
            modMultiplier = (1 - minMultiplier) * (0.5 ^ modTearsUp - 1) + 1
        end
        tears = tears * modMultiplier
        table.sort(data.Tears.Modifiers, function(a, b) return a.Priority < b.Priority end)
        for _, modi in ipairs(data.Tears.Modifiers) do
            tears = modi.Func(tears, origin)
        end
    end
    return tears
end

function Stat:EvaluateCache(player, cache)
    if cache == CacheFlag.CACHE_DAMAGE then
        player.Damage = Stat:GetEvaluatedDamage(player)
        ResetDamageCaches(player)
    elseif cache == CacheFlag.CACHE_FIREDELAY then
        player.MaxFireDelay = 30 / Stat:GetEvaluatedTears(player) - 1
        ResetTearsCaches(player)
    elseif cache == CacheFlag.CACHE_SPEED then
        local limit = Stat:GetSpeedLimit(player)
        if limit >= 0 then
            player.MoveSpeed = math.min(limit, player.MoveSpeed)
        end
        Stat:SetSpeedLimit(player, -1)
    end
end
Stat:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, CallbackPriority.LATE, Stat.EvaluateCache)
--[[
function Stat:PostUsePill(pillEffect, player, useFlags, pillColor)
    local data = ty:GetLibData(player)
    local giantFlag = 1
    if pillColor & PillColor.PILL_GIANT_FLAG == PillColor.PILL_GIANT_FLAG then
        giantFlag = 2
    end
    if pillEffect == PillEffect.PILLEFFECT_LARGER then
        data.PlayerSize.Larger = data.PlayerSize.Larger + giantFlag
    elseif pillEffect == PillEffect.PILLEFFECT_SMALLER then
        data.PlayerSize.Smaller = data.PlayerSize.Smaller + giantFlag
    end
end
Stat:AddCallback(ModCallbacks.MC_USE_PILL, Stat.PostUsePill)

function Stat:PostUseHugeGrowthCard(card, player, useFlags)
    local data = ty:GetLibData(player)
    if data.PlayerSize.HugeGrowth == 0 then
        data.PlayerSize.HugeGrowth = 1
    end
end
Stat:AddCallback(ModCallbacks.MC_USE_CARD, Stat.PostUseHugeGrowthCard, Card.CARD_HUGE_GROWTH)

function Stat:ResetHugeGrowthScale()
    for _, player in pairs(PlayerManager.GetPlayers()) do
        local data = ty:GetLibData(player)
        if data.Init and data.PlayerSize.HugeGrowth == 1 then
            data.PlayerSize.HugeGrowth = 0
        end    
    end
end
Stat:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Stat.ResetHugeGrowthScale)

function Stat:PostPlayerUpdate(player)
    local data = ty:GetLibData(player)
    if data.Init and data.PlayerSize then
        local size = 1
        local effects = player:GetEffects()
        size = size * 0.5 ^ (player:GetCollectibleNum(CollectibleType.COLLECTIBLE_PLUTO) + effects:GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_INNER_CHILD))
        size = size * 0.8 ^ (player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BINKY) + player:GetCollectibleNum(CollectibleType.COLLECTIBLE_MINI_MUSH) + data.PlayerSize.Smaller)
        size = size * 1.2 ^ player:GetCollectibleNum(CollectibleType.COLLECTIBLE_LEO)
        size = size * 1.25 ^ (player:GetCollectibleNum(CollectibleType.COLLECTIBLE_MAGIC_MUSHROOM) + data.PlayerSize.Larger)
        size = size * 1.6 ^ data.PlayerSize.HugeGrowth
        data.PlayerSize.Scale = size
    end
end
Stat:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Stat.PostPlayerUpdate)
]]
return Stat