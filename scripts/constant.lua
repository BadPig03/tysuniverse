ty.CustomCollectibles = {
    HEPHAESTUSSOUL = Isaac.GetItemIdByName("Hephaestus' Soul"),
    ABSOLUTION = Isaac.GetItemIdByName("Absolution"),
    GUILT = Isaac.GetItemIdByName("Guilt"),
    REWIND = Isaac.GetItemIdByName("Rewind"),
    ANOREXIA = Isaac.GetItemIdByName("Anorexia"),
    MIRRORING = Isaac.GetItemIdByName("Mirroring"),
    BROKENMIRRORING = Isaac.GetItemIdByName("Broken Mirroring"),
    LASERGUN = Isaac.GetItemIdByName("Laser Gun"),
    CORNUCOPIA = Isaac.GetItemIdByName("Cornucopia"),
    NOTICEOFCRITICALCONDITION = Isaac.GetItemIdByName("Notice Of Critical Condition"),
    LUMIGYROFLY = Isaac.GetItemIdByName("Lumigyro Fly"),
    COLLAPSE = Isaac.GetItemIdByName("Collapse"),
    CURSEDTREASURE = Isaac.GetItemIdByName("Cursed Treasure"),
    THEGOSPELOFJOHN = Isaac.GetItemIdByName("The Gospel of John"),
    MAGNIFIER = Isaac.GetItemIdByName("Magnifier"),
    SCAPEGOAT = Isaac.GetItemIdByName("Scapegoat"),
    GUPPYSFOOD = Isaac.GetItemIdByName("Guppy's Food"),
    CONSERVATIVETREATMENT = Isaac.GetItemIdByName("Conservative Treatment"),
    CONJUNCTIVITIS = Isaac.GetItemIdByName("Conjunctivitis"),
    CROWNOFKINGS = Isaac.GetItemIdByName("Crown of Kings"),
    MARRIAGECERTIFICATE = Isaac.GetItemIdByName("Marriage Certificate"),
    ORDER = Isaac.GetItemIdByName("Order"),
    HADESBLADE = Isaac.GetItemIdByName("Hades Blade"),
    BOBSSTOMACH = Isaac.GetItemIdByName("Bob's Stomach"),
    BLOODSACRIFICE = Isaac.GetItemIdByName("Blood Sacrifice"),
    CHOCOLATEPANCAKE = Isaac.GetItemIdByName("Chocolate Pancake"),
    ATONEMENTVOUCHER = Isaac.GetItemIdByName("Atonement Voucher"),
    WAKEUP = Isaac.GetItemIdByName("Wake-up"),
    PHILOSOPHERSSTAFF = Isaac.GetItemIdByName("Philosopher's Staff"),
    EXPIREDGLUE = Isaac.GetItemIdByName("Expired Glue"),
    TOOLBOX = Isaac.GetItemIdByName("Tool Box"),
    BLOODSAMPLE = Isaac.GetItemIdByName("Blood Sample")
}

ty.CustomChallenges = {
    LASERFAN = Isaac.GetChallengeIdByName("Laser Fan")
}

ty.CustomCostumes = {
    HEPHAESTUSSOULFIRE = Isaac.GetCostumeIdByPath("gfx/characters/costume_hephaestus_soul_fire.anm2"),
    WARFARINHAIR = Isaac.GetCostumeIdByPath("gfx/characters/character_warfarin_hair.anm2")
}

ty.CustomNullItems = {
    HEPHAESTUSSOUL = Isaac.GetNullItemIdByName("Hephaestus' Soul Fire"),
    WARFARINHAIR = Isaac.GetNullItemIdByName("Warfarin Hair"),
    WARFARINWINGS = Isaac.GetNullItemIdByName("Warfarin Wings"),
    MARRIAGECERTIFICATEHEARTS = Isaac.GetNullItemIdByName("Marriage Certificate Hearts"),
    LOSTSOUL = Isaac.GetNullItemIdByName("Lost Soul"),
}

ty.CustomEffects = {
    EMPTYHELPER = Isaac.GetEntityVariantByName("Empty Helper"),
    HEPHAESTUSSOULCIRCLE = Isaac.GetEntityVariantByName("Hephaestus Soul Circle"),
    HEPHAESTUSSOULFIREJET = Isaac.GetEntityVariantByName("Hephaestus Soul Fire Jet"),
    LASERSWIRL = Isaac.GetEntityVariantByName("Laser Swirl"),
    CROWNOFKINGS = Isaac.GetEntityVariantByName("Crown of Kings"),
    BOBSSTOMACHCHARGEBAR = Isaac.GetEntityVariantByName("Bobs Stomach Charge Bar"),
    WARFARINBLACKMARKETCRAWLSPACE = Isaac.GetEntitySubTypeByName("Warfarin Blackmarket Crawlspace"),
    WARFARINBLACKMARKETLADDER = Isaac.GetEntityVariantByName("Warfarin Blackmarket Ladder")
}

ty.CustomPlayerType = {
    WARFARIN = Isaac.GetPlayerTypeByName("Warfarin"),
    TAINTEDWARFARIN = Isaac.GetPlayerTypeByName("Tainted Warfarin")
}

ty.CustomEntities = {
    NOTICEOFCRITICALCONDITIONMACHINE = Isaac.GetEntityVariantByName("Notice Of Critical Condition Machine"),
    LUMIGYROFLY = Isaac.GetEntityVariantByName("Lumigyro Fly"),
    TREASUREGHOST = Isaac.GetEntityTypeByName("Treasure Ghost"),
    CURSEDCOIN = Isaac.GetEntitySubTypeByName("Cursed Coin"),
    MAGNIFIER = Isaac.GetEntityVariantByName("Magnifier"),
    BLOODSACRIFICEVESSEL = Isaac.GetEntityVariantByName("Blood Sacrifice Vessel"),
    TOOLBOX = Isaac.GetEntityVariantByName("Tool Box"),
}

ty.ConstantValues = {
    HEPHAESTUSSOULCIRCLEALPHA = 0.25,
    HEPHAESTUSSOULCIRCLE = 180,
    COLLAPSERANGE = 384,
    LASERGUNPLASMABALLRANGE = 160,
    HIDDENITEMMANAGERCONSTANT = 20030730
}

ty.CustomGiantBooks = {
    THEGOSPELOFJOHN = Isaac.GetGiantBookIdByName("TheGospelOfJohnGiantBook")
}

ty.CustomAchievements = {
    FF0UNLOCKED = Isaac.GetAchievementIdByName("ff0_unlocked")
}

ty.CustomSounds = {
    WARFARINHURT = Isaac.GetSoundIdByName("Warfarin Hurt")
}

ty.CharacterMultipliers = {
    [PlayerType.PLAYER_ISAAC] = 1,
    [PlayerType.PLAYER_MAGDALENA] = 1,
    [PlayerType.PLAYER_CAIN] = 1.2,
    [PlayerType.PLAYER_JUDAS] = 1.35,
    [PlayerType.PLAYER_XXX] = 1.05,
    [PlayerType.PLAYER_EVE] = function(player) if player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_WHORE_OF_BABYLON) then return 1 end return 0.75 end,
    [PlayerType.PLAYER_SAMSON] = 1,
    [PlayerType.PLAYER_AZAZEL] = 1.5,
    [PlayerType.PLAYER_LAZARUS] = 1,
    [PlayerType.PLAYER_THELOST] = 1,
    [PlayerType.PLAYER_LAZARUS2] = 1.4,
    [PlayerType.PLAYER_BLACKJUDAS] = 2,
    [PlayerType.PLAYER_LILITH] = 1,
    [PlayerType.PLAYER_KEEPER] = 1.2,
    [PlayerType.PLAYER_APOLLYON] = 1,
    [PlayerType.PLAYER_THEFORGOTTEN] = 1.5,
    [PlayerType.PLAYER_THESOUL] = 1,
    [PlayerType.PLAYER_BETHANY] = 1,
    [PlayerType.PLAYER_JACOB] = 1,
    [PlayerType.PLAYER_ESAU] = 1,
    [PlayerType.PLAYER_ISAAC_B] = 1,
    [PlayerType.PLAYER_MAGDALENA_B] = 0.75,
    [PlayerType.PLAYER_CAIN_B] = 1,
    [PlayerType.PLAYER_JUDAS_B] = 1,
    [PlayerType.PLAYER_XXX_B] = 1,
    [PlayerType.PLAYER_EVE_B] = 1.2,
    [PlayerType.PLAYER_SAMSON_B] = 1,
    [PlayerType.PLAYER_AZAZEL_B] = 1.5,
    [PlayerType.PLAYER_LAZARUS_B] = 1,
    [PlayerType.PLAYER_EDEN_B] = 1,
    [PlayerType.PLAYER_THELOST_B] = 1.3,
    [PlayerType.PLAYER_LILITH_B] = 1,
    [PlayerType.PLAYER_KEEPER_B] = 1,
    [PlayerType.PLAYER_APOLLYON_B] = 1,
    [PlayerType.PLAYER_THEFORGOTTEN_B] = 1.5,
    [PlayerType.PLAYER_BETHANY_B] = 1,
    [PlayerType.PLAYER_JACOB_B] = 1,
	[PlayerType.PLAYER_LAZARUS2_B] = 1.5,
    [ty.CustomPlayerType.WARFARIN] = 1,
}

ty.CollectibleMultipliers = {
    [CollectibleType.COLLECTIBLE_MEGA_MUSH] = function(player) if not player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_MEGA_MUSH) then return 1 end return 4 end,
    [CollectibleType.COLLECTIBLE_MAXS_HEAD] = 1.5,
    [CollectibleType.COLLECTIBLE_MAGIC_MUSHROOM] = function(player) if player:HasCollectible(CollectibleType.COLLECTIBLE_MAXS_HEAD) then return 1 end return 1.5 end,
    [CollectibleType.COLLECTIBLE_BLOOD_MARTYR] = function(player) if not player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL) then return 1 end if player:HasCollectible(CollectibleType.COLLECTIBLE_MAXS_HEAD) or player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_MAGIC_MUSHROOM) then return 1 end return 1.5 end,
    [CollectibleType.COLLECTIBLE_POLYPHEMUS] = 2,
    [CollectibleType.COLLECTIBLE_SACRED_HEART] = 2.3,
    [CollectibleType.COLLECTIBLE_EVES_MASCARA] = 2,
    [CollectibleType.COLLECTIBLE_ODD_MUSHROOM_RATE] = 0.9,
    [CollectibleType.COLLECTIBLE_20_20] = 0.75,
    [CollectibleType.COLLECTIBLE_EVES_MASCARA] = 2,
    [CollectibleType.COLLECTIBLE_SOY_MILK] = function(player) if player:HasCollectible(CollectibleType.COLLECTIBLE_ALMOND_MILK) then return 1 end return 0.2 end,
    [CollectibleType.COLLECTIBLE_CROWN_OF_LIGHT] = function(player) if player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_CROWN_OF_LIGHT) then return 2 end return 1 end,
    [CollectibleType.COLLECTIBLE_ALMOND_MILK] = 0.33,
    [CollectibleType.COLLECTIBLE_IMMACULATE_HEART] = 1.2
}

ty.CollectibleFlatDamages = {
    [CollectibleType.COLLECTIBLE_SACRED_HEART] = function(player, num) return 0.1 end,
    [CollectibleType.COLLECTIBLE_BOZO] = function(player, num) return 0.1 end
}

ty.TrinketFlatDamages = {
    [TrinketType.TRINKET_CURVED_HORN] = 2
}

return ty