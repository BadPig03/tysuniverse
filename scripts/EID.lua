local EIDInfo = {}
local EIDLanguage = { [1] = "zh_cn", [2] = "en_us" }

EIDInfo.Collectibles = {
    [ty.CustomCollectibles.HEPHAESTUSSOUL] = {
        [1] = {
            Name = "赫菲斯托斯之魂",
            Desc = "#{{Burning}} 免疫火焰伤害，获得飞行并发射火焰泪弹"..
            "#{{Chargeable}} 攻击时光圈会逐渐变亮变大"..
            "#释放时在光圈内喷出火焰并概率发生爆炸"
        },
        [2] = {
            Name = "Hephaestus' Soul",
            Desc = "#{{Burning}} Grants the ability to fly and immunity to fire, while shooting tears with fire"..
            "#{{Chargeable}} While holding down the fire button, the range and brightness of the circle increases"..
            "#Releasing the fire button creates a fire jet under every enemy within the circle, which has a chance to explode"
        }
    },
    [ty.CustomCollectibles.ABSOLUTION] = {
        [1] = {
            Name = "赦罪",
            Desc = "#{{ArrowUp}} 非自伤的伤害均视作自伤"..
            "#{{ArrowUp}} 原本属于自伤的伤害来源只造成一半伤害，最低半颗心"..
            "#{{AngelChance}} 恶魔房开启率转换为天使房开启率，并额外增加20%恶魔房开启率"..
            "#天使房内多选一的道具拿走后不会导致其他道具消失"
        },
        [2] = {
            Name = "Absolution",
            Desc = "#{{ArrowUp}} Damage taken from all sources will be considered as self-inflicted damage"..
            "#{{ArrowUp}} Damage sources that originally belonged to self-inflicted only deal half damage, at a minimum of half a heart"..
            "#{{AngelChance}} Spawns Angel Rooms only, with the same chance of spawning as Devil Rooms, and increase the Devil Room spawning chance by 20%"..
            "#Items in the Angel Room can be taken without causing other items to disappear"
        }
    },
    [ty.CustomCollectibles.GUILT] = {
        [1] = {
            Name = "罪孽",
            Desc = "#{{ArrowUp}} 恶魔房内只生成四个恶魔交易和一颗黑心"..
            "#{{DevilChance}} 每进行一次恶魔交易，恶魔房开启几率增加5%"..
            "#{{Warning}} 开启或进入恶魔房后，若本层内恶魔交易不足两次，进入下一层后移除四个恶魔房道具池的道具"
        },
        [2] = {
            Name = "Guilt",
            Desc = "#{{DevilChance}} Enemies no longer spawn in the Devil Room, and four deals with the Devil, as well as a black heart, are guaranteed"..
            "#{{Warning}} For spawned or entered Devil Rooms, skipping or failing to make at least 2 deals on the current floor, four items will be removed from the Devil Room item pool on the next floor"
        }
    },
    [ty.CustomCollectibles.REWIND] = {
        [1] = {
            Name = "倒带",
            Desc = "#使用后，90%概率随机进入一个与曾进入过的特殊房间种类相同的特殊房间，否则随机进入一个普通房间"..
            "#{{Warning}} 充能数量会因为进入的特殊房间种类不同而产生变化",
            Virtue = "有5%额外概率随机进入一个天使房",
            Belial = "有5%额外概率随机进入一个恶魔房"
        },
        [2] = {
            Name = "Rewind",
            Desc = "#Upon use, there is a 90% chance to randomly enters a special room of the same type as one previously visited; otherwise, randomly enter a normal room"..
            "#{{Warning}} The charge varies depending on the type of special room entered",
            Virtue = "There is a 5% additional chance to randomly enter an Angel Room",
            Belial = "There is a 5% additional chance to randomly enter a Devil Room"
        }
    },
    [ty.CustomCollectibles.ANOREXIA] = {
        [1] = {
            Name = "厌食症",
            Desc = "#{{Heart}} 触发一次'呕血'效果"..
            "#{{Trinket88}} 自动重置'食物'标签的道具"..
            "#{{Warning}} 被大胃王 {{Collectible664}} 覆盖"
        },
        [2] = {
            Name = "Anorexia",
            Desc = "#{{Heart}} Triggers the 'Hematemesis' effect once"..
            "#{{Trinket88}} Rerolls any item which contains the 'food' tag"..
            "#{{Warning}} Overriden by the Binge Eater {{Collectible664}}"
        }
    },
    [ty.CustomCollectibles.MIRRORING] = {
        [1] = {
            Name = "镜像",
            Desc = "#将正常角色转换为对应的堕化角色"..
            "#{{Warning}} 犹大与犹大之影均转换为堕化犹大"..
            "#复活的拉撒路、以扫和ff0无法转换",
            Virtue = "生成血量为6的不可发射泪弹的黑色魂火"
        },
        [2] = {
            Name = "Mirroring",
            Desc = "#Transforms the non-tainted character into the corresponding tainted character"..
            "#{{Warning}} Both Judas and Dark Judas are transformed into Tainted Judas"..
            "#Lazarus Risen, Esau and ff0 can't be transformed",
            Virtue = "Spawns a black wisp with 6 health which can't shoot"
        }
    },
    [ty.CustomCollectibles.BROKENMIRRORING] = {
        [1] = {
            Name = "碎镜像",
            Desc = "#将堕化角色转换为对应的正常角色"..
            "#{{Warning}} 死亡的堕化拉撒路无法转换",
            Virtue = "生成血量为9的不可发射泪弹的白色魂火",
        },
        [2] = {
            Name = "Broken Mirroring",
            Desc = "#Transforms the tainted character into the corresponding non-tainted character"..
            "#{{Warning}} Dead Tainted Lazarus can't be transformed",
            Virtue = "Spawns a white wisp with 9 health which can't shoot"
        }
    },
    [ty.CustomCollectibles.LASERGUN] = {
        [1] = {
            Name = "激光枪",
            Desc = "#生成一个会缓慢移动的等离子激光体"..
            "#它会主动攻击附近一定范围内的敌人"..
            "#{{ArrowUp}} 它对同一敌人的伤害会逐渐增加"
        },
        [2] = {
            Name = "Laser Gun",
            Desc = "#Fires a laser plasma which moves slowly"..
            "#It automatically attacks nearby enemies by firing lasers"..
            "#{{ArrowUp}} The damage it deals to the same enemy increases gradually"
        }
    },
    [ty.CustomCollectibles.CORNUCOPIA] = {
        [1] = {
            Name = "丰饶羊角",
            Desc = "#{{Battery}} 使用后，吸收角色接触到的掉落物、道具和饰品，并转换为充能"..
            "#充能满后使用，如果当前房间内有道具，则为所有道具增加一个道具选择；否则生成一个来自当前房间道具池的道具",
            Virtue = "有10%的概率额外生成一个天使房道具",
            Belial = "有10%的概率额外生成一个恶魔房道具"
        },
        [2] = {
            Name = "Cornucopia",
            Desc = "#{{Battery}} When used, absorbs all pickups, collectibles and trinkets that the player comes into contact with, and converts them into a certain amount of charge"..
            "#{{ArrowUp}} When used if the item is fully charged, spawn a collectible from current room's item pool"..
            "#{{Warning}} The quality of the item is gradually increased",
            Virtue = "Has 10% chance to spawn an extra Angel Room item",
            Belial = "Has 10% chance to spawn an extra Devil Room item"
        }
    },
    [ty.CustomCollectibles.NOTICEOFCRITICALCONDITION] = {
        [1] = {
            Name = "病危通知书",
            Desc = "#{{Pill}} 使用好胶囊时有20%的概率消除一颗碎心"..
            "#{{BrokenHeart}} 每到新层时获得两颗碎心，有概率生成一位医疗护士"
        },
        [2] = {
            Name = "Notice Of Critical Condition",
            Desc = "#{{Pill}} Taking positive pills has 20% chance to remove a broken heart"..
            "#{{BrokenHeart}} Upon a new floor, grants 2 broken hearts. And there is a chance to spawn a Healing Beggar in the starting room"
        }
    },
    [ty.CustomCollectibles.LUMIGYROFLY] = {
        [1] = {
            Name = "霓旋蝇",
            Desc = "#生成三只围绕角色或敌人旋转的霓旋蝇"..
            "#自动寻找最近的敌人攻击，直到敌人死亡"..
            "#{{Damage}} 霓旋蝇对接触的敌人造成每秒10点伤害"..
            "#{{Warning}} 当角色血量过低时进入可阻挡泪弹的护主模式"
        },
        [2] = {
            Name = "Lumigyro Fly",
            Desc = "#Spawns three lumigyro flies that orbit around Isaac or enemies"..
            "#Automatically finds the nearest enemy to attack until the enemy is dead"..
            "#{{Damage}} It deals 10 damage per second to enemies it comes in contact with"..
            "#{{Warning}} When Isaac is low on health, they will protect Isaac by blocking projectiles"
        }
    },
    [ty.CustomCollectibles.COLLAPSE] = {
        [1] = {
            Name = "坍缩",
            Desc = "#{{Magnetize}} 具有磁性并发射磁性泪弹"..
            "#被磁化的敌人每半秒会受到10+角色250%伤害"..
            "#{{Warning}} 会吸引敌人、掉落物、泪弹和炸弹等"..
            "#{{HolyMantle}} 免疫来自敌人的接触伤害与远程激光伤害"
        },
        [2] = {
            Name = "Collapse",
            Desc = "#{{Magnetize}} Isaac is magnetized and fires tears that magnetize enemies"..
            "Magnetized enemies will take 10 + 250% of Isaac damage per half second"..
            "#{{Warning}} Enemies, pickups, tears and bombs will be strongly pulled towards Isaac"..
            "#{{HolyMantle}} Prevents contact damage and laser damage from enemies"
        }
    },
    [ty.CustomCollectibles.CURSEDTREASURE] = {
        [1] = {
            Name = "被诅咒的宝藏",
            Desc = "#将所有种类的硬币替换为诅咒硬币，拾取后触发一次随机硬币系列饰品的效果"..
            "#{{Warning}} 商店里售卖的掉落物会被替换成道具"
        },
        [2] = {
            Name = "Cursed Treasure",
            Desc = "#Replace all types of coins with cursed coins, picking up triggers the effect of a random coin trinket once"..
            "#{{Warning}} Pick ups sold in the shop will be replaced with collectibles, with a 50% chance of being discounted"..
            "#The discount does not stack with {{Collectible64}}Steam Sale and becomes invalid after a reroll"
        }
    },
    [ty.CustomCollectibles.THEGOSPELOFJOHN] = {
        [1] = {
            Name = "约翰福音",
            Desc = "#使用后，清除一颗碎心并重置所在房间的道具为品质{{Quality3}}或{{Quality4}}的天使房道具交易"..
            "#{{BrokenHeart}} 进行道具交易会获得对应数量的碎心"..
            "#{{Warning}} 若天使房道具池过空，则生成{{Collectible390}}撒拉弗",
            Virtue = "生成一个天使房道具魂火跟班",
            Belial = "生成一个恶魔房道具魂火跟班"
        },
        [2] = {
            Name = "The Gospel of John",
            Desc = "#{{BrokenHeart}} Upon use, removes a broken heart and rerolls collectibles in the room, replacing them with collectibles of {{Quality3}} or {{Quality4}} from the Angel Room pool"..
            "#{{BrokenHeart}} Replaced collectible grants broken hearts on purchase"..
            "#{{Warning}} If the Angel Room pool is exhausted, {{Collectible390}}the Seraphim will be selected instead",
            Virtue = "Spawns an Angel item wisp",
            Belial = "Spawns a Devil item wisp"
        }
    },
    [ty.CustomCollectibles.MAGNIFIER] = {
        [1] = {
            Name = "放大镜",
            Desc = "#自动寻找离角色最近的敌人，同时放大周围的敌人"..
            "#{{Warning}} 会导致敌人的碰撞体积和受到的伤害增大"
        },
        [2] = {
            Name = "Magnifer",
            Desc = "#Seeks out the enemy with the lowest health, and can magnify enemies around it"..
            "#{{Warning}} For enemies, the collision size will be magnified, and the damage received will also increase"
        }
    },
    [ty.CustomCollectibles.SCAPEGOAT] = {
        [1] = {
            Name = "替罪羊",
            Desc = "#{{ArrowUp}} 获得一次额外的生命"..
            "#当角色死亡时，人物在当前房间复活，并永久转换为{{Player7}}阿撒泻勒，并额外给予1颗黑心"..
            "#若角色为{{Player28}}堕化阿撒泻勒，则改为获得{{Collectible82}}深渊领主"..
            "#{{Warning}} 复活顺序在{{Card89}}拉撒路的魂石之后，在{{Collectible11}}1UP!之前"
        },
        [2] = {
            Name = "Scapegoat",
            Desc = "#{{ArrowUp}} Grants Isaac an extra life"..
            "#When Isaac dies, he will respawn as {{Player7}}the Azazel permanently in the current room and receive an additional black heart"..
            "#If Isaac is {{Player28}}the Tainted Azazel, he will be granted a {{Collectible82}}Lord of the Pit instead"..
            "#{{Warning}} The revival activates after {{Card89}}Soul of Lazarus, but before{{Collectible11}}1up!"
        }
    },
    [ty.CustomCollectibles.GUPPYSFOOD] = {
        [1] = {
            Name = "嗝屁猫的罐头",
            Desc = "#{{ArrowUp}} +1心之容器"..
            "#{{Heart}} 回满红心",
            BingeEater = "{{ArrowUp}} +1额外伤害"..
            "#{{Collectible664}} {{ArrowUp}} +0.2弹速"..
            "#{{Collectible664}} {{ArrowDown}} -0.03移速"
        },
        [2] = {
            Name = "Guppy's Food",
            Desc = "#{{ArrowUp}} +1 Health up"..
            "#{{Heart}} Full health",
            BingeEater = "{{ArrowUp}} +1 extra Damage"..
            "#{{Collectible664}} {{ArrowUp}} +0.2 Shot Speed"..
            "#{{Collectible664}} {{ArrowDown}} -0.03 Speed"
        }
    },
    [ty.CustomCollectibles.CONSERVATIVETREATMENT] = {
        [1] = {
            Name = "保守疗法",
            Desc = "#{{ArrowUp}} 角色的属性值不会低于{{Player0}}以撒的属性初始值"..
            "#{{Heart}} 如果角色少于三颗心之容器，则补充至三颗心之容器"
        },
        [2] = {
            Name = "Conservative Treatment",
            Desc = "#{{ArrowUp}} The character's attribute values will not be lower than {{Player0}}Isaac's initial attribute values"..
            "#{{Heart}} If Isaac has fewer than three heart containers, then he will be replenished to three heart containers"
        }
    },
    [ty.CustomCollectibles.CONJUNCTIVITIS] = {
        [1] = {
            Name = "结膜炎",
            Desc = "#{{ArrowUp}} 泪弹获得拖尾和穿透敌人与障碍物的效果"..
            "#{{ArrowDown}} 射速修正x80%"
        },
        [2] = {
            Name = "Conjunctivitis",
            Desc = "#{{ArrowUp}} Grants trailing tears that deals extra damage and penetrating tears that travel through enemies and obstacles"..
            "#{{ArrowDown}} x0.8 Fire rate multiplier"
        }
    },
    [ty.CustomCollectibles.CROWNOFKINGS] = {
        [1] = {
            Name = "主宰之冠",
            Desc = "#{{BossRoom}} 未受到任何伤害的情况下清理完初始含有头目的房间："..
            "#{{Collectible}} 额外掉落一个来自随机道具池的品质不高于3的道具"
        },
        [2] = {
            Name = "Crown of Kings",
            Desc = "#{{BossRoom}} Cleaning a room containing any boss without being hit:"..
            "#{{Collectible}} Spawns an extra item of at most quality 3 from random item pools"
        }
    },
    [ty.CustomCollectibles.MARRIAGECERTIFICATE] = {
        [1] = {
            Name = "结婚证明",
            Desc = "#{{Player5}} 生成夏娃作为第二个角色，并随机复制角色身上的三个被动道具"..
            "#夏娃死亡后变为无敌的灵魂形态，伤害降低，在进入下一层时复活"..
            "#若夏娃进入下一层时未死亡，则随机复制角色身上的三个被动道具"..
            "#{{Warning}} 夏娃拾取的所有被动道具都会转移到角色身上"
        },
        [2] = {
            Name = "Marriage Certificate",
            Desc = "#{{Player5}} Grants Eve as the second character and randomly grants three duplicated passive items from Isaac"..
            "#After Eve's death, she transforms into an invulnerable ghost with reduced damage and revives upon entering the next floor"..
            "#If Eve is still alive upon entering the next floor, she grants three duplicated passive items from Isaac as well"..
            "#{{Warning}} All passive items picked up by Eve will transfer to Isaac"
        }
    },
    [ty.CustomCollectibles.ORDER] = {
        [1] = {
            Name = "秩序",
            Desc = "#每层生成的底座道具将来自不同的固定道具池"..
            "#{{Warning}} 替代章节的道具池由章节层数决定"
        },
        [2] = {
            Name = "Order",
            Desc = "#Collectibles on each floor will be chosen from different item pools"..
            "#{{Warning}} The item pool of the alternative chapter is determined by the chapter level"
        }
    },
    [ty.CustomCollectibles.HADESBLADE] = {
        [1] = {
            Name = "冥府之刃",
            Desc = "#{{Heart}} 使用时，若为红心角色，则移除一个心之容器"..
            "#{{Conjoined}} 生成一个来自恶魔房道具池的跟班"..
            "#{{SoulHeart}} 若为魂心角色，则移除两个魂心"..
            "#{{BoneHeart}} 优先扣除骨心"..
            "#{{Warning}} 如果恶魔房道具池过空，则生成{{Collectible113}}恶魔宝宝",
            Virtue = "生成血量为10，伤害为2的红色魂火",
            Belial = "额外获得0.2伤害提升"
        },
        [2] = {
            Name = "Hades Blade",
            Desc = "#{{Heart}} Upon use, for red heart characters, removes one red heart container"..
            "#{{SoulHeart}} For soul heart characters, two soul hearts are removed instead"..
            "#{{BoneHeart}} Bone hearts are removed first"..
            "#{{Conjoined}} Grants a familiar selected from the Devil Room pool"..
            "#{{Warning}} If the Devil Room pool is exhausted, {{Collectible113}}Demon Baby will be selected instead",
            Virtue = "Spawns a red wisp with 10 health and can deal 2 damage to enemies",
            Belial = "Grants +0.2 damage up"
        }
    },
    [ty.CustomCollectibles.BOBSSTOMACH] = {
        [1] = {
            Name = "鲍勃的胃",
            Desc = "#{{Chargeable}} 蓄力2.5秒后射出一颗爆炸泪弹"..
            "#{{Damage}} 造成15+角色250%伤害"..
            "#{{Poison}} 爆炸泪弹飞行时会产生毒性水迹"
        },
        [2] = {
            Name = "Bob's Stomach",
            Desc = "#{{Chargeable}} After firing tears for 2.5 seconds, releasing the fire button fires an explosive and poisoning tear"..
            "#{{Damage}} Deals damage equal to 15 + 250% of Isaac's damage"..
            "#{{Poison}} The tear leaves a trail of green creep"
        }
    },
    [ty.CustomCollectibles.BLOODSACRIFICE] = {
        [1] = {
            Name = "鲜血献祭",
            Desc = "#{{Heart}} 使用时移除一个心之容器并提供0.2伤害加成"..
            "#在角色附近生成一个肉身，可以作为当前层的复活点"..
            "#{{Warning}} 一层内可以放置多个肉身，优先从最后放置的肉身处复活",
            Virtue = "生成血量为8，伤害为3的红色魂火",
            Belial = "额外获得0.2伤害提升"
        },
        [2] = {
            Name = "Blood Sacrifice",
            Desc = "#{{Heart}} Upon use, removes one red heart container and grants +0.2 damage up"..
            "#Spawns a body which can revive Isaac in current floor"..
            "#{{Warning}} Multiple bodies can exist and Isaac will be revived at the position of the last placed body",
            Virtue = "Spawns a red wisp with 8 health and can deal 3 damage to enemies",
            Belial = "Grants +0.2 damage up"
        }
    },
    [ty.CustomCollectibles.CHOCOLATEPANCAKE] = {
        [1] = {
            Name = "巧克力煎饼",
            Desc = "#{{EmptyHeart}} +1空的心之容器"..
            "#{{DevilChance}} 与恶魔的一次交易免费"..
            "#{{Warning}} 免费交易后失去该道具",
            BingeEater = "{{ArrowUp}} +1幸运"..
            "#{{Collectible664}} {{ArrowUp}} +0.2弹速"..
            "#{{Collectible664}} {{ArrowDown}} -0.03移速"
        },
        [2] = {
            Name = "Chocolate Pancake",
            Desc = "#{{EmptyHeart}} +1 Empty heart container"..
            "#{{DevilChance}} Makes a deal with the Devil free"..
            "#{{Warning}} After dealing with the Devil, the collectible disappears",
            BingeEater = "{{ArrowUp}} +1 Luck"..
            "#{{Collectible664}} {{ArrowUp}} +0.2 Shotspeed"..
            "#{{Collectible664}} {{ArrowDown}} -0.03 Speed"
        }
    },
    [ty.CustomCollectibles.ATONEMENTVOUCHER] = {
        [1] = {
            Name = "赎罪券",
            Desc = "#{{AngelChance}} 本层开启天使房的几率为100%"..
            "#{{Warning}} 开启后会失去赎罪券"..
            "#{{DevilChance}} 若角色曾进入过恶魔房或进行过恶魔交易，则改为生成{{Collectible673}}赎罪并失去赎罪券"
        },
        [2] = {
            Name = "Atonement Voucher",
            Desc = "#{{AngelChance}} Causes an Angel Room to always spawn on current floor"..
            "#{{Warning}} Isaac loses the Atonement Voucher after the Angel room is spawned on current floor"..
            "#{{DevilChance}} If a Devil Deal was taken or a Devil room was visited previously, spawns a {{Collectible673}}Redemption and loses the Atonement Voucher instead"
        }
    },
    [ty.CustomCollectibles.WAKEUP] = {
        [1] = {
            Name = "唤醒",
            Desc = "#{{IsaacsRoom}} 传送到'家'一层并随机生成3个最低品质为3的攻击道具"..
            "#{{Heart}} 恢复所有血量"..
            "#{{Warning}} 击败教条后直接进入下一层",
            Virtue = "道具来自天使房道具池",
            Belial = "道具来自恶魔房道具池",
            WakeUp = "#{{ArrowUp}} 教条血量百分比为"
        },
        [2] = {
            Name = "Wake-up",
            Desc = "#{{IsaacsRoom}} Teleports Isaac to Home and spawns 3 offensive items of at least quality 3 from random item pools"..
            "#{{Heart}} Full Health"..
            "#{{Warning}} Go to next stage if the Dogma is killed",
            Virtue = "Collectibles are selected from Angel Room item pool instead",
            Belial = "Collectibles are selected from Devil Room item pool instead",
            WakeUp = "#{{ArrowUp}} The percent of the health of the Dogma is "
        }
    },
    [ty.CustomCollectibles.PHILOSOPHERSSTAFF] = {
        [1] = {
            Name = "贤者权杖",
            Desc = "#{{ArrowUp}} 持有时，角色身上的饰品会转化为对应金饰品"..
            "#击杀敌人时有4%的概率掉落随机饰品"..
            "#使用后，摧毁房间内的所有饰品，每摧毁一个饰品将生成4-8个随机硬币",
            Virtue = "15%概率发射点金术眼泪",
            Belial = "额外生成3个随机硬币",
        },
        [2] = {
            Name = "Philosopher's Staff",
            Desc = "#{{ArrowUp}} When held, trinkets on Isaac will transform into their corresponding golden trinkets"..
            "Enemies have 4% chance to drop a trinket on death"..
            "#Upon use, consume all trinkets in the room. For each trinket consumed, spawns 4-8 random coins",
            Virtue = "15% chance for {{Collectible202}} Midas' Touch tears",
            Belial = "Spawns 3 random coins"
        }
    },
    [ty.CustomCollectibles.EXPIREDGLUE] = {
        [1] = {
            Name = "过期胶水",
            Desc = "#每0.2秒，有2%的概率将硬币(镍币概率翻倍)替换为黏性镍币"..
            "#被炸的黏性镍币也可能被替换为黏性镍币"..
            "#{{Warning}} 替换后会重置消失时间"
        },
        [2] = {
            Name = "Expired Glue",
            Desc = "#Every 0.2 seconds, there is a 2% chance that any coin (nickel coin with a doubled probability) will be replaced with a sticky nickel coin",
            "#The sticky nickel coin that has been exploded may also be replaced with a sticky nickel coin"..
            "#{{Warning}} After replacement, the disappearance time will be reset"
        }
    },
    [ty.CustomCollectibles.TOOLBOX] = {
        [1] = {
            Name = "工具箱",
            Desc = "#生成一个工具箱跟班"..
            "#{{Card}} 每清理六个房间后生成一张随机特殊卡牌"
        },
        [2] = {
            Name = "Tool Box",
            Desc = "#Spawns a tool box familiar"..
            "#{{Card}} Randomly spawns a special tarot card every 6 rooms"
        }
    },
    [ty.CustomCollectibles.OCEANUSSOUL] = {
        [1] = {
            Name = "俄刻阿诺斯之魂",
            Desc = "#{{Water}} 将房间充满水，射击蓄力可以使房间产生水流和可吸引物体的水柱"..
            "#水流可推动敌人撞到障碍物或房间墙壁并受伤，还可以对静止或石化的地面敌人造成伤害"..
            "#{{ArrowUp}} 立即杀死火系的敌人和Boss"..
            "#{{ArrowDown}} -40%射速修正"
        },
        [2] = {
            Name = "Oceanus' Soul",
            Desc = "#{{Water}} Fills the room with water. Shoots to expel strong water flow and spawn water pillars that attract objects"..
            "#The water flow can push enemies into obstacles or walls, causing them damage, and can also harm stationary or petrified ground enemies"..
            "#{{ArrowUp}} Instantly kills burning enemies and Bosses"..
            "#{{ArrowDown}} -40% fire rate multiplier",
        }
    },
    [ty.CustomCollectibles.ABSENCENOTE] = {
        [1] = {
            Name = "请假条",
            Desc = "#每当角色睡觉或进入下一层时获得一颗胶囊"..
            "#{{Pill}} 每使用4种不同颜色的胶囊或12次任意胶囊，直接获得一个随机疾病道具"..
            "#{{Pill14}} 金胶囊视作单独的颜色，并算作使用1次"..
            "#大胶囊视作单独的颜色，并算作使用2次",
        },
        [2] = {
            Name = "Absence Note",
            Desc = "#Grants a pill whenever Isaac sleeps or is on a new floor"..
            "#{{Pill}} Obtains a random disease item directly by using 4 different colored pills or any pill 12 times"..
            "#{{Pill14}} Gold pills are considered as a separate color and count as using once"..
            "#Horse pills are considered as a separate color and count as using twice",
        }
    },
    [ty.CustomCollectibles.BONEINFISHSTEAK] = {
        [1] = {
            Name = "带骨鱼排",
            Desc = "#{{ArrowUp}} +1心之容器"..
            "#每当角色拾取'食物'标签道具或者吞下任何饰品时："..
            "#{{Collectible486}} 使角色受伤但不掉血"..
            "#{{Tears}} 永久+0.2射速修正",
            BingeEater = "{{ArrowUp}} +1额外伤害"..
            "#{{Collectible664}} {{ArrowUp}} +1幸运"..
            "#{{Collectible664}} {{ArrowDown}} -0.03移速"
        },
        [2] = {
            Name = "Bone-in Fish Steak",
            Desc = "#{{ArrowUp}} +1 Health up"..
            "#Whenever Isaac picks up an item which contains the 'food' tag or consumes any trinket"..
            "#{{Collectible486}} Causes Isaac to take damage without taking away health"..
            "#{{Tears}} +0.2 Fire rate permanently",
            BingeEater = "{{ArrowUp}} +1 Extra damage"..
            "#{{Collectible664}} {{ArrowUp}} +1 Luck"..
            "#{{Collectible664}} {{ArrowDown}} -0.03 Speed"
        }
    },
    [ty.CustomCollectibles.PLANETARIUMTELESCOPE] = {
        [1] = {
            Name = "星象望远镜",
            Desc = "#{{Card}} 生成一张'XVII-星星'卡牌"..
            "#{{ArrowUp}} 每持有一个有'星星'标签的道具会获得+2幸运值和+0.25射速修正"..
            "#{{Planetarium}} 进入新的一层时，星象房的开启概率为幸运值/24"..
            "#{{Warning}} 允许在第三章之后开启星象房，并可以拾取星象房中的所有道具"
        },
        [2] = {
            Name = "Planetarium Telescope",
            Desc = "#{{Card}} Spawns a tarot card 'XVII-Star'"..
            "#{{ArrowUp}} Each collectible with a 'star' tag will grant +2 luck and +0.25 fire rate"..
            "#{{Planetarium}} When entering a new floor, the Planetarium chance is luck / 24"..
            "#{{Warning}} Allows the spawning of the Planetarium Room after Chapter 3"..
            "#Isaac can pick up all collectibles in the Planetarium Room"
        }
    },
    [ty.CustomCollectibles.BEGGARMASK] = {
        [1] = {
            Name = "丐帮面具",
            Desc = "#{{ArrowUp}} 部分房间第一次进入时会额外生成一个对应的乞丐"..
            "#每次向乞丐捐赠时增加生成掉落物的概率"..
            "#当乞丐生成道具时，额外生成一个道具交易或者再次生成一个乞丐"..
            "#{{Warning}} 如果任意乞丐被炸死，则失去'丐帮面具'道具"
        },
        [2] = {
            Name = "Beggar Mask",
            Desc = "#{{ArrowUp}} A beggar will be spawned in some rooms upon the first entry"..
            "#For every donation received, beggars have a higher chance to drop a random pick up"..
            "#When a beggar drops an item, another item trade or a new beggar will be spawned"..
            "#{{Warning}} If a beggar is killed by explosion, the Beggar Mask is removed"
        }
    },
    [ty.CustomCollectibles.PEELEDBANANA] = {
        [1] = {
            Name = "剥皮香蕉",
            Desc = "#{{ArrowUp}} +1心之容器并治疗一颗红心"..
            "#{{Heart}} 进入新的房间时，有25%的概率治疗半颗红心"..
            "#{{Warning}} 多个道具的概率可叠加",
            BingeEater = "{{ArrowUp}} +2.5射程"..
            "#{{Collectible664}} {{ArrowUp}} +1幸运"..
            "#{{Collectible664}} {{ArrowDown}} -0.03移速"
        },
        [2] = {
            Name = "Peeled Banana",
            Desc = "#{{ArrowUp}} +1 Health up and heals 1 red heart"..
            "#{{Heart}}Has 25% chance to heal half a heart every new room"..
            "#{{Warning}}The probabilities of multiple bananas can stack",
            BingeEater = "{{ArrowUp}} +2.5 Tear range"..
            "#{{Collectible664}} {{ArrowUp}} +1 Luck"..
            "#{{Collectible664}} {{ArrowDown}} -0.03 Speed"
        }
    },
    [ty.CustomCollectibles.CURSEDDESTINY] = {
        [1] = {
            Name = "被诅咒的命运",
            Desc = "#显示地图轮廓与隐藏房、头目房的图标，并将通往头目房最近的路作为主路"..
            "#{{ArrowUp}} 消灭本层头目后会获得随机属性提升"..
            "#{{DevilChance}} 若未离开过主路，则一定开启恶魔房并在头目房内给予{{Collectible108}}圣饼效果"..
            "#{{CurseDarkness}} 非主路的房间内会变得黑暗，同时拥有负面效果"..
            "#{{Warning}} 部分楼层和特殊维度不生效"
        },
        [2] = {
            Name = "Cursed Destiny",
            Desc = "#Displays map outlines along with icons for secret rooms and boss rooms, and marks the path leading to the nearest boss room as the main route"..
            "#{{ArrowUp}} Defeating the boss on the floor will grant stats increases"..
            "#{{DevilChance}} If Isaac has not deviated from the main route when fighting the boss, he will be given damage resistance in the boss room and a Devil Room will always open"..
            "#{{CurseDarkness}} Rooms off the main route will be dark and Isaac grants negative effects"..
            "#{{Warning}} Doesn't work on certain floors and other dimensions"
        }
    },
    [ty.CustomCollectibles.BLOODSAMPLE] = {
        [1] = {
            Name = "血液样本",
            Desc = "#{{EmptyHeart}} 获得一个空的心之容器"
        },
        [2] = {
            Name = "Blood Sample",
            Desc = "#{{EmptyHeart}} Grants an empty health container"
        }
    },
    [ty.CustomCollectibles.BLOODYDICE] = {
        [1] = {
            Name = "血之骰",
            Desc = "#将最近一个恶魔交易免费并重置为本房间内道具池的道具",
        },
        [2] = {
            Name = "Bloody Dice",
            Desc = "#Makes the nearest Devil Deal free and rerolls into items from the current room's item pool",
        }
    }
}

EIDInfo.Cards = {
    [ty.CustomCards.SOULOFFF0] = {
        [1] = {
            Name = "ff0的魂石",
            Desc = "#{{Heart}} 给予可获得心之容器的能力并立即获得两颗心之容器"..
            "#{{Warning}} 效果仅持续一层，结束后将所有的心之容器转换为原本可接受的血量"
        },
        [2] = {
            Name = "Soul of ff0",
            Desc = "#{{Heart}} Grant the ability to obtain heart containers and immediately receive two heart containers"..
            "#{{Warning}} The ability only lasts for one floor, after which all heart containers will get converted"
        }
    }
}

EID:addIcon("Player"..ty.CustomPlayerType.WARFARIN, "Players", 0, 16, 16, 0, 0, Sprite("gfx/eid/player_icons.anm2", true))
EID:addIcon("Card"..ty.CustomCards.SOULOFFF0, "Soul of ff0", -1, 9, 9, -1, 0, Sprite("gfx/eid/eid_cardfronts.anm2", true))
EID:addIcon("Water", "Water", 0, 10, 10, 0, 0, Sprite("gfx/eid/inline_icons.anm2", true))
EID:addBirthright(ty.CustomPlayerType.WARFARIN, "#{{Heart}} 使用血液样本时额外恢复一颗红心 #{{ArrowUp}} 心上限数量增加到9个", "ff0", "zh_cn")
EID:addBirthright(ty.CustomPlayerType.WARFARIN, "#{{Heart}} Heals one red heart when using the Blood Sample #{{ArrowUp}} The max amount of heart containers is raised to 9", "ff0", "en_us")

for ID, descTable in pairs(EIDInfo.Collectibles) do
    for i = 1, 2 do
        EID:addCollectible(ID, descTable[i].Desc, descTable[i].Name, EIDLanguage[i])
    end
end

for ID, descTable in pairs(EIDInfo.Cards) do
    for i = 1, 2 do
        EID:addCard(ID, descTable[i].Desc, descTable[i].Name, EIDLanguage[i])
    end
end

do
    local function VirtueCondition(descObj)
        return descObj.ObjType == EntityType.ENTITY_PICKUP and descObj.ObjVariant == PickupVariant.PICKUP_COLLECTIBLE and EID.collectiblesOwned[CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES]
    end
    local function VirtueCallback(descObj)
        local subType = descObj.ObjSubType
        local language, languageIndex = Options.Language, 2
        if language == "zh" then
            languageIndex = 1
        end
        if EIDInfo.Collectibles[subType] then
            local virtueDesc = EIDInfo.Collectibles[subType][languageIndex].Virtue
            if virtueDesc then
                EID:appendToDescription(descObj, "#{{Collectible584}} "..virtueDesc)
            end
        end
        return descObj
    end
    EID:addDescriptionModifier("tyVirtueModifier", VirtueCondition, VirtueCallback)
end

do
    local function BelialCondition(descObj)
        return descObj.ObjType == EntityType.ENTITY_PICKUP and descObj.ObjVariant == PickupVariant.PICKUP_COLLECTIBLE and EID.collectiblesOwned[CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL_PASSIVE]
    end
    local function BelialCallback(descObj)
        local subType = descObj.ObjSubType
        local language, languageIndex = Options.Language, 2
        if language == "zh" then
            languageIndex = 1
        end
        if EIDInfo.Collectibles[subType] then
            local belialDesc = EIDInfo.Collectibles[subType][languageIndex].Belial
            if belialDesc then
                EID:appendToDescription(descObj, "#{{Collectible59}} "..belialDesc)
            end
        end
        return descObj
    end
    EID:addDescriptionModifier("tyBelialModifier", BelialCondition, BelialCallback)
end

do
    local function BingeEaterCondition(descObj)
        return descObj.ObjType == EntityType.ENTITY_PICKUP and descObj.ObjVariant == PickupVariant.PICKUP_COLLECTIBLE and EID.collectiblesOwned[CollectibleType.COLLECTIBLE_BINGE_EATER]
    end
    local function BingeEaterCallback(descObj)
        local subType = descObj.ObjSubType
        local language, languageIndex = Options.Language, 2
        if language == "zh" then
            languageIndex = 1
        end
        if EIDInfo.Collectibles[subType] then
            local bingeEaterDesc = EIDInfo.Collectibles[subType][languageIndex].BingeEater
            if bingeEaterDesc then
                EID:appendToDescription(descObj, "#{{Collectible664}} "..bingeEaterDesc)
            end
        end
        return descObj
    end
    EID:addDescriptionModifier("tyBingeEaterModifier", BingeEaterCondition, BingeEaterCallback)
end

do
    local function WakeUpCondition(descObj)
        return descObj.ObjType == EntityType.ENTITY_PICKUP and descObj.ObjVariant == PickupVariant.PICKUP_COLLECTIBLE and descObj.ObjSubType == ty.CustomCollectibles.WAKEUP
    end
    local function WakeUpCallback(descObj)
        local language, languageIndex = Options.Language, 2
        if language == "zh" then
            languageIndex = 1
        end
        local wakeUpDesc = EIDInfo.Collectibles[ty.CustomCollectibles.WAKEUP][languageIndex].WakeUp
        if wakeUpDesc then
            EID:appendToDescription(descObj, wakeUpDesc..string.format("%.1f", (math.min(math.max(Game():GetLevel():GetAbsoluteStage() / 22 + 5 / 11, 0.5), 1) * 100)).."%")
        end
        return descObj
    end
    EID:addDescriptionModifier("tyWakeUpModifier", WakeUpCondition, WakeUpCallback)
end