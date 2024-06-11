local Room = ty:DefineANewClass()

function Room:PostNewLevel()
    if PlayerManager.AnyoneIsPlayerType(PlayerType.PLAYER_LAZARUS_B) or PlayerManager.AnyoneIsPlayerType(PlayerType.PLAYER_LAZARUS2_B) then
        for i = 1, ty.ITEMCONFIG:GetCollectibles().Size - 1 do
            if ItemConfig.Config.IsValidCollectible(i) and ty.ITEMCONFIG:GetCollectible(i):HasCustomTag("nolazarus") and ty.ITEMPOOL:HasCollectible(i) then
                ty.ITEMPOOL:RemoveCollectible(i)
            end
        end
    end
end
Room:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, Room.PostNewLevel)

function Room:PreAddCollectible(id, charge, firstTime, slot, varData, player)
    local playerType = player:GetPlayerType()
    if ItemConfig.Config.IsValidCollectible(id) and ty.ITEMCONFIG:GetCollectible(id):HasCustomTag("nolazarus") and (playerType == PlayerType.PLAYER_LAZARUS_B or playerType == PlayerType.PLAYER_LAZARUS2_B) then
        return CollectibleType.COLLECTIBLE_BREAKFAST
    end
end
Room:AddCallback(ModCallbacks.MC_PRE_ADD_COLLECTIBLE, Room.PreAddCollectible)

return Room