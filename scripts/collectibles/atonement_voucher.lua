local AtonementVoucher = ty:DefineANewClass()

local function IsAngelRoomOpened()
    local room = ty.GAME:GetRoom()
    for i = 0, 7 do
        local door = room:GetDoor(i)
        if door and door.TargetRoomType == RoomType.ROOM_DEVIL and door.TargetRoomIndex == GridRooms.ROOM_DEVIL_IDX then
            room:RemoveDoor(i)
        end
    end
    for i = 0, 7 do
        local door = room:GetDoor(i)
        if door and door.TargetRoomType == RoomType.ROOM_ANGEL and door.TargetRoomIndex == GridRooms.ROOM_DEVIL_IDX then
            return true
        end
    end
    return false
end

local function ForceOpenAngelRoom(player)
    local room = ty.GAME:GetRoom()
    local data = ty:GetLibData(player)
    local roomData = ty.LEVEL:GetRoomByIdx(GridRooms.ROOM_DEVIL_IDX).Data
    if roomData and roomData.Type == RoomType.ROOM_DEVIL then
        ty.LEVEL:GetRoomByIdx(GridRooms.ROOM_DEVIL_IDX).Data = nil
    end
    ty.LEVEL:InitializeDevilAngelRoom(true, false)
    room:TrySpawnDevilRoomDoor(not data.AtonementVoucher.Effected, true)
end

function AtonementVoucher:PostPlayerUpdate(player)
    local room = ty.GAME:GetRoom()
    local data = ty:GetLibData(player)
    if data.Init and data.AtonementVoucher then
        if room:GetType() == RoomType.ROOM_DEVIL then
            data.AtonementVoucher.DevilRoomVisited = true
        end
        if player:HasCollectible(ty.CustomCollectibles.ATONEMENTVOUCHER) then
            if ty.GAME:GetDevilRoomDeals() > 0 or data.AtonementVoucher.DevilRoomVisited then
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_REDEMPTION, room:FindFreePickupSpawnPosition(player.Position, 0, true), Vector(0, 0), nil)
                player:RemoveCollectible(ty.CustomCollectibles.ATONEMENTVOUCHER)
            else
                if room:IsClear() and room:GetType() == RoomType.ROOM_BOSS and not IsAngelRoomOpened() then
                    ForceOpenAngelRoom(player)
                    data.AtonementVoucher.Effected = true
                end
            end
        end
    end
end
AtonementVoucher:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, AtonementVoucher.PostPlayerUpdate)

function AtonementVoucher:PostDevilCalculate()
    for _, player in pairs(PlayerManager.GetPlayers()) do
        local data = ty:GetLibData(player)
        if data.AtonementVoucher and data.AtonementVoucher.Effected then
            return 0
        end
    end
end
AtonementVoucher:AddCallback(ModCallbacks.MC_POST_DEVIL_CALCULATE, AtonementVoucher.PostDevilCalculate)

function AtonementVoucher:PostNewLevel()
    for _, player in pairs(PlayerManager.GetPlayers()) do
        local data = ty:GetLibData(player)
        if data.AtonementVoucher.Effected then
            player:RemoveCollectible(ty.CustomCollectibles.ATONEMENTVOUCHER)
        end
        data.AtonementVoucher.Effected = false
    end
end
AtonementVoucher:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, AtonementVoucher.PostNewLevel)

return AtonementVoucher