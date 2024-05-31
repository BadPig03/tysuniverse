local Rewind = ty:DefineANewClass()

local roomTypeString = {
    [RoomType.ROOM_SHOP] = 'shop',
    [RoomType.ROOM_ERROR] = 'error',
    [RoomType.ROOM_TREASURE] = 'treasure',
    [RoomType.ROOM_BOSS] = 'boss',
    [RoomType.ROOM_MINIBOSS] = 'miniboss',
    [RoomType.ROOM_SECRET] = 'secret',
    [RoomType.ROOM_SUPERSECRET] = 'supersecret',
    [RoomType.ROOM_ARCADE] = 'arcade',
    [RoomType.ROOM_CURSE] = 'curse',
    [RoomType.ROOM_CHALLENGE] = 'challenge',
    [RoomType.ROOM_LIBRARY] = 'library',
    [RoomType.ROOM_SACRIFICE] = 'sacrifice',
    [RoomType.ROOM_DEVIL] = 'devil',
    [RoomType.ROOM_ANGEL] = 'angel',
    [RoomType.ROOM_ISAACS] = 'isaacs',
    [RoomType.ROOM_BARREN] = 'barren',
    [RoomType.ROOM_CHEST] = 'chest',
    [RoomType.ROOM_DICE] = 'dice',
    [RoomType.ROOM_BLACK_MARKET] = 'blackmarket',
    [RoomType.ROOM_PLANETARIUM] = 'planetarium',
    [RoomType.ROOM_ULTRASECRET] = 'ultrasecret'
}
local roomTypeCharge = {
    [RoomType.ROOM_SHOP] = 5,
    [RoomType.ROOM_ERROR] = 3,
    [RoomType.ROOM_TREASURE] = 8,
    [RoomType.ROOM_BOSS] = 5,
    [RoomType.ROOM_MINIBOSS] = 4,
    [RoomType.ROOM_SECRET] = 6,
    [RoomType.ROOM_SUPERSECRET] = 6,
    [RoomType.ROOM_ARCADE] = 3,
    [RoomType.ROOM_CURSE] = 4,
    [RoomType.ROOM_CHALLENGE] = 5,
    [RoomType.ROOM_LIBRARY] = 8,
    [RoomType.ROOM_SACRIFICE] = 2,
    [RoomType.ROOM_DEVIL] = 12,
    [RoomType.ROOM_ANGEL] = 12,
    [RoomType.ROOM_ISAACS] = 5,
    [RoomType.ROOM_BARREN] = 4,
    [RoomType.ROOM_CHEST] = 4,
    [RoomType.ROOM_DICE] = 4,
    [RoomType.ROOM_BLACK_MARKET] = 8,
    [RoomType.ROOM_PLANETARIUM] = 8,
    [RoomType.ROOM_ULTRASECRET] = 6
}
local bossRoomVariant = {
	[1] = {
		[0] = {1010, 1011, 1012, 1013, 1019, 1020, 1021, 1022, 1023, 1029, 1035, 1036, 1088, 1089, 1095, 1096, 1117, 1118, 1119, 1120, 2010, 2011, 2012, 2013, 2050, 2051, 2052, 2053, 2070, 2071, 2072, 2073, 4010, 4011, 4012, 4013, 5020, 5021, 5022, 5023, 5140, 5141, 5142, 5143, 5146, 5147, 5148, 5149, 5160, 5161, 5162, 5163},
		[1] = {1019, 1029, 1035, 1036, 1088, 1089, 1095, 1096, 2010, 2011, 2012, 2013, 3320, 3321, 3322, 3323, 3340, 3341, 3342, 3343, 3370, 3371, 3372, 3373, 4010, 4011, 4012, 4013, 5010, 5011, 5012, 5013, 5160, 5161, 5162, 5163},
		[2] = {1010, 1011, 1012, 1013, 1019, 1020, 1021, 1022, 1023, 1029, 1035, 1036, 1088, 1089, 1095, 1096, 2010, 2011, 2012, 2013, 4010, 4011, 4012, 4013, 5010, 5011, 5012, 5013, 5140, 5141, 5142, 5143, 5160, 5161, 5162, 5163},
		[4] = {5170, 5171, 5172, 5173, 5180, 5181, 5182, 5183, 5230, 5231, 5232, 5233, 5280, 5281, 5282, 5283},
		[5] = {5170, 5171, 5172, 5173, 5180, 5181, 5182, 5183, 5190, 5191, 5192, 5193, 5320, 5321, 5322, 5322, 5330, 5330, 5330, 5330}
	},
	[2] = {
		[0] = {1030, 1031, 1032, 1033, 1040, 1041, 1042, 1043, 1079, 1085, 1086, 1087, 1100, 1101, 1102, 1103, 1106, 1107, 1108, 1109, 2020, 2021, 2022, 2023, 2060, 2061, 2062, 2063, 3280, 3281, 3282, 3283, 3384, 3385, 3386, 3387, 3394, 3395, 3396, 3397, 3398, 3399, 3404, 3405, 4020, 4021, 4022, 4023, 5030, 5031, 5032, 5033, 5050, 5051, 5052, 5053, 5080, 5081, 5082, 5083, 5270, 5271, 5272, 5273},
		[1] = {1079, 1085, 1086, 1087, 2020, 2021, 2022, 2023, 3260, 3261, 3262, 3263, 3270, 3271, 3272, 3273, 3280, 3281, 3282, 3283, 3290, 3291, 3292, 3293, 3360, 3361, 3362, 3363, 3384, 3385, 3386, 3387, 3394, 3395, 3396, 3397, 3398, 3399, 3404, 3405, 4020, 4021, 4022, 4023, 5080, 5081, 5082, 5083, 5100, 5101, 5102, 5103, 5270, 5271, 5272, 5273}, 
		[2] = {1030, 1031, 1032, 1033, 1040, 1041, 1042, 1043, 1079, 1085, 1086, 1087, 1100, 1101, 1102, 1103, 1106, 1107, 1108, 1109, 2020, 2021, 2022, 2023, 3280, 3281, 3282, 3283, 3384, 3385, 3386, 3387, 3394, 3395, 3396, 3397, 3398, 3399, 3404, 3405, 4020, 4021, 4022, 4023, 5080, 5081, 5082, 5083, 5270, 5271, 5272, 5273},
		[4] = {5200, 5201, 5202, 5203, 5210, 5211, 5212, 5213, 5220, 5221, 5222, 5223, 5250, 5251, 5253, 5254},
		[5] = {5210, 5211, 5212, 5213, 5240, 5241, 5242, 5243, 5260, 5261, 5262, 5263, 5310, 5311, 5312, 5313, 6020, 6021, 6022, 6022}
	},
	[3] = {
		[0] = {1050, 1051, 1052, 1053, 1110, 1111, 1112, 1113, 1097, 1098, 1099, 1105, 2030, 2031, 2032, 2033, 3406, 3407, 3408, 3409, 4030, 4034, 4035, 4036, 5040, 5041, 5042, 5043, 5060, 5061, 5062, 5063, 5090, 5091, 5092, 5093, 5250, 5251, 5252, 5253},
		[1] = {1097, 1098, 1099, 1105, 2030, 2031, 2032, 2033, 3406, 3407, 3408, 3409, 3350, 3351, 3352, 3353, 4030, 4034, 4035, 4036, 5040, 5041, 5042, 5043, 5090, 5091, 5092, 5093, 5240, 5241, 5242, 5243},
		[2] = {1050, 1051, 1052, 1053, 1110, 1111, 1112, 1113, 1097, 1098, 1099, 1105, 2030, 2031, 2032, 2033, 3406, 3407, 3408, 3409, 4030, 4034, 4035, 4036, 5040, 5041, 5042, 5043, 5060, 5061, 5062, 5063, 5090, 5091, 5092, 5093, 5250, 5251, 5252, 5253},
		[4] = {5370, 5371, 5372, 5372, 5290, 5291, 5292, 5293},
		[5] = {5300, 5300, 5301, 5301, 6010, 6011, 6012, 6012}
	},
	[4] = {
		[0] = {1070, 1071, 1072, 1073, 2040, 2041, 2042, 2043, 3300, 3301, 3302, 3303, 3310, 3311, 3312, 3313, 3330, 3331, 3332, 3333, 3400, 3401, 3402, 3403, 3406, 3407, 3408, 3409, 3410, 3411, 3412, 3413, 4031, 4032, 4033, 4033, 4040, 4041, 4042, 4043, 5070, 5071, 5072, 5072, 5110, 5111, 5113, 5113, 5152, 5153, 5154, 5155},
		[1] = {2040, 2041, 2042, 2043, 3300, 3301, 3302, 3303, 3310, 3311, 3312, 3313, 3330, 3331, 3332, 3333, 3400, 3401, 3402, 3403, 3406, 3407, 3408, 3409, 3410, 3411, 3412, 3413, 4031, 4032, 4033, 4033, 4040, 4041, 4042, 4043, 5070, 5071, 5072, 5072, 5110, 5111, 5113, 5113, 5152, 5153, 5154, 5155},
		[2] = {2040, 2041, 2042, 2043, 3300, 3301, 3302, 3303, 3310, 3311, 3312, 3313, 3330, 3331, 3332, 3333, 3400, 3401, 3402, 3403, 3406, 3407, 3408, 3409, 3410, 3411, 3412, 3413, 4031, 4032, 4033, 4033, 4040, 4041, 4042, 4043, 5070, 5071, 5072, 5072, 5110, 5111, 5113, 5113, 5152, 5153, 5154, 5155},
		[4] = {5360, 5361, 5362, 5362, 5350, 5351, 5352, 5352, 5340, 5340, 5340, 5340}
	},
	[10] = {
		[0] = {3380, 3381, 3382, 3383},
		[1] = {3600}
	},
	[11] = {
		[0] = {5130},
		[1] = {3390, 3391, 3392, 3393}
	},
	[12] = {
		[0] = {1010, 1011, 1012, 1013, 1019, 1020, 1021, 1022, 1023, 1029, 1030, 1031, 1032, 1033, 1035, 1036, 1040, 1041, 1042, 1043, 1050, 1051, 1052, 1053, 1070, 1071, 1072, 1073, 1079, 1085, 1086, 1087, 1088, 1089, 1095, 1096, 1097, 1098, 1099, 1100, 1101, 1102, 1103, 1105, 1106, 1107, 1108, 1109, 1110, 1111, 1112, 1113, 1117, 1118, 1119, 1120, 2010, 2011, 2012, 2013, 2020, 2021, 2022, 2023, 2030, 2031, 2032, 2033, 2040, 2041, 2042, 2043, 2050, 2051, 2052, 2053, 2060, 2061, 2062, 2063, 2070, 2071, 2072, 2073, 3260, 3261, 3262, 3263, 3270, 3271, 3272, 3273, 3280, 3281, 3282, 3283, 3290, 3291, 3292, 3293, 3300, 3301, 3302, 3303, 3310, 3311, 3312, 3313, 3320, 3321, 3322, 3323, 3330, 3331, 3332, 3333, 3340, 3341, 3342, 3343, 3350, 3351, 3352, 3353, 3360, 3361, 3362, 3363, 3370, 3371, 3372, 3373, 3380, 3381, 3382, 3383, 3384, 3385, 3386, 3387, 3390, 3391, 3392, 3393, 3394, 3395, 3396, 3397, 3398, 3399, 3400, 3401, 3402, 3403, 3404, 3405, 3406, 3407, 3408, 3409, 3410, 3411, 3412, 3413, 3600, 4010, 4011, 4012, 4013, 4020, 4021, 4022, 4023, 4030, 4031, 4032, 4033, 4034, 4035, 4036, 4040, 4041, 4042, 4043, 5010, 5011, 5012, 5013, 5020, 5021, 5022, 5023, 5030, 5031, 5032, 5033, 5040, 5041, 5042, 5043, 5050, 5051, 5052, 5053, 5060, 5061, 5062, 5063, 5070, 5071, 5072, 5080, 5081, 5082, 5083, 5090, 5091, 5092, 5093, 5100, 5101, 5102, 5103, 5110, 5111, 5113, 5130, 5140, 5141, 5142, 5143, 5146, 5147, 5148, 5149, 5152, 5153, 5154, 5155, 5160, 5161, 5162, 5163, 5240, 5241, 5242, 5243, 5250, 5251, 5252, 5253, 5270, 5271, 5272, 5273}
	}
}
local challengeTriggered = false
local normalTeleport = false

local function IsRoomInfoDuplicated(list, type)
    local count = 0
    for _, item in pairs(list) do
        if item == type then
            count = count + 1
        end
    end
    if count <= 1 then
        return false
    else
        return true
    end
end

local function DoNormalTeleport(player)
	player:UseActiveItem(CollectibleType.COLLECTIBLE_TELEPORT)
	normalTeleport = true
end

local function MoveToNewRoom(roomType, player, rng)
	local data = ty:GetLibData(player)
	if roomType == RoomType.ROOM_SHOP then
		local index = 0
		if PlayerManager.AnyoneIsPlayerType(PlayerType.PLAYER_KEEPER_B) then
			if ty.GAME:IsHardMode() then
				index = rng:RandomInt(7, 11)
			else
				index = ty.GAME:GetRoom():GetShopLevel() + 6
			end
		else
			if ty.GAME:IsHardMode() then
				index = rng:RandomInt(0, 4)
			else
				index = ty.GAME:GetRoom():GetShopLevel() - 1
			end
		end
		Isaac.ExecuteCommand("goto s.shop."..index)
	elseif roomType == RoomType.ROOM_BOSS then
		local index = -1
		local roomList = {}
		local stage = ty.LEVEL:GetAbsoluteStage()
		if stage <= LevelStage.STAGE4_2 then
			roomList = bossRoomVariant[math.ceil(stage / 2)][ty.LEVEL:GetStageType()]
			index = roomList[rng:RandomInt(#roomList) + 1]
		elseif stage == LevelStage.STAGE4_3 then
			Isaac.ExecuteCommand("goto x.boss")
		elseif stage >= LevelStage.STAGE5 and stage <= LevelStage.STAGE7 then
			roomList = bossRoomVariant[stage][ty.LEVEL:GetStageType()]
			index = roomList[rng:RandomInt(#roomList) + 1]
		elseif stage == LevelStage.STAGE8 then
			Isaac.ExecuteCommand("goto x.itemdungeon.666")
		end
		if index ~= -1 then
			Isaac.ExecuteCommand("goto s.boss."..index)
		end
	elseif roomType == RoomType.ROOM_CHALLENGE then
		if challengeTriggered then
			DoNormalTeleport(player)
			data.Rewind.MaxCharge = 3
			return
		else
			challengeTriggered = true
		end
		if rng:RandomInt(100) < 50 then
			Isaac.ExecuteCommand("goto s.challenge."..rng:RandomInt(0, 14))
		else
			Isaac.ExecuteCommand("goto s.challenge."..rng:RandomInt(16, 23))
			data.Rewind.MaxCharge = 6
		end
	elseif roomType == RoomType.ROOM_DEVIL then
		local index = 0
		if PlayerManager.AnyoneHasTrinket(TrinketType.TRINKET_NUMBER_MAGNET) then
			index = rng:RandomInt(0, 34)
		else
			index = rng:RandomInt(0, 23)
		end
		if index == 15 then
			index = 12
		end
		Isaac.ExecuteCommand("goto s.devil."..index)
	elseif roomType == RoomType.ROOM_ANGEL then
		Isaac.ExecuteCommand("goto s.angel."..rng:RandomInt(0, 21))
	elseif roomType == RoomType.ROOM_ISAACS then
		Isaac.ExecuteCommand("goto s.isaacs."..rng:RandomInt(0, 29))
	else
		local roomConfigRoom = RoomConfigHolder.GetRandomRoom(rng:Next(), false, StbType.SPECIAL_ROOMS, roomType)
		Isaac.ExecuteCommand("goto s."..roomTypeString[roomType].."."..roomConfigRoom.Variant)
	end
	ty.GAME:StartRoomTransition(GridRooms.ROOM_DEBUG_IDX, Direction.NO_DIRECTION, RoomTransitionAnim.TELEPORT, player, 0)
end

function Rewind:PreChangeRoom(targetRoomIndex, dimension)
	if normalTeleport and ty.LEVEL:GetRoomByIdx(targetRoomIndex, dimension).Data.Type ~= RoomType.ROOM_DEFAULT then
		normalTeleport = false
		local rng = ty.LEVEL:GetDevilAngelRoomRNG()
		return {ty.LEVEL:QueryRoomTypeIndex(RoomType.ROOM_DEFAULT, rng:RandomInt(100) < 50, rng), dimension}
	end
end
Rewind:AddCallback(ModCallbacks.MC_PRE_CHANGE_ROOM, Rewind.PreChangeRoom)

function Rewind:PostNewRoom()
	local room = ty.GAME:GetRoom()
	local roomDesc = ty.LEVEL:GetCurrentRoomDesc()
	local roomConfigRoom = roomDesc.Data
	local roomType = room:GetType()
	if roomDesc.VisitedCount == 1 and ty.LEVEL:GetCurrentRoomIndex() ~= GridRooms.ROOM_DEBUG_IDX and roomTypeString[roomType] then
		for _, player in pairs(PlayerManager.GetPlayers()) do
			local data = ty:GetLibData(player)
			table.insert(data.Rewind.RoomList, roomType)
		end
	end
	if not PlayerManager.AnyoneHasCollectible(ty.CustomCollectibles.REWIND) then
		return
	end
	if ty.LEVEL:GetCurrentRoomIndex() == GridRooms.ROOM_DEBUG_IDX then
		for i = 0, 7 do
			local door = room:GetDoor(i)
			if door and door.TargetRoomIndex == GridRooms.ROOM_DEBUG_IDX then
				door.TargetRoomIndex = ty.LEVEL:GetStartingRoomIndex()
			end
		end
		if roomType == RoomType.ROOM_BLACK_MARKET then
			if ty.LEVEL:MakeRedRoomDoor(GridRooms.ROOM_DEBUG_IDX, DoorSlot.LEFT0) then
				local door = ty.GAME:GetRoom():GetDoor(DoorSlot.LEFT0)
				door.TargetRoomIndex = ty.LEVEL:GetStartingRoomIndex()
			else
				Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_FOOL, Vector(200, 280), Vector(0, 0), nil)
			end
		end
		if roomType == RoomType.ROOM_CHALLENGE and roomConfigRoom.Variant >= 16 then
			for i = 0, 7 do
				local door = room:GetDoor(i)
				if door then
					local sprite = door:GetSprite()
					sprite:Load("gfx/grid/door_09_bossambushroomdoor.anm2", true)
					sprite:Play("Opened")
				end
			end
		end
	end
end
Rewind:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Rewind.PostNewRoom)

function Rewind:PostNewLevel()
	challengeTriggered = false
end
Rewind:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, Rewind.PostNewLevel)

function Rewind:PostEffectInit(effect)
	local room = ty.GAME:GetRoom()
	if ty.LEVEL:GetCurrentRoomIndex() == GridRooms.ROOM_DEBUG_IDX and room:GetType() == RoomType.ROOM_SHOP then
		effect:Remove()
	end
end
Rewind:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, Rewind.PostEffectInit, EffectVariant.TALL_LADDER)

function Rewind:PostGridEntityDoorUpdate(door)
	local door = door:ToDoor()
	local room = ty.GAME:GetRoom()
	if ty.LEVEL:GetCurrentRoomIndex() == GridRooms.ROOM_DEBUG_IDX and room:IsClear() and not door:IsOpen() then
		if room:GetType() == RoomType.ROOM_SECRET or room:GetType() == RoomType.ROOM_SUPERSECRET or room:GetType() == RoomType.ROOM_ULTRASECRET then
			door:TryBlowOpen(true, nil)
		end
	end
end
Rewind:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_DOOR_UPDATE, Rewind.PostGridEntityDoorUpdate, GridEntityType.GRID_DOOR)

function Rewind:UseItem(itemID, rng, player, useFlags, activeSlot, varData)
	if useFlags & UseFlag.USE_CARBATTERY == UseFlag.USE_CARBATTERY or ty.LEVEL:GetCurrentRoomIndex() <= GridRooms.ROOM_DEVIL_IDX or ty.LEVEL:GetAbsoluteStage() == LevelStage.STAGE8 or ty.LEVEL:GetDimension() > Dimension.NORMAL then
		return { Discharge = false, Remove = false, ShowAnim = true }
	end
	local data = ty:GetLibData(player)
	if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) and rng:RandomInt(100) < 5 then
		Isaac.ExecuteCommand("goto s.angel."..RoomConfigHolder.GetRandomRoom(rng:Next(), false, StbType.SPECIAL_ROOMS, RoomType.ROOM_ANGEL).Variant)
		ty.GAME:StartRoomTransition(GridRooms.ROOM_DEBUG_IDX, Direction.NO_DIRECTION, RoomTransitionAnim.TELEPORT, player, 0)
		data.Rewind.MaxCharge = 12
		return { Discharge = true, Remove = false, ShowAnim = true }
	elseif player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL_PASSIVE) and rng:RandomInt(100) < 5 then
		Isaac.ExecuteCommand("goto s.devil."..RoomConfigHolder.GetRandomRoom(rng:Next(), false, StbType.SPECIAL_ROOMS, RoomType.ROOM_DEVIL).Variant)
		ty.GAME:StartRoomTransition(GridRooms.ROOM_DEBUG_IDX, Direction.NO_DIRECTION, RoomTransitionAnim.TELEPORT, player, 0)
		data.Rewind.MaxCharge = 12
		return { Discharge = true, Remove = false, ShowAnim = true }
	end
	if rng:RandomInt(100) < 10 then
		DoNormalTeleport(player)
		data.Rewind.MaxCharge = 3
		return { Discharge = true, Remove = false, ShowAnim = true }
	end
	if #data.Rewind.RoomList == 0 then
		ty.GAME:StartRoomTransition(GridRooms.ROOM_ERROR_IDX, Direction.NO_DIRECTION, RoomTransitionAnim.TELEPORT, player, 0)
		data.Rewind.MaxCharge = 4
		return { Discharge = true, Remove = false, ShowAnim = true }
	end
	local index = rng:RandomInt(#data.Rewind.RoomList) + 1
	local roomType = data.Rewind.RoomList[index]
	if IsRoomInfoDuplicated(data.Rewind.RoomList, roomType) then
		table.remove(data.Rewind.RoomList, index)
	end
	data.Rewind.MaxCharge = roomTypeCharge[roomType]
	MoveToNewRoom(roomType, player, rng)
	return { Discharge = true, Remove = false, ShowAnim = true }
end
Rewind:AddCallback(ModCallbacks.MC_USE_ITEM, Rewind.UseItem, ty.CustomCollectibles.REWIND)

function Rewind:PlayerGetActiveMaxCharge(collectibleType, player, varData)
	local data = ty:GetLibData(player)
	return data.Rewind.MaxCharge
end
Rewind:AddCallback(ModCallbacks.MC_PLAYER_GET_ACTIVE_MAX_CHARGE, Rewind.PlayerGetActiveMaxCharge, ty.CustomCollectibles.REWIND)

return Rewind