local Collectible = ty:DefineANewClass()

local collectibles = {
    [ty.CustomCollectibles.HEPHAESTUSSOUL] = { Name="赫菲斯托斯之魂", Description="火焰化身" },
    [ty.CustomCollectibles.ABSOLUTION] = { Name="赦罪", Description="这不是你的错" },
    [ty.CustomCollectibles.GUILT] = { Name="罪孽", Description="陷入邪恶的深渊" },
    [ty.CustomCollectibles.REWIND] = { Name="倒带", Description="似曾相识" },
    [ty.CustomCollectibles.ANOREXIA] = { Name="厌食症", Description="我吃不下了" },
    [ty.CustomCollectibles.MIRRORING] = { Name="镜像", Description="另一个我" },
    [ty.CustomCollectibles.BROKENMIRRORING] = { Name="碎镜像", Description="另一个我" },
    [ty.CustomCollectibles.LASERGUN] = { Name="激光枪", Description="灼热的等离子" },
    [ty.CustomCollectibles.CORNUCOPIA] = { Name="丰饶羊角", Description="变废为宝" },
    [ty.CustomCollectibles.NOTICEOFCRITICALCONDITION] = { Name="病危通知书", Description="生死未卜" },
    [ty.CustomCollectibles.LUMIGYROFLY] = { Name="霓旋蝇", Description="它们更加暴力" },
    [ty.CustomCollectibles.COLLAPSE] = { Name="坍缩", Description="我很有吸引力" },
    [ty.CustomCollectibles.CURSEDTREASURE] = { Name="被诅咒的宝藏", Description="更多的商品...但代价是什么？" },
    [ty.CustomCollectibles.THEGOSPELOFJOHN] = { Name="约翰福音", Description="憧憬未来" },
    [ty.CustomCollectibles.MAGNIFIER] = { Name="放大镜", Description="放大放大再放大" },
    [ty.CustomCollectibles.SCAPEGOAT] = { Name="替罪羊", Description="承担所有的罪恶和污浊" },
    [ty.CustomCollectibles.GUPPYSFOOD] = { Name="嗝屁猫的罐头", Description="还没过期" },
    [ty.CustomCollectibles.CONSERVATIVETREATMENT] = { Name="保守疗法", Description="不会再恶化了" },
    [ty.CustomCollectibles.CONJUNCTIVITIS] = { Name="结膜炎", Description="眼泪增多" },
    [ty.CustomCollectibles.CROWNOFKINGS] = { Name="主宰之冠", Description="权力易逝" },
    [ty.CustomCollectibles.MARRIAGECERTIFICATE] = { Name="结婚证明", Description="见证坚定不移的爱情" },
    [ty.CustomCollectibles.ORDER] = { Name="秩序", Description="???" },
    [ty.CustomCollectibles.HADESBLADE] = { Name="冥府之刃", Description="心怀鬼胎" },
    [ty.CustomCollectibles.BOBSSTOMACH] = { Name="鲍勃的胃", Description="快要溢出了" },
    [ty.CustomCollectibles.BLOODSACRIFICE] = { Name="鲜血献祭", Description="以血肉铸就" },
    [ty.CustomCollectibles.CHOCOLATEPANCAKE] = { Name="巧克力煎饼", Description="恶魔的最爱" },
    [ty.CustomCollectibles.ATONEMENTVOUCHER] = { Name="赎罪券", Description="拿钱赎罪" },
    [ty.CustomCollectibles.WAKEUP] = { Name="唤醒", Description="这是一场梦吗？" },
    [ty.CustomCollectibles.PHILOSOPHERSSTAFF] = { Name="贤者权杖", Description="别碰它！" },
    [ty.CustomCollectibles.EXPIREDGLUE] = { Name="过期胶水", Description="好臭" },
    [ty.CustomCollectibles.TOOLBOX] = { Name="工具箱", Description="里面有什么？" },
    [ty.CustomCollectibles.OCEANUSSOUL] = { Name="俄刻阿诺斯之魂", Description="海洋化身" },
    [ty.CustomCollectibles.ABSENCENOTE] = { Name="请假条", Description="按时吃药" },
    [ty.CustomCollectibles.BONEINFISHSTEAK] = { Name="带骨鱼排", Description="小心地吃" },
    [ty.CustomCollectibles.PLANETARIUMTELESCOPE] = { Name="星象望远镜", Description="远距离观察" },
    [ty.CustomCollectibles.BEGGARMASK] = { Name="丐帮面具", Description="忠诚！" },
    [ty.CustomCollectibles.PEELEDBANANA] = { Name="剥皮香蕉", Description="甜甜的感觉" },
    [ty.CustomCollectibles.CURSEDDESTINY] = { Name="被诅咒的命运", Description="命中注定" },
    [ty.CustomCollectibles.FALLENSKY] = { Name="天坠", Description="直坠深渊" },
    [ty.CustomCollectibles.BLOODSAMPLE] = { Name="血液样本", Description="血量提升" },
    [ty.CustomCollectibles.BLOODYDICE] = { Name="血之骰", Description="重置你的交易" }
}

local trinkets = {
    [ty.CustomTrinkets.LOSTBOTTLECAP] = { Name="丢失的瓶盖", Description="再来一瓶！" },
    [ty.CustomTrinkets.BROKENGLASSEYE] = { Name="损坏的玻璃眼", Description="它曾经是完整的" },
    [ty.CustomTrinkets.STONECARVINGKNIFE] = { Name="石刻刀", Description="石雕" }
}

function Collectible:ItemQueueUpdate(player)
    if ty.GAME:GetFrameCount() > 0 then
        local data = ty:GetLibData(player)
        local queuedItem = player.QueuedItem
        if not player:IsItemQueueEmpty() and queuedItem.Item then
            if data.ItemQueue and data.ItemQueue.ItemID == 0 then
                data.ItemQueue.ItemID = queuedItem.Item
                data.ItemQueue.Frame = ty.GAME:GetFrameCount()
                Isaac.RunCallback("TY_POST_PICK_UP_COLLECTIBLE", player, queuedItem.Item.ID, queuedItem.Touched, queuedItem.Item:IsTrinket())
            end
        end
        if player:IsItemQueueEmpty() and not queuedItem.Item and data.ItemQueue and data.ItemQueue.ItemID ~= 0 then
            data.ItemQueue.ItemID = 0
            data.ItemQueue.Frame = -1
        end
    end
end
Collectible:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Collectible.ItemQueueUpdate)

function Collectible:PostPickupCollectible(player, itemID, touched, isTrinket)
    local language = Options.Language
    if language ~= "zh" then
        return
    end
    if isTrinket then
        if trinkets[itemID] then
            ty.HUD:ShowItemText(trinkets[itemID].Name, trinkets[itemID].Description)
        end
    else
        if collectibles[itemID] then
            ty.HUD:ShowItemText(collectibles[itemID].Name, collectibles[itemID].Description)
        end
        if player:GetPlayerType() == ty.CustomPlayerType.WARFARIN and itemID == CollectibleType.COLLECTIBLE_BIRTHRIGHT then
            ty.HUD:ShowItemText("长子名分", "更好的转换")
        end
    end
end
Collectible:AddCallback("TY_POST_PICK_UP_COLLECTIBLE", Collectible.PostPickupCollectible)

return Collectible