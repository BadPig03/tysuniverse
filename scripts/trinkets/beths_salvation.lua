local BethsSalvation = ty:DefineANewClass()

local function CanTeleportToAngelRoom(player)
    if PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_EUCHARIST) then
        return true
    elseif player:GetTrinketRNG(ty.CustomTrinkets.BETHSSALVATION):RandomInt(100) < 50 then
        return true
    end
    return false
end

function BethsSalvation:PostPlayerNewLevel(player)
    local room = ty.GAME:GetRoom()
    if room:IsFirstVisit() and ty.LEVEL:GetCurrentRoomIndex() == ty.LEVEL:GetStartingRoomIndex() and not ty.LEVEL:IsAscent() and Isaac.GetChallenge() ~= Challenge.CHALLENGE_BACKASSWARDS then
        local multiplier = PlayerManager.GetTotalTrinketMultiplier(ty.CustomTrinkets.BETHSSALVATION)
        if multiplier > 0 and CanTeleportToAngelRoom(player) then
            Isaac.CreateTimer(function()
                ty.LEVEL:InitializeDevilAngelRoom(true, false)
                ty.GAME:StartRoomTransition(GridRooms.ROOM_DEVIL_IDX, Direction.NO_DIRECTION, RoomTransitionAnim.TELEPORT, player, Dimension.CURRENT)
            end, 1, 0, false)
        end
    end
end
BethsSalvation:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_ROOM_TEMP_EFFECTS, BethsSalvation.PostPlayerNewLevel)

return BethsSalvation