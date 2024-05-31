local Card = ty:DefineANewClass()

local cards = {
    [ty.CustomCards.SOULOFFF0] = { Name="ff0的魂石", Description="血液活化" },
    [ty.CustomCards.GLOWINGHOURGLASSSHARD] = { Name="发光沙漏碎片", Description="逆转时间" },
    --[ty.CustomCards.VIPCARD] = { Name="贵宾卡", Description="如你所愿" }
}

local pickingUpCard = nil

function Card:PostPickupCollision(pickup, collider, low)
    local player = collider:ToPlayer()
    if player and player:CanPickupItem() then
        pickingUpCard = pickup
    end
end
Card:AddCallback(ModCallbacks.MC_POST_PICKUP_COLLISION, Card.PostPickupCollision, PickupVariant.PICKUP_TAROTCARD)

function Card:CardPostUpdate()
    if pickingUpCard then
        local pickup = pickingUpCard
        pickingUpCard = nil
        if not pickup:Exists() or pickup:IsDead() then
            for _, player in pairs(PlayerManager.GetPlayers()) do
                for slot = PillCardSlot.PRIMARY, PillCardSlot.QUATERNARY do
                    local card = player:GetCard(slot)
                    if card == pickup.SubType then
                        Isaac.RunCallbackWithParam("TY_POST_PICK_UP_CARD", nil, card, player)
                        return
                    end
                end
            end
        end
    end
end
Card:AddCallback(ModCallbacks.MC_POST_UPDATE, Card.CardPostUpdate)

function Card:PostPickUpCard(card, player)
    local language = Options.Language
    if cards[card] and language == "zh" then
        ty.HUD:ShowItemText(cards[card].Name, cards[card].Description)
    end
end
Card:AddCallback("TY_POST_PICK_UP_CARD", Card.PostPickUpCard)

return Card