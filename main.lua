ty = RegisterMod("ty's Universe [+REPENTOGON]", 1)

ty.VERSION = "02w19c"
ty.REPENTOGONVERSION = "1.0.9d"
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

include("scripts.conflicts")
include("scripts.load")

if EID then
	include("scripts.EID")
end

Isaac.SetWindowTitle(" with ty's Universe "..ty.VERSION.." Enabled!")

function ty:PostRender()
    for _, player in pairs(PlayerManager.GetPlayers()) do
        local controllerIndex = player.ControllerIndex
        if Input.IsActionPressed(ButtonAction.ACTION_DROP, controllerIndex) and Input.IsActionTriggered(ButtonAction.ACTION_RESTART, controllerIndex) then
            player:UseActiveItem(CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS)
            break
        end
    end
end
ty:AddCallback(ModCallbacks.MC_POST_RENDER, ty.PostRender)