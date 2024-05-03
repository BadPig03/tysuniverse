local Pill = ty:DefineANewClass()

local pills = {
    [ty.CustomPills.BAITANDSWITCH] = { Name="偷天换日" }
}

function Pill:UsePill(pillEffect, player, useFlags)
    if pills[pillEffect] then
        ty.HUD:ShowItemText(pills[pillEffect].Name, "")
    end
end
Pill:AddCallback(ModCallbacks.MC_USE_PILL, Pill.UsePill)


return Pill