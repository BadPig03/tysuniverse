local Functions = ty:DefineANewClass()

function Functions:IsPlayerFiring(player)
    local controllerIndex = player.ControllerIndex
	return Input.IsActionPressed(ButtonAction.ACTION_SHOOTUP, controllerIndex) or Input.IsActionPressed(ButtonAction.ACTION_SHOOTDOWN, controllerIndex) or Input.IsActionPressed(ButtonAction.ACTION_SHOOTRIGHT, controllerIndex) or Input.IsActionPressed(ButtonAction.ACTION_SHOOTLEFT, controllerIndex)
end

function Functions:GetPlayerFromTear(tear)
    if tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer() then
        return tear.SpawnerEntity:ToPlayer()
    elseif tear.SpawnerEntity and tear.SpawnerEntity:ToFamiliar() and (tear.SpawnerEntity.Variant == FamiliarVariant.CAINS_OTHER_EYE or tear.SpawnerEntity.Variant == FamiliarVariant.INCUBUS or tear.SpawnerEntity.Variant == FamiliarVariant.FATES_REWARD or tear.SpawnerEntity.Variant == FamiliarVariant.TWISTED_BABY or tear.SpawnerEntity.Variant == FamiliarVariant.BLOOD_BABY or tear.SpawnerEntity.Variant == FamiliarVariant.UMBILICAL_BABY) and tear.SpawnerEntity:ToFamiliar().Player and tear.SpawnerEntity:ToFamiliar().Player:ToPlayer() then
        return tear.SpawnerEntity:ToFamiliar().Player:ToPlayer()
    end
    return nil
end

function Functions:GetPlayerIndex(player)
    for index = 0, ty.GAME:GetNumPlayers() - 1 do
        if GetPtrHash(player) == GetPtrHash(Isaac.GetPlayer(index)) then
            return index
        end
    end
    return 0
end

function Functions:IsValidEnemy(enemy)
    return enemy:ToNPC() and enemy:IsActiveEnemy() and enemy:IsVulnerableEnemy() and enemy.Type ~= EntityType.ENTITY_FIREPLACE and not enemy:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) and not enemy:HasEntityFlags(EntityFlag.FLAG_CHARM)
end

function Functions:GetCollectibleFromCurrentRoom(includeActives, excludeTags, rng, originalItem)
	includeActives = includeActives or false
	excludeTags = excludeTags or ItemConfig.TAG_QUEST
    originalItem = originalItem or CollectibleType.COLLECTIBLE_BREAKFAST
	local room = ty.GAME:GetRoom()
    local roomType = room:GetType()
	local result
	repeat
		local newPool = ItemPoolType.POOL_TREASURE
		if type(rng) == "userdata" then
			newPool = ty.ITEMPOOL:GetPoolForRoom(roomType, rng:Next())
		else
			newPool = ty.ITEMPOOL:GetPoolForRoom(roomType, rng)
		end
        if roomType == RoomType.ROOM_CHALLENGE and ty.LEVEL:HasBossChallenge() then
            newPool = ItemPoolType.POOL_BOSS
        end
        if newPool < 0 then
            newPool = ItemPoolType.POOL_TREASURE
        end
        if (roomType == RoomType.ROOM_BOSS and (room:GetBossID() == 23 or ty.LEVEL:GetStateFlag(LevelStateFlag.STATE_SATANIC_BIBLE_USED))) or (ty.LEVEL:GetAbsoluteStage() == LevelStage.STAGE6 and ty.LEVEL:GetStageType() == StageType.STAGETYPE_ORIGINAL and ty.LEVEL:GetCurrentRoomIndex() == ty.LEVEL:GetStartingRoomIndex()) then
            newPool = ItemPoolType.POOL_DEVIL
        end
        if type(rng) == "userdata" then
            result = ty.ITEMPOOL:GetCollectible(newPool, true, rng:Next())
        else
            result = ty.ITEMPOOL:GetCollectible(newPool, true, rng)
        end
		local item = ty.ITEMCONFIG:GetCollectible(result)
	until (result == CollectibleType.COLLECTIBLE_BREAKFAST or (result ~= CollectibleType.COLLECTIBLE_BREAKFAST and result ~= originalItem)) and (item.Tags & excludeTags ~= excludeTags and (includeActives or item.Type % ItemType.ITEM_ACTIVE == 1))
	return result
end

function Functions:GetFamiliarsFromItemPool(itemPoolType, defaultItem, rng)
    local itemID = 1
    repeat
        for i = 1, ty.ITEMCONFIG:GetCollectibles().Size - 1 do
            if ItemConfig.Config.IsValidCollectible(i) and ty.ITEMCONFIG:GetCollectible(i).Type ~= ItemType.ITEM_FAMILIAR then
                ty.ITEMPOOL:AddRoomBlacklist(i)
            end
        end
        itemID = ty.ITEMPOOL:GetCollectible(itemPoolType, false, rng:Next(), defaultItem)
    until ty.ITEMCONFIG:GetCollectible(itemID).Type == ItemType.ITEM_FAMILIAR
    ty.ITEMPOOL:RemoveCollectible(itemID)
    ty.ITEMPOOL:ResetRoomBlacklist()
    return itemID
end

function Functions:GetLaserColor(player)
    local color = Color.Default
    if player:HasCollectible(CollectibleType.COLLECTIBLE_IPECAC) then
        color = Color.LaserIpecac
    elseif player:HasCollectible(CollectibleType.COLLECTIBLE_SACRED_HEART) then
        color = Color(1, 1, 1, 1, 0, 0, 0, 5, 6, 6, 1)
    elseif player:HasCollectible(CollectibleType.COLLECTIBLE_URANUS) then
        color = Color(1, 1, 1, 1, 0.1, 0.1, 0.1, 4, 4.4, 6, 1)
    elseif player:HasCollectible(CollectibleType.COLLECTIBLE_FIRE_MIND) or player:HasCollectible(ty.CustomCollectibles.HEPHAESTUSSOUL) then
        color = Color.LaserFireMind
    elseif player:HasCollectible(CollectibleType.COLLECTIBLE_SCORPIO) or player:HasCollectible(CollectibleType.COLLECTIBLE_COMMON_COLD) or player:HasCollectible(CollectibleType.COLLECTIBLE_MYSTERIOUS_LIQUID) then
        color = Color.LaserPoison
    elseif player:HasCollectible(CollectibleType.COLLECTIBLE_PARASITE) then
        color = Color(1, 1, 1, 1, 0, 0, 0, 3, 1.5, 0, 1)
    elseif player:HasCollectible(CollectibleType.COLLECTIBLE_SPIDER_BITE) then
        color = Color(1, 1, 1, 1, 0, 0, 0, 5.2, 5.2, 5, 1)
	elseif player:HasCollectible(CollectibleType.COLLECTIBLE_STRANGE_ATTRACTOR) or player:HasCollectible(CollectibleType.COLLECTIBLE_LODESTONE) then
		color = Color(1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1)
    elseif player:HasCollectible(CollectibleType.COLLECTIBLE_ROTTEN_TOMATO) then
        color = Color(1, 1, 1, 1, 0, 0, 0, 5, 1, 0, 1)
	elseif player:HasCollectible(CollectibleType.COLLECTIBLE_JACOBS_LADDER) then
        color = Color(1, 1, 1, 1, 3.8, 4.9, 6, 1, 0.1, 0.1, 0.1)
    elseif player:HasCollectible(CollectibleType.COLLECTIBLE_NUMBER_ONE) then
        color = Color.LaserNumberOne
    elseif player:HasCollectible(CollectibleType.COLLECTIBLE_SPOON_BENDER) or player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_TELEPATHY_BOOK) or player.TearFlags & TearFlags.TEAR_HOMING == TearFlags.TEAR_HOMING then
        color = Color.LaserHoming
    elseif player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_EYESHADOW) then
        color = Color(1, 1, 1, 1, 0, 0, 0, 4, 1, 3.5, 1)
    elseif player:HasCollectible(CollectibleType.COLLECTIBLE_GODS_FLESH) then
        color = Color(1, 1, 1, 1, 0, 0, 0, 1.2, 1.2, 4, 1)
    elseif player:HasCollectible(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK) then
        color = Color.LaserChocolate
    elseif player:HasCollectible(CollectibleType.COLLECTIBLE_ALMOND_MILK) then
        color = Color.LaserAlmond
    elseif player:HasCollectible(CollectibleType.COLLECTIBLE_SOY_MILK) then
        color = Color.LaserSoy
    elseif player:HasCollectible(CollectibleType.COLLECTIBLE_LUMP_OF_COAL) then
        color = Color.TearCoal
    elseif player:HasCollectible(CollectibleType.COLLECTIBLE_DARK_MATTER) then
        color = Color(3, 3, 3, 1, -0.5, -0.5, -0.5, 1, 1, 1, 1)
    end
    if player.TearFlags & TearFlags.TEAR_SPECTRAL == TearFlags.TEAR_SPECTRAL then
        color:SetTint(1.5, 2, 2, 0.5)
    end
    return color
end

function Functions:GetLastBossRoomIndex()
    local function HasOneOrLessDoor(roomDesc)
        local count = 0
        for i = DoorSlot.LEFT0, DoorSlot.DOWN1 do
            if roomDesc.AllowedDoors & 1 << i == 1 << i then
                count = count + 1
            end
        end
        return count <= 1
    end
    if ty.LEVEL:GetAbsoluteStage() == LevelStage.STAGE7 then
        for i = 0, 168 do
            local roomDesc = ty.LEVEL:GetRoomByIdx(i)
            local roomData = roomDesc.Data
            if roomData and roomData.Type == RoomType.ROOM_BOSS and roomData.Shape == RoomShape.ROOMSHAPE_2x2 then
                return roomDesc.SafeGridIndex
            end
        end
    else
        for i = 0, 168 do
            local roomDesc = ty.LEVEL:GetRoomByIdx(i)
            local roomData = roomDesc.Data
            if roomData and roomData.Type == RoomType.ROOM_BOSS and HasOneOrLessDoor(roomDesc) then
                return roomDesc.SafeGridIndex
            end
        end    
    end
    return ty.LEVEL:GetStartingRoomIndex()
end

return Functions