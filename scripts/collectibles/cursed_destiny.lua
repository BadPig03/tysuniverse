local CursedDestiny = ty:DefineANewClass()

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

local function RevealRooms()
    for i = 0, 168 do
        local room = ty.LEVEL:GetRoomByIdx(i)
        if room.Data and (room.Data.Type == RoomType.ROOM_BOSS or room.Data.Type == RoomType.ROOM_SECRET) then
            room.DisplayFlags = 1 << 2
        end
    end
    ty.LEVEL:ApplyMapEffect()
    ty.LEVEL:UpdateVisibility()
    ty.LEVEL:RemoveCurses(LevelCurse.CURSE_OF_THE_LOST)
end

function CursedDestiny:EvaluateCache(player, cacheFlag)
    if not ty.GAME:GetRoom():HasCurseMist() then
        local data = ty:GetLibData(player)
        if cacheFlag == CacheFlag.CACHE_SPEED then
            player.MoveSpeed = player.MoveSpeed + data.CursedDestiny.Reward * 0.1
        end
        if cacheFlag == CacheFlag.CACHE_FIREDELAY then
            ty.Stat:AddTearsModifier(player, function(tears) return tears + 0.25 * data.CursedDestiny.Reward end)
        end
        if cacheFlag == CacheFlag.CACHE_DAMAGE then
            ty.Stat:AddFlatDamage(player, data.CursedDestiny.Reward * 0.5)
        end
        if cacheFlag == CacheFlag.CACHE_RANGE then
            player.TearRange = player.TearRange + data.CursedDestiny.Reward * 50
        end
        if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
            player.ShotSpeed = player.ShotSpeed + data.CursedDestiny.Reward * 0.1
        end
        if cacheFlag == CacheFlag.CACHE_LUCK then
            player.Luck = player.Luck + data.CursedDestiny.Reward * 0.5
        end  
    end
end
CursedDestiny:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, CursedDestiny.EvaluateCache)

function CursedDestiny:PreLevelPlaceRoom(levelGeneratorRoom, roomConfigRoom, seed)
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
CursedDestiny:AddCallback(ModCallbacks.MC_PRE_LEVEL_PLACE_ROOM, CursedDestiny.PreLevelPlaceRoom)

function CursedDestiny:PostLevelLayoutGenerated(levelGenerator)
    if IsValidStage() then
        newLevel = true
        ty.PERSISTENTDATA.LevelGeneratorRooms = {}
        ty.PERSISTENTDATA.ShortestPath = {}    
    end
end
CursedDestiny:AddCallback(ModCallbacks.MC_POST_LEVEL_LAYOUT_GENERATED, CursedDestiny.PostLevelLayoutGenerated)

function CursedDestiny:PostNewLevel()
    if IsValidStage() and newLevel then
        local rooms = ty.PERSISTENTDATA.LevelGeneratorRooms
        for i, room in pairs(rooms) do
            rooms[i].Neighbors = GetNeighbors(rooms[i].Neighbors)
        end
        ty.PERSISTENTDATA.ShortestPath = FindShortestPath()
        newLevel = false
    end
    if ty.GLOBALDATA.CursedDestiny then
        ty.GLOBALDATA.CursedDestiny.OutOfBounds = false
    end
end
CursedDestiny:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, CursedDestiny.PostNewLevel)

function CursedDestiny:PreSpawnCleanAward(rng, spawnPosition)
    local room = ty.GAME:GetRoom()
    if IsValidStage() and PlayerManager.AnyoneHasCollectible(ty.CustomCollectibles.CURSEDDESTINY) and room:GetType() == RoomType.ROOM_BOSS and ty.LEVEL:GetCurrentRoomIndex() == ty:GetLastBossRoomIndex() then
        for _, player in pairs(PlayerManager.GetPlayers()) do
            if player:HasCollectible(ty.CustomCollectibles.CURSEDDESTINY) then
                local data = ty:GetLibData(player)
                if not ty.GLOBALDATA.CursedDestiny.OutOfBounds then
                    local stage = ty.LEVEL:GetAbsoluteStage()
                    local devilRoom = ty.LEVEL:GetRoomByIdx(GridRooms.ROOM_DEVIL_IDX)
                    if devilRoom.Data and devilRoom.Data.Type == RoomType.ROOM_ANGEL then
                        local item = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, ty.ITEMPOOL:GetCollectible(ItemPoolType.POOL_DEVIL, true, rng:Next()), room:FindFreePickupSpawnPosition(room:GetCenterPos(), 0, true), Vector(0, 0), nil):ToPickup()
                        item:MakeShopItem(-2)
                    end
                    if ty.LEVEL:CanSpawnDevilRoom() and not IsDevilAngelRoomOpened() then
                        room:TrySpawnDevilRoomDoor(true, true) 
                    end
                    data.CursedDestiny.Reward = data.CursedDestiny.Reward + 1
                end
                data.CursedDestiny.Reward = data.CursedDestiny.Reward + 1
                player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
                player:AnimateHappy()
            end
        end
    end
end
CursedDestiny:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, CursedDestiny.PreSpawnCleanAward)

function CursedDestiny:PostAddCollectible(type, charge, firstTime, slot, varData, player)
    if IsValidStage() and PlayerManager.AnyoneHasCollectible(ty.CustomCollectibles.CURSEDDESTINY) then
        RevealRooms()
    end
end
CursedDestiny:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, CursedDestiny.PostAddCollectible, ty.CustomCollectibles.CURSEDDESTINY)

function CursedDestiny:PostNewRoom()
    local roomIndex = ty.LEVEL:GetRoomByIdx(ty.LEVEL:GetCurrentRoomIndex()).SafeGridIndex
    if PlayerManager.AnyoneHasCollectible(ty.CustomCollectibles.CURSEDDESTINY) and not ty.GLOBALDATA.CursedDestiny.OutOfBounds and roomIndex == ty:GetLastBossRoomIndex() then
        for _, player in pairs(PlayerManager.GetPlayers()) do
            local effects = player:GetEffects()
            if player:HasCollectible(ty.CustomCollectibles.CURSEDDESTINY) and not effects:HasCollectibleEffect(CollectibleType.COLLECTIBLE_WAFER) then
                effects:AddCollectibleEffect(CollectibleType.COLLECTIBLE_WAFER)
            end
        end
    end
    if IsValidStage() and PlayerManager.AnyoneHasCollectible(ty.CustomCollectibles.CURSEDDESTINY) then
        RevealRooms()
    end
end
CursedDestiny:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, CursedDestiny.PostNewRoom)

function CursedDestiny:GetShaderParams(shaderName)
    local pos, pos2 = Isaac.GetPlayer().Position, Isaac.GetPlayer(1).Position
    local distances = {192, 192, 64, 64}
    local active = 0
	if IsValidStage() and PlayerManager.AnyoneHasCollectible(ty.CustomCollectibles.CURSEDDESTINY) and shaderName == "GuidanceOfDestinyDarkness" then
        local room = ty.GAME:GetRoom()
        local roomIndex = ty.LEVEL:GetRoomByIdx(ty.LEVEL:GetCurrentRoomIndex()).SafeGridIndex
        if not ty:IsValueInTable(roomIndex, ty.PERSISTENTDATA.ShortestPath) and roomIndex >= 0 then
            ty.GAME:Darken(1, 1)
            active = 0.9
            if not ty.GLOBALDATA.CursedDestiny.OutOfBounds then
                ty.GLOBALDATA.CursedDestiny.OutOfBounds = true
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
CursedDestiny:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, CursedDestiny.GetShaderParams)

return CursedDestiny