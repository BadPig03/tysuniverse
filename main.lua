ty = RegisterMod("ty's Universe [+REPENTOGON]", 1)

ty.VERSION = "02w15c"
ty.REPENTOGONVERSION = "1.0.8c"
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
ty.PERSISTENTDATA = { Rewind = false, GlowingHourglass = false, LevelGeneratorRooms = {}, ShortestPath = {} }
ty.JSON = include("json")

include("scripts/load.lua")

if EID then
	include("scripts/EID.lua")
end

local function MeetsVersion(targetVersion)
    local version = {}
    local target = {}
    for num in REPENTOGON.Version:gsub("a", ".1"):gsub("b", ".2"):gsub("c", ".3"):gsub("d", ".4"):gmatch("%d+") do
        table.insert(version, tonumber(num))
    end
    for num in targetVersion:gsub("a", ".1"):gsub("b", ".2"):gsub("c", ".3"):gsub("d", ".4"):gmatch("%d+") do
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

local meetsVersion = MeetsVersion(ty.REPENTOGONVERSION)

function ty:PostRender()
    if REPENTOGON then
        if ty.GAME:GetFrameCount() < 120 then
            if Options.Language == "zh" then
                local warningString = "请注意群内是否有新版本可用!"
                ty.LANAPIXEL:DrawStringScaledUTF8(warningString, (Isaac.GetScreenWidth() - ty.LANAPIXEL:GetStringWidthUTF8(warningString)) / 2, (Isaac.GetScreenHeight() - 2 * ty.LANAPIXEL:GetBaselineHeight()), 1, 1, KColor(1, 0, 0, 1))
            else
                local warningString = "Please check for updates!"
                ty.PFTEMP:DrawStringScaledUTF8(warningString, (Isaac.GetScreenWidth() - ty.PFTEMP:GetStringWidthUTF8(warningString)) / 2, (Isaac.GetScreenHeight() - 2 * ty.PFTEMP:GetBaselineHeight()), 1, 1, KColor(1, 0, 0, 1))
            end
        end
        if not meetsVersion then
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