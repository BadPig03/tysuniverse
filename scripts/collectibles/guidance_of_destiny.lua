local GuidanceOfDestiny = ty:DefineANewClass()

local roomGenerationIndices = {}
local newLevel = false

local function FindShortestPath(start, target)
    start = start or ty.LEVEL:GetStartingRoomIndex()
    target = target or ty:GetLastBossRoomIndex()

    local function GetNeighborsByGridIndex(gridIndex)
        local rooms = ty.PERSISTENTDATA.LevelGeneratorRooms
        for _, roomIndex in pairs(rooms) do
            if roomIndex.GridIndex == gridIndex then
                return roomIndex.Neighbors
            end
        end
    end

    local queue = {{start}}
    local visited = {[start] = true}
    while #queue > 0 do
        local path = table.remove(queue, 1)
        local current = path[#path]
        if current == target then
            return path
        end
        local neighbors = GetNeighborsByGridIndex(current)
        for _, neighbor in pairs(neighbors) do
            if not visited[neighbor] then
                visited[neighbor] = true
                local new_path = {table.unpack(path)}
                table.insert(new_path, neighbor)
                table.insert(queue, new_path)
            end
        end
    end
    return nil
end

local function GetNeighbors(rooms)
    local neighbors = {}
    for _, i in pairs(rooms) do
        table.insert(neighbors, ty.PERSISTENTDATA.LevelGeneratorRooms[i].GridIndex)
    end
    table.sort(neighbors)
    return neighbors
end

local function IsValidRoomDoor(door)
    return not (door:IsRoomType(RoomType.ROOM_ERROR) or door:IsRoomType(RoomType.ROOM_BOSS) or door:IsRoomType(RoomType.ROOM_SECRET) or door:IsRoomType(RoomType.ROOM_SUPERSECRET) or door:IsRoomType(RoomType.ROOM_DEVIL) or door:IsRoomType(RoomType.ROOM_ANGEL) or door:IsRoomType(RoomType.ROOM_DUNGEON) or door:IsRoomType(RoomType.ROOM_BOSSRUSH) or door:IsRoomType(RoomType.ROOM_BLACK_MARKET) or door:IsRoomType(RoomType.ROOM_GREED_EXIT) or door:IsRoomType(RoomType.ROOM_TELEPORTER) or door:IsRoomType(RoomType.ROOM_TELEPORTER_EXIT) or door:IsRoomType(RoomType.ROOM_SECRET_EXIT) or door:IsRoomType(RoomType.ROOM_BLUE) or door:IsRoomType(RoomType.ROOM_ULTRASECRET)) 
end

local function IsValidStage()
    local stage = ty.LEVEL:GetAbsoluteStage()
    return not (ty.GAME:IsGreedMode() or stage == LevelStage.STAGE4_3 or stage > LevelStage.STAGE7 or ty.LEVEL:IsAscent() or ty.LEVEL:GetDimension() > Dimension.NORMAL)
end

local function IsDevilAngelRoomOpened()
    local room = ty.GAME:GetRoom()
    for i = 0, 7 do
        local door = room:GetDoor(i)
        if door and (door.TargetRoomType == RoomType.ROOM_DEVIL or door.TargetRoomType == RoomType.ROOM_ANGEL) and door.TargetRoomIndex == GridRooms.ROOM_DEVIL_IDX then
            return true
        end
    end
    return false
end

function GuidanceOfDestiny:EvaluateCache(player, cacheFlag)
    local data = ty:GetLibData(player)
    if cacheFlag == CacheFlag.CACHE_SPEED then
        player.MoveSpeed = player.MoveSpeed + data.GuidanceOfDestiny.Reward * 0.15
    end
    if cacheFlag == CacheFlag.CACHE_FIREDELAY then
        ty.Stat:AddTearsModifier(player, function(tears) return tears + 0.5 * data.GuidanceOfDestiny.Reward end)
    end
    if cacheFlag == CacheFlag.CACHE_DAMAGE then
        ty.Stat:AddFlatDamage(player, data.GuidanceOfDestiny.Reward)
    end
    if cacheFlag == CacheFlag.CACHE_RANGE then
        player.TearRange = player.TearRange + data.GuidanceOfDestiny.Reward * 60
    end
    if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
        player.ShotSpeed = player.ShotSpeed + data.GuidanceOfDestiny.Reward * 0.05
    end
    if cacheFlag == CacheFlag.CACHE_LUCK then
        player.Luck = player.Luck + data.GuidanceOfDestiny.Reward
    end
end
GuidanceOfDestiny:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, GuidanceOfDestiny.EvaluateCache)

function GuidanceOfDestiny:PreLevelPlaceRoom(levelGeneratorRoom, roomConfigRoom, seed)
    if IsValidStage() and newLevel then
        local shape = levelGeneratorRoom:Shape()
        local gridIndex = levelGeneratorRoom:Row() * 13 + levelGeneratorRoom:Column()
        if shape == RoomShape.ROOMSHAPE_LTL then
            gridIndex = gridIndex + 1
        end
        ty.PERSISTENTDATA.LevelGeneratorRooms[levelGeneratorRoom:GenerationIndex()] = { Shape = shape, GridIndex = gridIndex, Neighbors = levelGeneratorRoom:Neighbors()}
        for _, neighbor in pairs(levelGeneratorRoom:Neighbors()) do
			if ty.PERSISTENTDATA.LevelGeneratorRooms[neighbor] then
				local flag = true
				for _, neighbor2 in pairs(ty.PERSISTENTDATA.LevelGeneratorRooms[neighbor].Neighbors) do
					if neighbor2 == levelGeneratorRoom:GenerationIndex() then
						flag = false
						break
					end
				end
				if flag then
					table.insert(ty.PERSISTENTDATA.LevelGeneratorRooms[neighbor].Neighbors, levelGeneratorRoom:GenerationIndex())
				end
			end
		end
    end
end
GuidanceOfDestiny:AddCallback(ModCallbacks.MC_PRE_LEVEL_PLACE_ROOM, GuidanceOfDestiny.PreLevelPlaceRoom)

function GuidanceOfDestiny:PostLevelLayoutGenerated(levelGenerator)
    if IsValidStage() then
        newLevel = true
    end
    ty.PERSISTENTDATA.LevelGeneratorRooms = {}
    ty.PERSISTENTDATA.ShortestPath = {}
end
GuidanceOfDestiny:AddCallback(ModCallbacks.MC_POST_LEVEL_LAYOUT_GENERATED, GuidanceOfDestiny.PostLevelLayoutGenerated)

function GuidanceOfDestiny:PostNewLevel()
    if IsValidStage() and newLevel then
        local rooms = ty.PERSISTENTDATA.LevelGeneratorRooms
        for i, room in pairs(rooms) do
            rooms[i].Neighbors = GetNeighbors(rooms[i].Neighbors)
        end
        ty.PERSISTENTDATA.ShortestPath = FindShortestPath()
        newLevel = false
    end
    if ty.GLOBALDATA.GuidanceOfDestiny then
        ty.GLOBALDATA.GuidanceOfDestiny.OutOfBounds = false
        ty.GLOBALDATA.GuidanceOfDestiny.Revealed = false
    end
end
GuidanceOfDestiny:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, GuidanceOfDestiny.PostNewLevel)

function GuidanceOfDestiny:PreSpawnCleanAward(rng, spawnPosition)
    local room = ty.GAME:GetRoom()
    if IsValidStage() and PlayerManager.AnyoneHasCollectible(ty.CustomCollectibles.GUIDANCEOFDESTINY) and room:GetType() == RoomType.ROOM_BOSS and ty.LEVEL:GetCurrentRoomIndex() == ty:GetLastBossRoomIndex() then
        for _, player in pairs(PlayerManager.GetPlayers()) do
            if player:HasCollectible(ty.CustomCollectibles.GUIDANCEOFDESTINY) then
                local data = ty:GetLibData(player)
                if not ty.GLOBALDATA.GuidanceOfDestiny.OutOfBounds then
                    local stage = ty.LEVEL:GetAbsoluteStage()
                    local devilRoom = ty.LEVEL:GetRoomByIdx(GridRooms.ROOM_DEVIL_IDX)
                    if devilRoom.Data and devilRoom.Data.Type == RoomType.ROOM_ANGEL then
                        local item = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, ty.ITEMPOOL:GetCollectible(ItemPoolType.POOL_DEVIL, true, rng:Next()), room:FindFreePickupSpawnPosition(room:GetCenterPos(), 0, true), Vector(0, 0), nil):ToPickup()
                        item:MakeShopItem(-2)
                    end
                    if stage >= LevelStage.STAGE1_2 and stage <= LevelStage.STAGE4_2 and not IsDevilAngelRoomOpened() then
                        room:TrySpawnDevilRoomDoor(true, true) 
                    end
                end
                local rng = player:GetCollectibleRNG(ty.CustomCollectibles.GUIDANCEOFDESTINY)
                data.GuidanceOfDestiny.Reward = data.GuidanceOfDestiny.Reward + 1
                player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
                player:AnimateHappy()
            end
        end
    end
end
GuidanceOfDestiny:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, GuidanceOfDestiny.PreSpawnCleanAward)

function GuidanceOfDestiny:PostUpdate()
    if IsValidStage() and PlayerManager.AnyoneHasCollectible(ty.CustomCollectibles.GUIDANCEOFDESTINY) and not ty.GLOBALDATA.GuidanceOfDestiny.Revealed then
        for i = 0, 168 do
            local room = ty.LEVEL:GetRoomByIdx(i)
            if room.Data and (room.Data.Type == RoomType.ROOM_BOSS or room.Data.Type == RoomType.ROOM_SECRET) then
                room.DisplayFlags = 1 << 2
            end
        end
        ty.LEVEL:ApplyMapEffect()
        ty.LEVEL:UpdateVisibility()
        ty.GLOBALDATA.GuidanceOfDestiny.Revealed = true
    end
end
GuidanceOfDestiny:AddCallback(ModCallbacks.MC_POST_UPDATE, GuidanceOfDestiny.PostUpdate)

function GuidanceOfDestiny:PostNewRoom()
    local roomIndex = ty.LEVEL:GetRoomByIdx(ty.LEVEL:GetCurrentRoomIndex()).SafeGridIndex
    if PlayerManager.AnyoneHasCollectible(ty.CustomCollectibles.GUIDANCEOFDESTINY) and not ty.GLOBALDATA.GuidanceOfDestiny.OutOfBounds and roomIndex == ty:GetLastBossRoomIndex() then
        for _, player in pairs(PlayerManager.GetPlayers()) do
            local effects = player:GetEffects()
            if player:HasCollectible(ty.CustomCollectibles.GUIDANCEOFDESTINY) and not effects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_WAFER) then
                effects:AddCollectibleEffect(CollectibleType.COLLECTIBLE_WAFER)
            end
        end
    end
end
GuidanceOfDestiny:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, GuidanceOfDestiny.PostNewRoom)

function GuidanceOfDestiny:GetShaderParams(shaderName)
    local pos, pos2 = Isaac.GetPlayer().Position, Isaac.GetPlayer(1).Position
    local distances = {192, 192, 64, 64}
    local active = 0
	if IsValidStage() and PlayerManager.AnyoneHasCollectible(ty.CustomCollectibles.GUIDANCEOFDESTINY) and shaderName == "GuidanceOfDestinyDarkness" then
        local room = ty.GAME:GetRoom()
        local roomIndex = ty.LEVEL:GetRoomByIdx(ty.LEVEL:GetCurrentRoomIndex()).SafeGridIndex
        if not ty:IsValueInTable(roomIndex, ty.PERSISTENTDATA.ShortestPath) and roomIndex >= 0 then
            ty.GAME:Darken(1, 1)
            active = 0.9
            if not ty.GLOBALDATA.GuidanceOfDestiny.OutOfBounds then
                ty.GLOBALDATA.GuidanceOfDestiny.OutOfBounds = true
            end
        end
        if PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_NIGHT_LIGHT) or PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_BLACK_CANDLE) then
            distances = {256, 256, 96, 96}
        end
    else
        return { ActiveIn = 0 }
    end
    local edgePos = Isaac.WorldToScreen(pos + Vector(distances[1], 0))
    local edgePos2 = Isaac.WorldToScreen(pos2 + Vector(distances[2], 0))
    local fadePos = Isaac.WorldToScreen(pos + Vector(distances[3], 0))
    local fadePos2 = Isaac.WorldToScreen(pos2 + Vector(distances[4], 0))
    pos, pos2 = Isaac.WorldToScreen(pos), Isaac.WorldToScreen(pos2)
    return {
        ActiveIn = active,
        TargetPositionOne = {pos.X, pos.Y, edgePos.X, edgePos.Y},
        TargetPositionTwo = {pos2.X, pos2.Y, edgePos2.X, edgePos2.Y},
        FadePositions = {fadePos.X, fadePos.Y, fadePos2.X, fadePos2.Y},
        WarpCheck = {pos.X + 1, pos.Y + 1}
    }
end
GuidanceOfDestiny:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, GuidanceOfDestiny.GetShaderParams)

return GuidanceOfDestiny