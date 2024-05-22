local BethsSalvation = ty:DefineANewClass()

local function CanTeleportToAngelRoom(player)
    if PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_EUCHARIST) then
        return true
    elseif player:GetTrinketRNG(ty.CustomTrinkets.BETHSSALVATION):RandomInt(100) < 50 then
        return true
    end
    return false
end

function BethsSalvation:PostNewLevel()
    local multiplier = PlayerManager.GetTotalTrinketMultiplier(ty.CustomTrinkets.BETHSSALVATION)
    local firstPlayer = Isaac.GetPlayer(0)
    if multiplier > 0 and CanTeleportToAngelRoom(firstPlayer) then
        ty.LEVEL:InitializeDevilAngelRoom(true, false)
        ty.GAME:StartRoomTransition(GridRooms.ROOM_DEVIL_IDX, Direction.NO_DIRECTION, RoomTransitionAnim.TELEPORT, firstPlayer, Dimension.CURRENT)    
    end
end
BethsSalvation:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, BethsSalvation.PostNewLevel)

return BethsSalvation