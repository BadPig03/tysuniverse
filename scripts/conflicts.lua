local specialistForGoodItems = (Epic and true) or false

local function MeetsVersion(targetVersion)
    local version = {}
    local target = {}
    for num in REPENTOGON.Version:gsub("a", ".1"):gsub("b", ".2"):gsub("c", ".3"):gsub("d", ".4"):gsub("e", ".5"):gmatch("%d+") do
        table.insert(version, tonumber(num))
    end
    for num in targetVersion:gsub("a", ".1"):gsub("b", ".2"):gsub("c", ".3"):gsub("d", ".4"):gsub("e", ".5"):gmatch("%d+") do
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
                local warningString = "请勿使用rewind指令，这会导致潜在的bug!"
                ty.LANAPIXEL:DrawStringScaledUTF8(warningString, (Isaac.GetScreenWidth() - ty.LANAPIXEL:GetStringWidthUTF8(warningString)) / 2, (Isaac.GetScreenHeight() - 2 * ty.LANAPIXEL:GetBaselineHeight()), 1, 1, KColor(1, 0, 0, 1))
            else
                local warningString = "Do not use the command rewind, as it may cause potential bugs!"
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
        if specialistForGoodItems then
            if Options.Language == "zh" then
                local warningString = "检测到冲突mod\"The Specialist For Good Items\"!"
                ty.LANAPIXEL:DrawStringScaledUTF8(warningString, (Isaac.GetScreenWidth() - ty.LANAPIXEL:GetStringWidthUTF8(warningString)) / 2, (Isaac.GetScreenHeight() - 2 * ty.LANAPIXEL:GetBaselineHeight()) / 4, 1, 1, KColor(1, 0, 0, 1))
            else
                local warningString = "Mod is conflict with\"The Specialist For Good Items\"!"
                ty.PFTEMP:DrawStringScaledUTF8(warningString, (Isaac.GetScreenWidth() - ty.PFTEMP:GetStringWidthUTF8(warningString)) / 2, (Isaac.GetScreenHeight() - 2 * ty.PFTEMP:GetBaselineHeight()) / 4, 1, 1, KColor(1, 0, 0, 1))
            end
        end
    else
        if Options.Language == "zh" then
            local warningString = "请安装Repentogon!"
            ty.LANAPIXEL:DrawStringScaledUTF8(warningString, (Isaac.GetScreenWidth() - ty.LANAPIXEL:GetStringWidthUTF8(warningString)) / 2, (Isaac.GetScreenHeight() - 2 * ty.LANAPIXEL:GetBaselineHeight()) / 2, 1, 1, KColor(1, 0, 0, 1))
        else
            local warningString = "Please install the Repentogon!"
            ty.PFTEMP:DrawStringScaledUTF8(warningString, (Isaac.GetScreenWidth() - ty.PFTEMP:GetStringWidthUTF8(warningString)) / 2, (Isaac.GetScreenHeight() - 2 * ty.PFTEMP:GetBaselineHeight()) / 2, 1, 1, KColor(1, 0, 0, 1))
        end
    end
end
ty:AddCallback(ModCallbacks.MC_POST_RENDER, ty.PostRender)