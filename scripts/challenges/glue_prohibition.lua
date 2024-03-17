local GlueProhibition = ty:DefineANewClass()

function GlueProhibition:PostGameStarted(continued)
    if Isaac.GetChallenge() == ty.CustomChallenges.GLUEPROHIBITION and not continued then
        local player = Isaac.GetPlayer()
        player:AddSmeltedTrinket(TrinketType.TRINKET_NO)
    end
end
GlueProhibition:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, GlueProhibition.PostGameStarted)

function GlueProhibition:GetShopItemPrice(variant, subType, itemID, price)
    if Isaac.GetChallenge() == ty.CustomChallenges.GLUEPROHIBITION then
        return math.min(99, math.floor(price * 1.5))
    end
end
GlueProhibition:AddCallback(ModCallbacks.MC_GET_SHOP_ITEM_PRICE, GlueProhibition.GetShopItemPrice)

return GlueProhibition