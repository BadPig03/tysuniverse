local Room = ty:DefineANewClass()

function Room:PostNewRoom()
    local room = ty.GAME:GetRoom()
    for i = 1, ty.ITEMCONFIG:GetCollectibles().Size - 1 do
        if ItemConfig.Config.IsValidCollectible(i) and ty.ITEMCONFIG:GetCollectible(i):HasCustomTag("nolazarus") then
            ty.ITEMPOOL:AddRoomBlacklist(i)
            ty.ITEMPOOL:RemoveCollectible(i)
        end
    end
end
Room:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Room.PostNewRoom)

function Room:PreAddCollectible(id, charge, firstTime, slot, varData, player)
    if ItemConfig.Config.IsValidCollectible(id) and ty.ITEMCONFIG:GetCollectible(id):HasCustomTag("nolazarus") and (player:GetPlayerType() == PlayerType.PLAYER_LAZARUS_B or player:GetPlayerType() == PlayerType.PLAYER_LAZARUS2_B) then
        return CollectibleType.COLLECTIBLE_BREAKFAST
    end
end
Room:AddCallback(ModCallbacks.MC_PRE_ADD_COLLECTIBLE, Room.PreAddCollectible)

return Room