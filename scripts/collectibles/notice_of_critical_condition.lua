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
	if PlanetariumChance then
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
	return -151 / 1690 * frame^2
end

local function AddChance(data, difference)
	data.NoticeOfCriticalCondition.PreviousSpawnChance = data.NoticeOfCriticalCondition.CurrentSpawnChance
	data.NoticeOfCriticalCondition.CurrentSpawnChance = math.min(100, math.max(0, data.NoticeOfCriticalCondition.CurrentSpawnChance + difference))
	data.NoticeOfCriticalCondition.FontAlpha = 2.9
end

local function GetInitData()
	return { IsBroken = false, ShouldExplode = false, BrokenChance = 0 }
end

local function SpawnDamageEffect(player)
	Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 0, player.Position, Vector(0, 0), nil)
	Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_SPLAT, 0, player.Position, Vector(0, 0), nil)
	Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_RED, 0, player.Position, Vector(0, 0), nil)
	player:TakeDamage(0, DamageFlag.DAMAGE_RED_HEARTS, EntityRef(player), 0)
end

local function GetItemFromPool(player)
    local rng = player:GetCollectibleRNG(ty.CustomCollectibles.NOTICEOFCRITICALCONDITION)
    local data = ty.GLOBALDATA
    local index = rng:RandomInt(#data.NoticeOfCriticalCondition.ItemList) + 1
    local item = data.NoticeOfCriticalCondition.ItemList[index]
	if ty.ITEMPOOL:HasCollectible(item) then
		table.remove(data.NoticeOfCriticalCondition.ItemList, index)
		return item
	else
		return GetItemFromPool(player)
	end
end

function NoticeOfCriticalCondition:PostHUDRender()
	local data = ty.GLOBALDATA
    if not PlayerManager.AnyoneHasCollectible(ty.CustomCollectibles.NOTICEOFCRITICALCONDITION) or not data.NoticeOfCriticalCondition or not ty.HUD:IsVisible() or not Options.FoundHUD or (ty.GAME:GetRoom():GetType() == RoomType.ROOM_DUNGEON and ty.LEVEL:GetAbsoluteStage() == LevelStage.STAGE8) or ty.GAME:GetSeeds():HasSeedEffect(SeedEffect.SEED_NO_HUD) or ty.GAME:IsGreedMode() then
		return
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
	if PlayerManager.AnyoneHasCollectible(ty.CustomCollectibles.NOTICEOFCRITICALCONDITION) and data.NoticeOfCriticalCondition then
		data.NoticeOfCriticalCondition.MachineList = {}
		local spawnChance = data.NoticeOfCriticalCondition.CurrentSpawnChance
		local rng = ty.LEVEL:GetDevilAngelRoomRNG()
		if rng:RandomInt(100) < spawnChance then
			Isaac.Spawn(EntityType.ENTITY_SLOT, ty.CustomEntities.NOTICEOFCRITICALCONDITIONMACHINE, 0, Vector(160, 200), Vector(0, 0), nil)
			AddChance(data, -60)
		else
			AddChance(data, 40)
		end
		for _, player in pairs(PlayerManager.GetPlayers()) do
			if player:HasCollectible(ty.CustomCollectibles.NOTICEOFCRITICALCONDITION) then
				player:AddBrokenHearts(2)
			end
		end	
	end
end
NoticeOfCriticalCondition:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, NoticeOfCriticalCondition.PostNewLevel)

function NoticeOfCriticalCondition:UsePill(pillEffect, player, useFlags, pillColor)
    if player:HasCollectible(ty.CustomCollectibles.NOTICEOFCRITICALCONDITION) then
        local rng = player:GetCollectibleRNG(ty.CustomCollectibles.NOTICEOFCRITICALCONDITION)
        local pillConfig = ty.ITEMCONFIG:GetPillEffect(pillEffect)
		if pillConfig.EffectSubClass > 0 and rng:RandomInt(100) < 20 and player:GetBrokenHearts() >= 1 then
			ty.SFXMANAGER:Play(SoundEffect.SOUND_DEVIL_CARD)
			player:AddBrokenHearts(-1)
		end
    end
end
NoticeOfCriticalCondition:AddCallback(ModCallbacks.MC_USE_PILL, NoticeOfCriticalCondition.UsePill)

function NoticeOfCriticalCondition:PreEntitySpawn(type, variant, subType, position, velocity, spawner, seed)
	local data = ty.GLOBALDATA
	if type == EntityType.ENTITY_SLOT and PlayerManager.AnyoneHasCollectible(ty.CustomCollectibles.NOTICEOFCRITICALCONDITION) and data.NoticeOfCriticalCondition.MachineList[tostring(seed)] == nil then
		data.NoticeOfCriticalCondition.MachineList[tostring(seed)] = ty:TableCopyTo(GetInitData())
		if variant == SlotVariant.SLOT_MACHINE or variant == SlotVariant.TEMPERANCE_MACHINE then
			local rng = ty.LEVEL:GetDevilAngelRoomRNG()
			if rng:RandomInt(100) < 25 then
				return { EntityType.ENTITY_SLOT, ty.CustomEntities.NOTICEOFCRITICALCONDITIONMACHINE, 0, seed }
			end
		end
	end
end
NoticeOfCriticalCondition:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, NoticeOfCriticalCondition.PreEntitySpawn)

function NoticeOfCriticalCondition:PostSlotUpdate(slot)
	if slot.Variant ~= ty.CustomEntities.NOTICEOFCRITICALCONDITIONMACHINE then
		return
	end
	local slotData = ty.GLOBALDATA.NoticeOfCriticalCondition.MachineList[tostring(slot.InitSeed)]
	local room = ty.GAME:GetRoom()
	local sprite = slot:GetSprite()
	if slotData.IsBroken then
		if sprite:IsFinished("Death") then
			sprite:Play("Broken", true)
		end
	else
		if slotData.ShouldExplode or slot.GridCollisionClass == EntityGridCollisionClass.GRIDCOLL_GROUND then
			slotData.IsBroken = true
			slotData.ShouldExplode = false
			sprite:Play("Death", true)
			slot:TakeDamage(1, DamageFlag.DAMAGE_EXPLOSION, EntityRef(nil), 0)
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BOMB_EXPLOSION, 0, slot.Position, Vector(0,0), nil)
		end
		local player = slotData.Player
		if player then
			local playerData = ty:GetLibData(player)
			local rng = player:GetCollectibleRNG(ty.CustomCollectibles.NOTICEOFCRITICALCONDITION)
			if sprite:IsFinished("InsertTwoCoins") then
				sprite:Play("Initiate", true)
			end
			if sprite:IsFinished("Initiate") then
				sprite:Play("Wiggle", true)
			end
			if sprite:IsFinished("Wiggle") then
				if rng:RandomInt(100) < 25 then
					sprite:Play("GainItem", true)
				else
					sprite:Play("GainPill", true)
				end
			end
			if sprite:IsFinished("GainPill") then
				Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_PILL, rng:RandomInt(13) + 1, room:FindFreePickupSpawnPosition(slot.Position + Vector(0, 16), 0, true), Vector(0, 0), nil)
				sprite:Play("Idle", true)
				ty.SFXMANAGER:Play(SoundEffect.SOUND_SLOTSPAWN)
				slotData.BrokenChance = math.max(0, slotData.BrokenChance - 5)
				playerData.NoticeOfCriticalCondition.TempBrokenHearts = playerData.NoticeOfCriticalCondition.TempBrokenHearts - 1
			end
			if sprite:IsFinished("GainItem") then
				local itemSubtype = GetItemFromPool(player)
				local item = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, itemSubtype, room:FindFreePickupSpawnPosition(slot.Position + Vector(0, 80), 0, true), Vector(0, 0), nil):ToPickup()
				item.ShopItemId = -2
				item.Price = 0
				ty.SFXMANAGER:Play(SoundEffect.SOUND_SLOTSPAWN)
				slotData.BrokenChance = math.min(100, slotData.BrokenChance + 20)
				playerData.NoticeOfCriticalCondition.TempBrokenHearts = playerData.NoticeOfCriticalCondition.TempBrokenHearts - 1
				if itemSubtype == CollectibleType.COLLECTIBLE_DEATH_CERTIFICATE then
					slotData.ShouldExplode = true
					playerData.NoticeOfCriticalCondition.Disable = true
				else
					sprite:Play("Idle", true)
					if rng:RandomInt(100) < slotData.BrokenChance then
						slotData.ShouldExplode = true
					end
				end
			end
			if sprite:IsEventTriggered("InsertCoin") then
				ty.SFXMANAGER:Play(SoundEffect.SOUND_COIN_INSERT)
			end
			if sprite:IsEventTriggered("GainItem") then
				ty.SFXMANAGER:Play(SoundEffect.SOUND_THUMBSUP)
			end
			if sprite:IsEventTriggered("GainPill") then
				ty.SFXMANAGER:Play(SoundEffect.SOUND_THUMBS_DOWN)
				SpawnDamageEffect(player)
				player:AddBrokenHearts(1)
			end
		end
	end
end
NoticeOfCriticalCondition:AddCallback(ModCallbacks.MC_POST_SLOT_UPDATE, NoticeOfCriticalCondition.PostSlotUpdate, ty.CustomEntities.NOTICEOFCRITICALCONDITIONMACHINE)

function NoticeOfCriticalCondition:PreSlotCollision(slot, collider, low)
	if slot.Variant == ty.CustomEntities.NOTICEOFCRITICALCONDITIONMACHINE then
		local player = collider:ToPlayer()
		local sprite = slot:GetSprite()
		local slotData = ty.GLOBALDATA.NoticeOfCriticalCondition.MachineList[tostring(slot.InitSeed)]
		if sprite:IsPlaying("Idle") and player and player:GetBrokenHearts() >= 1 and player:GetNumCoins() >= 2 then
			local playerData = ty:GetLibData(player)
			slotData.Player = player
			sprite:Play("InsertTwoCoins", true)
			player:AddCoins(-2)
			ty.SFXMANAGER:Play(SoundEffect.SOUND_DEVIL_CARD)
			SpawnDamageEffect(player)
			player:AddBrokenHearts(-1)
			playerData.NoticeOfCriticalCondition.TempBrokenHearts = playerData.NoticeOfCriticalCondition.TempBrokenHearts + 1
		end	
	end
end
NoticeOfCriticalCondition:AddCallback(ModCallbacks.MC_PRE_SLOT_COLLISION, NoticeOfCriticalCondition.PreSlotCollision, ty.CustomEntities.NOTICEOFCRITICALCONDITIONMACHINE)

function NoticeOfCriticalCondition:PostNewRoom()
    for _, player in pairs(PlayerManager.GetPlayers()) do
        if player:HasCollectible(ty.CustomCollectibles.NOTICEOFCRITICALCONDITION) then
            local data = ty:GetLibData(player)
            if data.NoticeOfCriticalCondition.TempBrokenHearts > 0 then
                player:AddBrokenHearts(data.NoticeOfCriticalCondition.TempBrokenHearts)
                data.NoticeOfCriticalCondition.TempBrokenHearts = 0
            end
		end
    end
end
NoticeOfCriticalCondition:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, NoticeOfCriticalCondition.PostNewRoom)

return NoticeOfCriticalCondition