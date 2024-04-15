local Anorexia = ty:DefineANewClass()

function Anorexia:PostPlayerUpdate(player)
	local data = ty:GetLibData(player)
	if data.Init and player:HasCollectible(ty.CustomCollectibles.ANOREXIA) and not player:HasCollectible(CollectibleType.COLLECTIBLE_BINGE_EATER) and ty.LEVEL:GetDimension() ~= Dimension.DEATH_CERTIFICATE then
		for _, entity in pairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)) do
			local pickup = entity:ToPickup()
			local item = ty.ITEMCONFIG:GetCollectible(pickup.SubType)
			if item and item:HasTags(ItemConfig.TAG_FOOD) then
				local newType = ty:GetCollectibleFromCurrentRoom(true, ItemConfig.TAG_FOOD | ItemConfig.TAG_QUEST, player:GetCollectibleRNG(ty.CustomCollectibles.ANOREXIA))
				if pickup.SubType ~= newType then
					pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, newType, true, true, false)
					Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector(0, 0), nil)
				end
			end
		end
	end
end
Anorexia:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Anorexia.PostPlayerUpdate)

function Anorexia:PostAddCollectible(collectibleType, charge, firstTime, slot, varData, player)
	if collectibleType == ty.CustomCollectibles.ANOREXIA then
		if player:HasCollectible(CollectibleType.COLLECTIBLE_BINGE_EATER) then
			player:RemoveCostume(ty.ITEMCONFIG:GetCollectible(ty.CustomCollectibles.ANOREXIA))
		elseif firstTime then
			player:UsePill(PillEffect.PILLEFFECT_HEMATEMESIS, PillColor.PILL_NULL, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_NOHUD)	
		end
	elseif collectibleType == CollectibleType.COLLECTIBLE_BINGE_EATER and player:HasCollectible(ty.CustomCollectibles.ANOREXIA) then
		player:RemoveCostume(ty.ITEMCONFIG:GetCollectible(ty.CustomCollectibles.ANOREXIA))
	end
end
Anorexia:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, Anorexia.PostAddCollectible)

return Anorexia