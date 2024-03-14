local questionMarkSprite = Sprite("gfx/005.100_collectible.anm2")
questionMarkSprite:ReplaceSpritesheet(1,"gfx/items/collectibles/questionmark.png", true)

function ty:TableCopyTo(origin)
	if type(origin) ~= "table" then
		return origin
	end
	local new = {}
	for key, value in pairs(origin) do
		local vType = type(value)
		if vType == "table" then
			new[key] = ty:TableCopyTo(value)
		else
			new[key] = value
		end
	end
	return new
end

function ty:IsValueInTable(value, origin)
	for _, item in pairs(origin) do
		if value == item then
			return true
		end
	end
	return false
end

function ty:RemoveValueInTable(value, origin)
	for _, item in pairs(origin) do
		if value == item then
			table.remove(origin, _)
		end
	end
end

function ty:IsPlayerFiring(player)
    local controllerIndex = player.ControllerIndex
	if Input.IsActionPressed(ButtonAction.ACTION_SHOOTUP, controllerIndex) or Input.IsActionPressed(ButtonAction.ACTION_SHOOTDOWN, controllerIndex) or Input.IsActionPressed(ButtonAction.ACTION_SHOOTRIGHT, controllerIndex) or Input.IsActionPressed(ButtonAction.ACTION_SHOOTLEFT, controllerIndex) then
		return true
	end
	return false
end

function ty:GetPlayerFromTear(tear)
    if tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer() then
        return tear.SpawnerEntity:ToPlayer()
    elseif tear.SpawnerEntity and tear.SpawnerEntity:ToFamiliar() and (tear.SpawnerEntity.Variant == FamiliarVariant.CAINS_OTHER_EYE or tear.SpawnerEntity.Variant == FamiliarVariant.INCUBUS or tear.SpawnerEntity.Variant == FamiliarVariant.FATES_REWARD or tear.SpawnerEntity.Variant == FamiliarVariant.TWISTED_BABY or tear.SpawnerEntity.Variant == FamiliarVariant.BLOOD_BABY or tear.SpawnerEntity.Variant == FamiliarVariant.UMBILICAL_BABY) and tear.SpawnerEntity:ToFamiliar().Player and tear.SpawnerEntity:ToFamiliar().Player:ToPlayer() then
        return tear.SpawnerEntity:ToFamiliar().Player:ToPlayer()
    end
    return nil
end

function ty:GetPlayerIndex(player)
    for index = 0, ty.GAME:GetNumPlayers() - 1 do
        if GetPtrHash(player) == GetPtrHash(Isaac.GetPlayer(index)) then
            return index
        end
    end
    return 0
end

function ty:IsValidCollider(collider)
    if collider:IsActiveEnemy() and collider:IsVulnerableEnemy() and collider.Type ~= EntityType.ENTITY_FIREPLACE and not collider:HasEntityFlags(EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_CHARM) then
        return true
    end
    return false
end

function ty:GetCollectibleFromCurrentRoom(includeActives, excludeTags, rng, originalItem)
	includeActives = includeActives or false
	excludeTags = excludeTags or ItemConfig.TAG_QUEST
	local room = ty.GAME:GetRoom()
	local result = nil
	repeat
        local roomType = room:GetType()
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

function ty:GetCollectibleFromAllItemPools(includeActives, excludeTags, rng)
	includeActives = includeActives or false
	excludeTags = excludeTags or ItemConfig.TAG_QUEST
    local seed = rng
    if type(rng) ~= "userdata" then
        rng = RNG()
        rng:SetSeed(seed)
    end
	local result = nil
	repeat
        result = ty.ITEMPOOL:GetCollectible(rng:RandomInt(ItemPoolType.NUM_ITEMPOOLS), false, rng:Next())
		local item = ty.ITEMCONFIG:GetCollectible(result)
	until item.Tags & excludeTags ~= excludeTags and (includeActives or item.Type % ItemType.ITEM_ACTIVE == 1)
	return result
end

function ty:ToStringFillZero(number)
	if number < 10 then
		return "0"..tostring(number)
	else
		return tostring(number)
	end
end

function ty:GetNearestEnemy(position)
	local distance = 8192
    local nearestEnemy = nil
    for _, ent in pairs(Isaac.FindInRadius(position, 8192, EntityPartition.ENEMY)) do
        if ty:IsValidCollider(ent) and (ent.Position - position):Length() < distance then
            distance = (ent.Position - position):Length()
            nearestEnemy = ent
        end
    end
    return nearestEnemy
end

function ty:GetLaserColor(player)
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

function ty:SpawnFakeSprite(entity, animation)
    local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, ty.CustomEffects.EMPTYHELPER, 0, entity.Position, Vector(0, 0), nil)
    local sprite = effect:GetSprite()
    sprite:Load(entity:GetSprite():GetFilename(), true)
    sprite:Play(animation, true)
end

function ty:RemoveOtherPickupIndex(index)
    if index ~= 0 then
        for _, ent in pairs(Isaac.FindByType(EntityType.ENTITY_PICKUP)) do
            local pickup = ent:ToPickup()
            if pickup.OptionsPickupIndex == index then
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, ent.Position, Vector(0, 0), nil)
                ent:Remove()
            end
        end
    end
end

return ty