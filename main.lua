ty = RegisterMod("ty's Universe [+REPENTOGON]", 1)

ty.VERSION = "02w10c"
ty.REPENTOGONVERSION = "1.0.7a"
ty.GAME = Game()
ty.HUD = ty.GAME:GetHUD()
ty.ITEMPOOL = ty.GAME:GetItemPool()
ty.ITEMCONFIG = Isaac.GetItemConfig()
ty.LEVEL = ty.GAME:GetLevel()
ty.SFXMANAGER = SFXManager()
ty.SEEDS = ty.GAME:GetSeeds()
ty.PERSISTENTGAMEDATA = Isaac.GetPersistentGameData()
ty.LANAPIXEL = Font()
ty.LANAPIXEL:Load("font/cjk/lanapixel.fnt")
ty.PFTEMP = Font()
ty.PFTEMP:Load("font/pftempestasevencondensed.fnt")
ty.LUAMIN = Font()
ty.LUAMIN:Load("font/luaminioutlined.fnt")
ty.GLOBALDATA = {}
ty.PERSISTENTDATA = { Rewind = false, GlowingHourglass = false }

local json = require("json")

include("scripts/load.lua")

if EID then
	include("scripts/EID.lua")
    local inlineSprite = Sprite("gfx/eid/inline_icons.anm2", true)
    EID:addIcon("Water", "Water", 0, 10, 10, 0, 0, inlineSprite);
end

local lastRoomData = {}
local genesisReset = false
local esauJRReset = false

local function MeetsVersion(targetVersion)
    local version = {}
    local target = {}
    for num in REPENTOGON.Version:gsub("a", ".1"):gsub("b", ".2"):gmatch("%d+") do
        table.insert(version, tonumber(num))
    end
    for num in targetVersion:gsub("a", ".1"):gsub("b", ".2"):gmatch("%d+") do
        table.insert(target, tonumber(num))
    end
    for i = 1, math.max(#version, #target) do
        local v = version[i] or 0
        local t = target[i] or 0
        if v < t then
            return false
        elseif v > t then
            return true
        end
    end
    return true
end

local function GetInitData()
	local data = {}
	if data.Init == nil then
		data.Init = false
	end
    data.AbsenceNote = { Colors = {}, Count = 0, Triggered = false }
    data.AtonementVoucher = { Effected = false, DevilRoomVisited = false }
    data.BobsStomach = { LastDirectionX = 0, LastDirectionY = 0, Fired = false, CanFire = false }
    data.BloodSacrifice = { UsedCount = {}, VesselList = {}, Respawning = false, PlaySound = false }
    data.BloodSample = { DamageAmount = 0, RedHearts = 0 }
    data.BoneInFishSteak = { TearsUp = 0, TrinketsCount = 0 }
    data.Cornucopia = { IsHolding = false, Charge = 0 }
    data.CrownOfKings = { CanSpawn = false, IsBossChallenge = false, IsBossrush = false, CanRender = true }
    data.Guilt = { DealsCount = 0, CurrentFrame = 0, TempFrame = 1, DevilRoomSpawned = false, SoundPlayed = false, DisableDevilRoom = false, RemoveItems = false, RemoveItemList = {}, RemoveItemFrameList = {}, Effected = -1 }
    data.HadesBlade = { Count = 0 }
    data.HiddenItemManager = { ItemList = {} }
    data.ItemQueue = { Frame = -1, ItemID = 0, RoomFrame = -1 }
    data.LaserGun = { IsHolding = false }
    data.LumigyroFly = { Count = 0, Target = nil, RotationList = {}, InProtect = false, DepthOffset = -1 }
    data.Magnifier = { Scale = 1 }
    data.MarriageCertificate = { MainPlayerSeed = -1, IsAlive = true }
    data.Mirroring = { PlayerType = -1, OldItemList = {}, Health = 0, Bomb = 0, IsDarkJudas = false, IsLazarus2 = false, Charge = 0, BookOfVirtues = false, MirrorBustedPosition = Vector(0, 0), MirroringSpawned = false }
    data.NoticeOfCriticalCondition = { TempBrokenHearts = 0 }
    data.PlayerSize = { Scale = 1, HugeGrowth = 0, Larger = 0, Smaller = 0 }
    data.ReviveTable = { IsDead = false, ReviveTime = 0, ReviveInfo = nil, Reviver = nil, PlayingAnimation = nil, AnimationCountdown = -1 }
    data.Rewind = { RoomList = {}, MaxCharge = 3 }
    data.Stat = { Damage = { Multiplier = 1, DamageUp = 0, Flat = 0 }, Speed = { Limit = -1 }, Tears = { TearsUp = 0, Modifiers = {} } }
    data.WakeUp = { CurrentStage = 0, StageType = 0, DetectDogma = false, Used = false, VirtueTriggered = false, BelialTriggered = false, Time = -1, HealthFactor = 1 }
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
    data.BloodSample = { BossIndex = GridRooms.ROOM_ERROR_IDX, GridIndex = 37, ItemList = {}, InTriggered = false, OutTriggered = false }
    data.ExpiredGlue = {}
    data.NoticeOfCriticalCondition = { FontAlpha = 0, PreviousSpawnChance = 20, CurrentSpawnChance = 20, MachineList = {}, Disabled = false, ItemList = { 13, 14, 70, 75, 92, 102, 103, 104, 119, 127, 135, 143, 149, 154, 169, 176, 214, 219, 240, 254, 261, 340, 345, 347, 350, 368, 379, 440, 446, 452, 453, 454, 459, 460, 466, 469, 475, 493, 496, 502, 525, 531, 532, 549, 553, 558, 600, 628, 637, 645, 654, 657, 658, 659, 678, 680, 683, 688, 694, 697, 724, 725, 726, 731, ty.CustomCollectibles.ANOREXIA, ty.CustomCollectibles.CONSERVATIVETREATMENT, ty.CustomCollectibles.CONJUNCTIVITIS } }
    data.OceanusSoul = { Strength = 0, RoomList = {} }
    data.Order = { Set = false, ItemPoolList = GetItemPoolListInit(), Timeout = -1 }
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
        ty:SetLibData(player, ty:TableCopyTo(lastRoomData[tostring(player:GetPlayerType())]))
        player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
        if player:GetFlippedForm() then
            local player = player:GetFlippedForm()
            ty:SetLibData(player, ty:TableCopyTo(lastRoomData[tostring(player:GetPlayerType())]))
            player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
        end
    end
    ty.GLOBALDATA = ty:TableCopyTo(lastRoomData["GlobalData"])
end

function ty:PostPlayerInit(player)
	ty:SetLibData(player, GetInitData())
end
ty:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, ty.PostPlayerInit)

function ty:PostGameStarted(continued)
    if continued then
        local data = json.decode(ty:LoadData())
        for _, player in pairs(PlayerManager.GetPlayers()) do
            ty:SetLibData(player, data[tostring(player:GetPlayerType())])
            player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
            if player:GetFlippedForm() then
                local player = player:GetFlippedForm()
                ty:SetLibData(player, data[tostring(player:GetPlayerType())])
                player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
            end
        end
        ty.GLOBALDATA = ty:TableCopyTo(data["GlobalData"])
    else
        ty.GLOBALDATA = ty:TableCopyTo(GetGlobalInitData())
        --[[if ImGui and ImGui.ElementExists("MainWindow") then
            ImGui.SetVisible("MainWindow", true)
        end]]
    end
    ResetInitData()
end
ty:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, ty.PostGameStarted)

function ty:PreGameExit(shouldSave)
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
		ty:SaveData(json.encode(data))
	end
end
ty:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, ty.PreGameExit)

function ty:PreRoomExit(player, newLevel)
    if not ty.PERSISTENTDATA.Rewind and not newLevel then
        lastRoomData[tostring(player:GetPlayerType())] = ty:TableCopyTo(ty:GetLibData(player))
        lastRoomData["GlobalData"] = ty:TableCopyTo(ty.GLOBALDATA)
        if player:GetFlippedForm() then
            local player = player:GetFlippedForm()
            lastRoomData[tostring(player:GetPlayerType())] = ty:TableCopyTo(ty:GetLibData(player))
        end
    end
end
ty:AddCallback(ModCallbacks.MC_PRE_ROOM_EXIT, ty.PreRoomExit)

function ty:UseItem(itemID, rng, player, useFlags, activeSlot, varData)
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
ty:AddCallback(ModCallbacks.MC_USE_ITEM, ty.UseItem)

function ty:PostUpdate()
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
ty:AddCallback(ModCallbacks.MC_POST_UPDATE, ty.PostUpdate)

function ty:PostNewRoom()
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
ty:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, ty.PostNewRoom)

function ty:PostRender()
    if REPENTOGON then
        if ty.GAME:GetFrameCount() < 150 then
            if Options.Language == "zh" then
                local warningString = "请注意群内是否有新版本可用!"
                ty.LANAPIXEL:DrawStringScaledUTF8(warningString, (Isaac.GetScreenWidth() - ty.LANAPIXEL:GetStringWidthUTF8(warningString)) / 2, (Isaac.GetScreenHeight() - 2 * ty.LANAPIXEL:GetBaselineHeight()), 1, 1, KColor(1, 0, 0, 1))
            else
                local warningString = "Please check for updates!"
                ty.PFTEMP:DrawStringScaledUTF8(warningString, (Isaac.GetScreenWidth() - ty.PFTEMP:GetStringWidthUTF8(warningString)) / 2, (Isaac.GetScreenHeight() - 2 * ty.PFTEMP:GetBaselineHeight()), 1, 1, KColor(1, 0, 0, 1))
            end
        end
        if not MeetsVersion(ty.REPENTOGONVERSION) then
            if Options.Language == "zh" then
                local warningString = "请更新Repentogon的版本至"..ty.REPENTOGONVERSION.."!"
                ty.LANAPIXEL:DrawStringScaledUTF8(warningString, (Isaac.GetScreenWidth() - ty.LANAPIXEL:GetStringWidthUTF8(warningString)) / 2, (Isaac.GetScreenHeight() - 2 * ty.LANAPIXEL:GetBaselineHeight()) / 2, 1, 1, KColor(1, 0, 0, 1))
            else
                local warningString = "Please update the Repentogon to version "..ty.REPENTOGONVERSION.."!"
                ty.PFTEMP:DrawStringScaledUTF8(warningString, (Isaac.GetScreenWidth() - ty.PFTEMP:GetStringWidthUTF8(warningString)) / 2, (Isaac.GetScreenHeight() - 2 * ty.PFTEMP:GetBaselineHeight()) / 2, 1, 1, KColor(1, 0, 0, 1))
            end
        end
        local versionInfo = ty.VERSION
        ty.LANAPIXEL:DrawStringUTF8(versionInfo, Isaac.GetScreenWidth() - ty.LANAPIXEL:GetStringWidthUTF8(versionInfo) - 1, 0, KColor(1, 1, 1, 1))
        for _, player in pairs(PlayerManager.GetPlayers()) do
            local controllerIndex = player.ControllerIndex
            if Input.IsActionPressed(ButtonAction.ACTION_DROP, controllerIndex) and Input.IsActionTriggered(ButtonAction.ACTION_RESTART, controllerIndex) then
                player:UseActiveItem(CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS)
                break
            end
        end
    end
end
ty:AddCallback(ModCallbacks.MC_POST_RENDER, ty.PostRender)

if REPENTOGON then
    if not ImGui.ElementExists("MainWindow") then
        ty.IMGUIWINDOW = ImGui.CreateWindow("MainWindow", "ty的宇宙mod提示!")
        ImGui.AddText("MainWindow", "欢迎下载ty的宇宙mod进行体验测试!\n\n请注意：\n本mod仍在内测，可能会遇到兼容性问题或bug。\n请及时在群内向作者反映报错！\n同时，请常检查群内mod是否有更新并及时更新！\n\n祝你玩的愉快！", true)
        ImGui.AddButton("MainWindow", "MainWindowButton", "确定", function() ImGui.SetVisible("MainWindow", false) end)
        ImGui.SetWindowSize("MainWindow", 640, 360)
    end
end