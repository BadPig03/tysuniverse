ty.LoadedLua = {}
ty.ClassesList = {
    Functions = 'functions',
    Card = 'card',
    Pill = 'pill',
    Collectible = 'collectible',
    Stat = 'stat',
    Revive = 'revive',
    SaveAndLoad = 'save_and_load',
    Room = 'room'
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
    'cornucopia',
    'crown_of_kings',
    'cursed_destiny',
    'cursed_treasure',
    'expired_glue',
    'explosion_master',
    'fallen_sky',
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
    'peeled_banana',
    'philosophers_staff',
    'planetarium_telescope',
    'rewind',
    'scapegoat',
    'sinister_pact',
    'the_gospel_of_john',
    'tool_box',
    'wake_up'
}
ty.PocketItemsList = {
    'soul_of_ff0',
    'glowing_hourglass_shard',
    'bait_and_switch'
}
ty.TrinketsList = {
    'broken_glass_eye',
    'lost_bottle_cap',
    'stone_carving_knife',
    'beths_salvation',
    'keepers_core'
}
ty.ChallengesList = {
    'glue_prohibition'
}
ty.PlayersList = {
    'warfarin'
}

ty.GlobalDataName = "_TY_GLOBAL_"
ty.DataName = "_TY_"
ty.TempDataName = "_TY_TEMP_"

include("scripts.class")
include("scripts.constant")
include("scripts.data")

for _, title in pairs(ty.ClassesList) do
    local class = include("scripts."..title)
	table.insert(ty.LoadedLua, class)
	ty[_] = class
end
for _, title in pairs(ty.CollectiblesList) do
    local class = include("scripts.collectibles."..title)
	table.insert(ty.LoadedLua, class)
	ty[_] = class
end
for _, title in pairs(ty.TrinketsList) do
    local class = include("scripts.trinkets."..title)
	table.insert(ty.LoadedLua, class)
	ty[_] = class
end
for _, title in pairs(ty.PocketItemsList) do
    local class = include("scripts.pocket_items."..title)
	table.insert(ty.LoadedLua, class)
	ty[_] = class
end
for _, title in pairs(ty.ChallengesList) do
    local class = include("scripts.challenges."..title)
	table.insert(ty.LoadedLua, class)
	ty[_] = class
end
for _, title in pairs(ty.PlayersList) do
    local class = include("scripts.players."..title)
	table.insert(ty.LoadedLua, class)
	ty[_] = class
end
do
    local class = include("scripts.collectibles.conservative_treatment")
    table.insert(ty.LoadedLua, class)
	ty[#ty.CollectiblesList + 1] = class
end
for _, title in pairs(ty.LoadedLua) do
    title:Register()
end

print("ty's Universe Version "..ty.VERSION.." has fully loaded!")

return ty