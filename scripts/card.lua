local cards = {
    [ty.CustomCards.SOULOFFF0] = { Name="ff0的魂石", Description="血液活化" }
}

local pickingUpCard = nil

function ty:PostPickupCollision(pickup, collider, low)
    local player = collider:ToPlayer()
    if player and player:CanPickupItem() then
        pickingUpCard = pickup
    end
end
ty:AddCallback(ModCallbacks.MC_POST_PICKUP_COLLISION, ty.PostPickupCollision, PickupVariant.PICKUP_TAROTCARD)

function ty:CardPostUpdate()
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
ty:AddCallback(ModCallbacks.MC_POST_UPDATE, ty.CardPostUpdate)

function ty:PostPickUpCard(card, player)
    local language = Options.Language
    if cards[card] and language == "zh" then
        ty.HUD:ShowItemText(cards[card].Name, cards[card].Description)
    end
end
ty:AddCallback("TY_POST_PICK_UP_CARD", ty.PostPickUpCard)

return ty