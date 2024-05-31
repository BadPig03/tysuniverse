local VIPCard = ty:DefineANewClass()

local functions = ty.Functions

local function GetRoomShopItems()
    local items = {}
    local room = ty.GAME:GetRoom()
    local spawns = ty.LEVEL:GetCurrentRoomDesc().Data.Spawns
    for index = 0, #spawns - 1 do
        local entries = spawns:Get(index)
        local entry = entries:PickEntry(0)
        if entry.Type == EntityType.ENTITY_PICKUP then
            table.insert(items, {Position = room:GetGridPosition(15 * (entries.Y + 1) + entries.X + 1), Variant = entry.Variant, Subtype = entry.Subtype })
        end
    end
    return items
end

function VIPCard:PostUseCard(card, player, useFlags)
    local room = ty.GAME:GetRoom()
    local roomType = room:GetType()
    if roomType == RoomType.ROOM_SHOP or roomType == RoomType.ROOM_BLACK_MARKET then
        room:ShopRestockFull()
    elseif roomType == RoomType.ROOM_DEVIL then
        for _, itemTable in pairs(GetRoomShopItems()) do
            local item = Isaac.Spawn(EntityType.ENTITY_PICKUP, itemTable.Variant, itemTable.Subtype, itemTable.Position, Vector(0, 0), nil):ToPickup()
            item:MakeShopItem(-2)
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, item.Position, Vector(0, 0), nil)
        end
    end
end
VIPCard:AddCallback(ModCallbacks.MC_USE_CARD, VIPCard.PostUseCard, ty.CustomCards.VIPCARD)

return VIPCard