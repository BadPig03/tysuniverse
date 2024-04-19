local SaveAndLoad = ty:DefineANewClass()

local lastRoomData = {}
local genesisReset = false
local esauJRReset = false

local function GetInitData()
	local data = {}
	if data.Init == nil then
		data.Init = false
	end
    data.AbsenceNote = { Colors = {}, Count = 0, TriggeredColorCount = {}, Triggered = true }
    data.AtonementVoucher = { Effected = false, DevilRoomVisited = false }
    data.BobsStomach = { LastDirectionX = 0, LastDirectionY = 0, Fired = false, CanFire = false }
    data.BloodSacrifice = { UsedCount = {}, VesselList = {}, Respawning = false, PlaySound = false }
    data.BloodSample = { Percent = 0 }
    data.BoneInFishSteak = { TearsUp = 0, TrinketsCount = 0 }
    data.Cornucopia = { IsHolding = false, Charge = 0 }
    data.CrownOfKings = { CanSpawn = false, IsBossChallenge = false, IsBossrush = false, CanRender = true }
    data.CursedDestiny = { Reward = 0 }
    data.Guilt = { DealsCount = 0, CurrentFrame = 0, TempFrame = 1, DevilRoomSpawned = false, SoundPlayed = false, DisableDevilRoom = false, RemoveItems = false, RemoveItemList = {}, RemoveItemFrameList = {}, Effected = -1 }
    data.HadesBlade = { Count = 0 }
    data.ItemQueue = { Frame = -1, ItemID = 0, RoomFrame = -1 }
    data.LaserGun = { IsHolding = false }
    data.LumigyroFly = { Count = 0, Target = nil, RotationList = {}, InProtect = false, DepthOffset = -1 }
    data.Magnifier = { Scale = 1 }
    data.MarriageCertificate = { MainPlayerSeed = -1, IsAlive = true }
    data.Mirroring = { OriginalType = -1 }
    data.OceanusSoul = { Metronome = false }
    data.PlayerSize = { Scale = 1, HugeGrowth = 0, Larger = 0, Smaller = 0 }
    data.Rewind = { RoomList = {}, MaxCharge = 3 }
    data.Warfarin = { Original = -1, UsedCount = 0 }
    data.WakeUp = { CurrentStage = 0, StageType = 0, DetectDogma = false, Used = false, VirtueTriggered = false, BelialTriggered = false, Time = -1, Delay = -1, HealthFactor = 1 }
    data.Stat = {}
    data._REVIVE = {}
    return data
end

local function GetGlobalInitData()
    local function GetItemPoolListInit()
        local itemPoolList = { ItemPoolType.POOL_TREASURE, ItemPoolType.POOL_SHOP, ItemPoolType.POOL_BOSS, ItemPoolType.POOL_DEVIL, ItemPoolType.POOL_ANGEL, ItemPoolType.POOL_DEMON_BEGGAR, ItemPoolType.POOL_SECRET, ItemPoolType.POOL_LIBRARY, ItemPoolType.POOL_RED_CHEST, ItemPoolType.POOL_CURSE, ItemPoolType.POOL_CRANE_GAME, ItemPoolType.POOL_ULTRA_SECRET, ItemPoolType.POOL_PLANETARIUM }
        local list = {}
        local rng = RNG()
        rng:SetSeed(ty.SEEDS:GetStartSeed())
        for stage = 1, 13 do
            local type = rng:RandomInt(#itemPoolList) + 1
            list[stage] = itemPoolList[type]
            table.remove(itemPoolList, type)
            rng:Next()
        end
        return list
    end
    local data = {}
    data.Init = true
    data.BloodSample = { BossDefeated = false, GridIndex = 37, ItemList = {}, InTriggered = false, OutTriggered = false }
    data.CursedDestiny = { ShortestPath = ty.PERSISTENTDATA.ShortestPath, OutOfBounds = false, Owned = false, InDarkness = false }
    data.Mirroring = { Broken = false }
    data.NoticeOfCriticalCondition = { FontAlpha = 0, PreviousSpawnChance = 20, CurrentSpawnChance = 20, MachineList = {}, Disabled = false, ItemList = { 13, 14, 70, 75, 92, 102, 103, 104, 119, 127, 135, 143, 149, 154, 169, 176, 214, 219, 240, 254, 261, 340, 345, 347, 350, 368, 379, 440, 446, 452, 453, 454, 459, 460, 466, 469, 475, 493, 496, 502, 525, 531, 532, 549, 553, 558, 600, 628, 637, 645, 654, 657, 658, 659, 678, 680, 683, 688, 694, 697, 724, 725, 726, 731, ty.CustomCollectibles.ANOREXIA, ty.CustomCollectibles.CONSERVATIVETREATMENT, ty.CustomCollectibles.CONJUNCTIVITIS } }
    data.OceanusSoul = { Strength = 0, RoomList = {} }
    data.Order = { Set = false, ItemPoolList = GetItemPoolListInit(), Timeout = -1 }
    data.TheGospelOfJohn = { Money = {}, BrokenHeart = {} }
    return data
end

local function ResetInitData()
    for _, player in pairs(PlayerManager.GetPlayers()) do
        ty:GetLibData(player).Init = true
        if player:GetFlippedForm() then
            local player = player:GetFlippedForm()
            ty:GetLibData(player).Init = true
        end
    end
end

local function RewindPlayerData()
    for _, player in pairs(PlayerManager.GetPlayers()) do
        ty:SetLibData(player, ty:GetTableCopyFrom(lastRoomData[tostring(player:GetPlayerType())]))
        player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
        if player:GetFlippedForm() then
            local player = player:GetFlippedForm()
            ty:SetLibData(player, ty:GetTableCopyFrom(lastRoomData[tostring(player:GetPlayerType())]))
            player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
        end
    end
    ty.GLOBALDATA = ty:GetTableCopyFrom(lastRoomData["GlobalData"])
end

if (not ty.GLOBALDATA or not ty.GLOBALDATA.Init) and Isaac.IsInGame() then
    for _, player in pairs(PlayerManager.GetPlayers()) do
        ty:SetLibData(player, ty:GetTableCopyFrom(GetInitData()))
        lastRoomData[tostring(player:GetPlayerType())] = ty:GetTableCopyFrom(ty:GetLibData(player))
        player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
        if player:GetFlippedForm() then
            local player = player:GetFlippedForm()
            ty:SetLibData(player, ty:GetTableCopyFrom(GetInitData()))
            lastRoomData[tostring(player:GetPlayerType())] = ty:GetTableCopyFrom(ty:GetLibData(player))
            player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
        end
    end
    ty.GLOBALDATA = ty:GetTableCopyFrom(GetGlobalInitData())
    lastRoomData["GlobalData"] = ty:GetTableCopyFrom(ty.GLOBALDATA)
    ResetInitData()
end

function SaveAndLoad:PostPlayerInit(player)
	ty:SetLibData(player, ty:GetTableCopyFrom(GetInitData()))
end
SaveAndLoad:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, SaveAndLoad.PostPlayerInit)

function SaveAndLoad:PostGameStarted(continued)
    if continued then
        local data = ty.JSON.decode(ty:LoadData())
        for _, player in pairs(PlayerManager.GetPlayers()) do
            ty:SetLibData(player, data[tostring(player:GetPlayerType())])
            player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
            if player:GetFlippedForm() then
                local player = player:GetFlippedForm()
                ty:SetLibData(player, data[tostring(player:GetPlayerType())])
                player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
            end
        end
        ty.GLOBALDATA = ty:GetTableCopyFrom(data["GlobalData"])
        ty.PERSISTENTDATA.ShortestPath = data["GlobalData"].CursedDestiny.ShortestPath
    else
        ty.GLOBALDATA = ty:GetTableCopyFrom(GetGlobalInitData())
    end
    ResetInitData()
end
SaveAndLoad:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, SaveAndLoad.PostGameStarted)

function SaveAndLoad:PreGameExit(shouldSave)
	if shouldSave then
		local data = {}
        for _, player in pairs(PlayerManager.GetPlayers()) do
            data[tostring(player:GetPlayerType())] = ty:GetLibData(player)
            if player:GetFlippedForm() then
                local player = player:GetFlippedForm()
                data[tostring(player:GetPlayerType())] = ty:GetLibData(player)
            end
        end
        data["GlobalData"] = ty.GLOBALDATA
		ty:SaveData(ty.JSON.encode(data))
	end
end
SaveAndLoad:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, SaveAndLoad.PreGameExit)

function SaveAndLoad:PreRoomExit(player, newLevel)
    if not ty.PERSISTENTDATA.Rewind and not newLevel then
        lastRoomData[tostring(player:GetPlayerType())] = ty:GetTableCopyFrom(ty:GetLibData(player))
        lastRoomData["GlobalData"] = ty:GetTableCopyFrom(ty.GLOBALDATA)
        if player:GetFlippedForm() then
            local player = player:GetFlippedForm()
            lastRoomData[tostring(player:GetPlayerType())] = ty:GetTableCopyFrom(ty:GetLibData(player))
        end
    end
end
SaveAndLoad:AddCallback(ModCallbacks.MC_PRE_ROOM_EXIT, SaveAndLoad.PreRoomExit)

function SaveAndLoad:UseItem(itemID, rng, player, useFlags, activeSlot, varData)
	if itemID == CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS then
        ty.PERSISTENTDATA.GlowingHourglass = true
	end
    if itemID == CollectibleType.COLLECTIBLE_GENESIS then
        genesisReset = true
    end
    if itemID == CollectibleType.COLLECTIBLE_ESAU_JR then
		esauJRReset = true
	end
end
SaveAndLoad:AddCallback(ModCallbacks.MC_USE_ITEM, SaveAndLoad.UseItem)

function SaveAndLoad:PostUpdate()
    if esauJRReset then
        for index = 0, ty.GAME:GetNumPlayers() - 1 do
            if PlayerManager.GetEsauJrState(index) then
                ty:GetLibData(Isaac.GetPlayer(index)).Init = true
            end
        end
        esauJRReset = false
    end
    if ty.PERSISTENTDATA.Rewind then
        RewindPlayerData()
        ty.PERSISTENTDATA.Rewind = false
    end
end
SaveAndLoad:AddCallback(ModCallbacks.MC_POST_UPDATE, SaveAndLoad.PostUpdate)

function SaveAndLoad:PostNewRoom(room, roomDesc)
	if genesisReset then
		ResetInitData()
		genesisReset = false
	end
    if ty.PERSISTENTDATA.GlowingHourglass then
        RewindPlayerData()
        ty.PERSISTENTDATA.GlowingHourglass = false
    end
    if Console.GetCommandHistory()[#Console.GetCommandHistory()] == "rewind" and Console.GetHistory()[2] == ">rewind" and not ty.PERSISTENTDATA.Rewind then
        ty.PERSISTENTDATA.Rewind = true
    end
end
SaveAndLoad:AddCallback(ModCallbacks.MC_PRE_NEW_ROOM, SaveAndLoad.PostNewRoom)

return SaveAndLoad