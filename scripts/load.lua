ty.LoadedLua = {}
ty.ClassesList = {
    Revive = 'revive',
    Stat = 'stat',
    HiddenItemManager = 'hiddenitemmanager'
}
ty.CollectiblesList = {
    'absence_note',
    'absolution',
    'anorexia',
    'atonement_voucher',
    'beggar_mask',
    'blood_sacrifice',
    'bobs_stomach',
    'bone_in_fish_steak',
    'chocolate_pancake',
    'collapse',
    'conjunctivitis',
    'conservative_treatment',
    'cornucopia',
    'crown_of_kings',
    'cursed_treasure',
    'expired_glue',
    'guilt',
    'guppys_food',
    'hades_blade',
    'hephaestus_soul',
    'laser_gun',
    'lost_soul',
    'lumigyrofly',
    'magnifier',
    'marriage_certificate',
    'mirroring',
    'notice_of_critical_condition',
    'oceanus_soul',
    'order',
    'philosophers_staff',
    'rewind',
    'scapegoat',
    'telescope',
    'the_gospel_of_john',
    'tool_box',
    'wake_up'
}
ty.PlayersList = {
    'warfarin'
}
ty.ChallengesList = {
    'glue_prohibition'
}
ty.CardsList = {
    'soul_of_ff0'
}

ty.GlobalDataName = "_TY_GLOBAL_"
ty.DataName = "_TY_"
ty.TempDataName = "_TY_TEMP_"

include("scripts.class")
include("scripts.constant")
include("scripts.data")
include("scripts.functions")
include("scripts.collectible")
include("scripts.card")

for _, title in pairs(ty.ClassesList) do
    local class = include("scripts."..title)
	table.insert(ty.LoadedLua, class)
	ty[_] = class
    print("ty's Universe [+REPENTOGON]: Class "..title.." has loaded!")
end
for _, title in pairs(ty.CollectiblesList) do
    local class = include("scripts.collectibles."..title)
	table.insert(ty.LoadedLua, class)
	ty[_] = class
    print("ty's Universe [+REPENTOGON]: Collectible "..title.." has loaded!")
end
for _, title in pairs(ty.PlayersList) do
    local class = include("scripts.players."..title)
	table.insert(ty.LoadedLua, class)
	ty[_] = class
    print("ty's Universe [+REPENTOGON]: Player "..title.." has loaded!")
end
for _, title in pairs(ty.ChallengesList) do
    local class = include("scripts.challenges."..title)
	table.insert(ty.LoadedLua, class)
	ty[_] = class
    print("ty's Universe [+REPENTOGON]: Challenges "..title.." has loaded!")
end
for _, title in pairs(ty.CardsList) do
    local class = include("scripts.cards."..title)
	table.insert(ty.LoadedLua, class)
	ty[_] = class
    print("ty's Universe [+REPENTOGON]: Cards "..title.." has loaded!")
end
for _, title in pairs(ty.LoadedLua) do
    title:Register()
end

return ty