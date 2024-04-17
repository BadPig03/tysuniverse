local NoticeOfCriticalCondition = ty:DefineANewClass()

local chanceIcon = Sprite("gfx/ui/notice_of_critical_condition_chance.anm2", true)
chanceIcon.Color = Color(1, 1, 1, 0.5)
chanceIcon:SetFrame("Idle", 9)

local function GetRenderOffset()
	local coords = Vector(0, 0)
	local dualityShift = false
	local heartShift = false
	if PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_DUALITY) then
		dualityShift = true
	end
	if PlayerManager.AnyoneIsPlayerType(PlayerType.PLAYER_BETHANY) or PlayerManager.AnyoneIsPlayerType(PlayerType.PLAYER_BETHANY_B) then
		heartShift = true
	end
	if Isaac.GetPlayer(0):GetPlayerType() == PlayerType.PLAYER_JACOB then
		coords = coords + Vector(0, 30)
		if dualityShift then
			coords = coords - Vector(0, 2)
		end
	end
	if heartShift then
		coords = coords + Vector(0, 10)
	end
	if dualityShift then
		coords = coords - Vector(0, 10)
	end
	if ty.GAME:IsHardMode() or ty.GAME:IsGreedMode() or ty.GAME:AchievementUnlocksDisallowed() then
		coords = coords + Vector(0, 16)
	end
	if PlanetariumChance or Options.StatHUDPlanetarium then
        coords = coords + Vector(0, 11)
    end
	coords = coords + ty.GAME.ScreenShakeOffset + Options.HUDOffset * Vector(20, 12)
	return coords
end

local function TextAcceleration(frame)
	frame = frame - 14
	if frame > 0 then
		return 0
	end
	return -151 / 1690 * frame ^ 2
end

local function AddChance(data, difference)
	data.NoticeOfCriticalCondition.PreviousSpawnChance = data.NoticeOfCriticalCondition.CurrentSpawnChance
	data.NoticeOfCriticalCondition.CurrentSpawnChance = math.min(100, math.max(0, data.NoticeOfCriticalCondition.CurrentSpawnChance + difference))
	data.NoticeOfCriticalCondition.FontAlpha = 2.9
end

local function GetInitData()
	return { IsBroken = false, ShouldExplode = false, BrokenChance = 0 }
end

local function GetItemFromPool(player)
    local data = ty.GLOBALDATA
    local rng = player:GetCollectibleRNG(ty.CustomCollectibles.NOTICEOFCRITICALCONDITION)
    local validItems = {}
    for _, item in pairs(data.NoticeOfCriticalCondition.ItemList) do
        if ty.ITEMPOOL:HasCollectible(item) then
            table.insert(validItems, item)
        end
    end
    if #validItems > 0 then
        local index = rng:RandomInt(#validItems) + 1
        local selected_item = validItems[index]
		ty:RemoveValueInTable(data.NoticeOfCriticalCondition.ItemList, selected_item)
		ty.ITEMPOOL:RemoveCollectible(selected_item)
        return selected_item
    else
        return CollectibleType.COLLECTIBLE_BREAKFAST
    end
end

function NoticeOfCriticalCondition:PostHUDRender()
	local data = ty.GLOBALDATA
    if not PlayerManager.AnyoneHasCollectible(ty.CustomCollectibles.NOTICEOFCRITICALCONDITION) or not data.NoticeOfCriticalCondition or not ty.HUD:IsVisible() or not Options.FoundHUD or ty.GAME:GetRoom():GetType() == RoomType.ROOM_DUNGEON or ty.LEVEL:GetAbsoluteStage() == LevelStage.STAGE8 or ty.GAME:GetSeeds():HasSeedEffect(SeedEffect.SEED_NO_HUD) or ty.GAME:IsGreedMode() then
		return
	end
	if data.NoticeOfCriticalCondition.Disabled then
		data.NoticeOfCriticalCondition.PreviousSpawnChance = 0
		data.NoticeOfCriticalCondition.CurrentSpawnChance = 0
	end
    local iconPosition = Vector(0, 168) + GetRenderOffset()
	chanceIcon:Render(iconPosition)
    local textCoords = iconPosition + Vector(16, 0)
    ty.LUAMIN:DrawStringScaledUTF8(string.format("%.1f%%", data.NoticeOfCriticalCondition.CurrentSpawnChance), textCoords.X, textCoords.Y, 1, 1, KColor(1, 1, 1, 0.5))
	local alpha = data.NoticeOfCriticalCondition.FontAlpha
	if alpha > 0 then
		alpha = math.min(0.5, alpha)
		local difference = data.NoticeOfCriticalCondition.CurrentSpawnChance - data.NoticeOfCriticalCondition.PreviousSpawnChance
		local differenceOutput = string.format("%.1f%%", difference)
		local slide = TextAcceleration((2.9 - data.NoticeOfCriticalCondition.FontAlpha) / 0.02)
		if difference > 0 then
			ty.LUAMIN:DrawString("+"..differenceOutput, textCoords.X + 30 + slide, textCoords.Y, KColor(0, 1, 0, alpha), 0, true)
		elseif difference < 0 then
			ty.LUAMIN:DrawString(differenceOutput, textCoords.X + 30 + slide, textCoords.Y, KColor(1, 0, 0, alpha), 0, true)
		end
        if not ty.GAME:IsPaused() then
		    data.NoticeOfCriticalCondition.FontAlpha = data.NoticeOfCriticalCondition.FontAlpha - 0.01
        end
	end
end
NoticeOfCriticalCondition:AddCallback(ModCallbacks.MC_POST_HUD_RENDER, NoticeOfCriticalCondition.PostHUDRender)

function NoticeOfCriticalCondition:PostNewLevel()
	local data = ty.GLOBALDATA
	if not PlayerManager.AnyoneHasCollectible(ty.CustomCollectibles.NOTICEOFCRITICALCONDITION) or not data.NoticeOfCriticalCondition or ty.LEVEL:GetAbsoluteStage() == LevelStage.STAGE8 or ty.GAME:IsGreedMode() then
		return
	end
	data.NoticeOfCriticalCondition.MachineList = {}
	if not data.NoticeOfCriticalCondition.Disabled then
		AddChance(data, 30)
		local spawnChance = data.NoticeOfCriticalCondition.CurrentSpawnChance
		local rng = ty.LEVEL:GetDevilAngelRoomRNG()
		if rng:RandomInt(100) < spawnChance then
			Isaac.Spawn(EntityType.ENTITY_SLOT, ty.CustomEntities.HEALINGBEGGAR, 0, Vector(120, 200), Vector(0, 0), nil)
			AddChance(data, -50)
		end
	end
	for _, player in pairs(PlayerManager.GetPlayers()) do
		if player:HasCollectible(ty.CustomCollectibles.NOTICEOFCRITICALCONDITION) then
			if not data.NoticeOfCriticalCondition.Disabled then
				if player:GetHeartLimit() > 4 then
					player:AddBrokenHearts(2)
				elseif player:GetHeartLimit() == 4 then
					player:AddBrokenHearts(1)
				end
			else
				player:AddBrokenHearts(3)
			end
		end
	end
end
NoticeOfCriticalCondition:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, NoticeOfCriticalCondition.PostNewLevel)

function NoticeOfCriticalCondition:UsePill(pillEffect, player, useFlags, pillColor)
    if player:HasCollectible(ty.CustomCollectibles.NOTICEOFCRITICALCONDITION) and pillColor ~= PillColor.PILL_NULL then
        local rng = player:GetCollectibleRNG(ty.CustomCollectibles.NOTICEOFCRITICALCONDITION)
        local pillConfig = ty.ITEMCONFIG:GetPillEffect(pillEffect)
		if pillConfig.EffectSubClass == 1 and rng:RandomInt(100) < 20 and player:GetBrokenHearts() >= 1 then
			ty.SFXMANAGER:Play(SoundEffect.SOUND_BAND_AID_PICK_UP, 0.6)
			player:AddBrokenHearts(-1)
		end
    end
end
NoticeOfCriticalCondition:AddCallback(ModCallbacks.MC_USE_PILL, NoticeOfCriticalCondition.UsePill)

function NoticeOfCriticalCondition:PostSlotUpdate(slot)
	if slot.Variant ~= ty.CustomEntities.HEALINGBEGGAR then
		return
	end
	local data = ty.GLOBALDATA
	local slotData = data.NoticeOfCriticalCondition.MachineList[tostring(slot.InitSeed)]
	local room = ty.GAME:GetRoom()
	local sprite = slot:GetSprite()
	if slotData == nil then
		data.NoticeOfCriticalCondition.MachineList[tostring(slot.InitSeed)] = ty:GetTableCopyFrom(GetInitData())
		slotData = data.NoticeOfCriticalCondition.MachineList[tostring(slot.InitSeed)]
	end
	if slotData.IsBroken then
		if sprite:IsFinished("Teleport") then
			slot:Remove()
		end
	else
		if slotData.ShouldExplode then
			slot.Velocity = Vector(0, 0)
			slotData.IsBroken = true
			slotData.ShouldExplode = false
			sprite:Play("Teleport", true)
		end
		if slot.GridCollisionClass == EntityGridCollisionClass.GRIDCOLL_GROUND then
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 0, slot.Position, Vector(0, 0), nil)
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_SPLAT, 0, slot.Position, Vector(0, 0), nil)
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_RED, 0, slot.Position, Vector(0, 0), nil)
			local rng = slot:GetDropRNG()
			for i = 1, rng:RandomInt(3) + 1 do
				Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_PILL, 0, slot.Position, Vector(1, 0):Resized(2 + rng:RandomFloat() * 4):Rotated(rng:RandomInt(360)), nil):ToPickup()
			end
			for _, player in pairs(PlayerManager.GetPlayers()) do
				if player:HasCollectible(ty.CustomCollectibles.BEGGARMASK) then
					player:RemoveCollectible(ty.CustomCollectibles.BEGGARMASK)
					player:AnimateSad()
					ty.SFXMANAGER:Play(SoundEffect.SOUND_HOLY_MANTLE, 0.6, 2, false, 1.3)
					Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CRACKED_ORB_POOF, 0, player.Position, Vector(0, 0), nil):GetSprite().Color:SetColorize(0.3, 0.3, 0.3, 1)        
				end
			end	
			slot:BloodExplode()
			slot:Remove()
			return
		end
		local player = slotData.Player
		if player then
			local rng = player:GetCollectibleRNG(ty.CustomCollectibles.NOTICEOFCRITICALCONDITION)
			if sprite:IsEventTriggered("CoinInsert") then
				ty.SFXMANAGER:Play(SoundEffect.SOUND_SCAMPER, 0.6)
			end
			if sprite:IsEventTriggered("GainPill") then
				Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_PILL, 0, slot.Position, Vector(1, 0):Resized(3 + rng:RandomFloat() * 5):Rotated(rng:RandomInt(360)), nil)
				ty.SFXMANAGER:Play(SoundEffect.SOUND_SLOTSPAWN, 0.6)
				ty.SFXMANAGER:Play(SoundEffect.SOUND_THUMBS_DOWN, 0.6)
				sprite:Play("Idle", true)
				slotData.BrokenChance = math.max(0, slotData.BrokenChance - 4)
			end
			if sprite:IsEventTriggered("Prize") then
				local itemSubtype = GetItemFromPool(player)
				Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, itemSubtype, room:FindFreePickupSpawnPosition(slot.Position + Vector(0, 80), 0, true), Vector(0, 0), nil)
				ty.SFXMANAGER:Play(SoundEffect.SOUND_SLOTSPAWN, 0.6)
				ty.SFXMANAGER:Play(SoundEffect.SOUND_THUMBSUP, 0.6)
				sprite:Play("Idle", true)
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 0, player.Position, Vector(0, 0), nil)
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_SPLAT, 0, player.Position, Vector(0, 0), nil)
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_RED, 0, player.Position, Vector(0, 0), nil)
				player:AddBrokenHearts(-1)
				slotData.BrokenChance = math.min(100, slotData.BrokenChance + 16)
				if itemSubtype == CollectibleType.COLLECTIBLE_DEATH_CERTIFICATE then
					slotData.ShouldExplode = true
					data.NoticeOfCriticalCondition.Disabled = true
				else
					if rng:RandomInt(100) < slotData.BrokenChance then
						slotData.ShouldExplode = true
					end
				end
			end
			if sprite:IsFinished("PayPrize") then
				sprite:Play("Prize", true)
			end
			if sprite:IsFinished("Prize") or sprite:IsFinished("PayNothing") then
				sprite:Play("Idle", true)
			end
			if sprite:IsFinished("Teleport") then
				slot:Remove()
			end
		end
	end
end
NoticeOfCriticalCondition:AddCallback(ModCallbacks.MC_POST_SLOT_UPDATE, NoticeOfCriticalCondition.PostSlotUpdate, ty.CustomEntities.HEALINGBEGGAR)

function NoticeOfCriticalCondition:PreSlotCollision(slot, collider, low)
	local player = collider:ToPlayer()
	if slot.Variant == ty.CustomEntities.HEALINGBEGGAR and player then
		if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
			player = player:GetOtherTwin()
		end
		local sprite = slot:GetSprite()
		local data = ty.GLOBALDATA
		local slotData = ty.GLOBALDATA.NoticeOfCriticalCondition.MachineList[tostring(slot.InitSeed)]
		if slotData == nil then
			data.NoticeOfCriticalCondition.MachineList[tostring(slot.InitSeed)] = ty:GetTableCopyFrom(GetInitData())
			slotData = data.NoticeOfCriticalCondition.MachineList[tostring(slot.InitSeed)]
		end
		if sprite:IsPlaying("Idle") and player and player:GetBrokenHearts() >= 1 and player:GetNumCoins() >= 2 then
			local playerData = ty:GetLibData(player)
			slotData.Player = player
			if player:GetCollectibleRNG(ty.CustomCollectibles.NOTICEOFCRITICALCONDITION):RandomInt(100) < 25 then
				sprite:Play("PayPrize", true)
			else
				sprite:Play("PayNothing", true)
			end
			player:AddCoins(-2)
			ty.SFXMANAGER:Play(SoundEffect.SOUND_BAND_AID_PICK_UP, 0.6)
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 0, player.Position, Vector(0, 0), nil)
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_SPLAT, 0, player.Position, Vector(0, 0), nil)
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_RED, 0, player.Position, Vector(0, 0), nil)
		end
	end
end
NoticeOfCriticalCondition:AddCallback(ModCallbacks.MC_PRE_SLOT_COLLISION, NoticeOfCriticalCondition.PreSlotCollision, ty.CustomEntities.HEALINGBEGGAR)

function NoticeOfCriticalCondition:PreSlotCreateExplosionDrops(slot)
    return false
end
NoticeOfCriticalCondition:AddCallback(ModCallbacks.MC_PRE_SLOT_CREATE_EXPLOSION_DROPS, NoticeOfCriticalCondition.PreSlotCreateExplosionDrops, ty.CustomEntities.HEALINGBEGGAR)

return NoticeOfCriticalCondition