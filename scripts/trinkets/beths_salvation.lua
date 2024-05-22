local BethsSalvation = ty:DefineANewClass()

function BethsSalvation:PostNewLevel()
    local multiplier = PlayerManager.GetTotalTrinketMultiplier(ty.CustomTrinkets.BETHSSALVATION)
    if multiplier > 0 and ty.LEVEL:GetDevilAngelRoomRNG():RandomInt(100) < 50 then
        ty.LEVEL:InitializeDevilAngelRoom(true, false)
        ty.GAME:StartRoomTransition(GridRooms.ROOM_DEVIL_IDX, Direction.NO_DIRECTION, RoomTransitionAnim.TELEPORT, Isaac.GetPlayer(0), Dimension.CURRENT)
    end
end
BethsSalvation:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, BethsSalvation.PostNewLevel)

return BethsSalvation