local Guilt = ty:DefineANewClass()

local itemSprite = Sprite("gfx/005.100_collectible.anm2", true)

local function IsDevilRoomOpened()
    local room = ty.GAME:GetRoom()
    for i = 0, 7 do
        local door = room:GetDoor(i)
        if door and door.TargetRoomType == RoomType.ROOM_DEVIL and door.TargetRoomIndex == GridRooms.ROOM_DEVIL_IDX then
            return true
        end
    end
    return false
end

local function ClearRoom(player, gridOnly)
    local room = ty.GAME:GetRoom()
    if not gridOnly then
        local itemList = {}
        for _, entity in pairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)) do
            if entity:ToPickup():IsShopItem() then
                table.insert(itemList, entity.SubType)
            end
        end
        if #itemList <= 3 then
            repeat
                local rng = player:GetCollectibleRNG(ty.CustomCollectibles.GUILT)
                local item = ty.ITEMPOOL:GetCollectible(ItemPoolType.POOL_DEVIL, false, rng:Next())
                if ty.ITEMCONFIG:GetCollectible(item).Quality <= 2 and rng:RandomInt(100) < 25 then
                    item = ty.ITEMPOOL:GetCollectible(ItemPoolType.POOL_DEVIL, true, rng:Next())
                else
                    ty.ITEMPOOL:RemoveCollectible(item)
                end
                table.insert(itemList, item)
            until #itemList >= 4
        end
        for _, entity in pairs(Isaac.GetRoomEntities()) do
            if entity:ToNPC() or entity:ToPickup() or entity.Type == EntityType.ENTITY_SLOT then
                entity:Remove()
            end
        end
        for item = 1, #itemList do
            if ty.ITEMCONFIG:GetCollectible(itemList[item]) and item <= 4 then
                local positionList = { Vector(280, 320), Vector(360, 320), Vector(200, 280), Vector(440, 280) }
                local pickup = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, itemList[item], positionList[item], Vector(0, 0), nil):ToPickup()
                pickup:MakeShopItem(-2)
            end
        end
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_BLACK, room:FindFreePickupSpawnPosition(Vector(320, 280), 0, true), Vector(0, 0), nil)
    end
    for i = 1, room:GetGridSize() do
        local grid = room:GetGridEntity(i)
        if grid and not (grid:GetType() >= GridEntityType.GRID_WALL and grid:GetType() <= GridEntityType.GRID_GRAVITY) and grid:GetType() ~= GridEntityType.GRID_STATUE and not (player:HasCollectible(CollectibleType.COLLECTIBLE_SANGUINE_BOND) and i == 67) then
            room:RemoveGridEntity(i, 0, false)
        end
    end
    if room:GetGridEntity(52) == nil or (room:GetGridEntity(52) and room:GetGridEntity(52):GetType() ~= GridEntityType.GRID_STATUE) then
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.DEVIL, 0, Vector(320, 240), Vector(0, 0), nil)
        room:SpawnGridEntity(52, GridEntityType.GRID_STATUE, 0, Random(), 0)
    end
end

function Guilt:PostNewRoom()
    local room = ty.GAME:GetRoom()
    for _, player in pairs(PlayerManager.GetPlayers()) do
        if player:HasCollectible(ty.CustomCollectibles.GUILT) then
            local data = ty:GetLibData(player)
            if room:GetType() == RoomType.ROOM_DEVIL then
                if ty.LEVEL:GetCurrentRoomDesc().VisitedCount <= 1 then
                    ClearRoom(player, false)
                else 
                    ClearRoom(player, true)
                end
            end
        end
    end
end
Guilt:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Guilt.PostNewRoom)

function Guilt:PostPlayerNewLevel(player)
    if player:HasCollectible(ty.CustomCollectibles.GUILT) then
        local data = ty:GetLibData(player)
        if data.Guilt.DisableDevilRoom then
            ty.LEVEL:DisableDevilRoom()
            data.Guilt.DisableDevilRoom = false
        end
        if data.Guilt.DevilRoomSpawned and data.Guilt.DealsCount + 2 > ty.GAME:GetDevilRoomDeals() then
            for i = 1, 4 do
                data.Guilt.RemoveItemList[i] = ty.ITEMPOOL:GetCollectible(ItemPoolType.POOL_DEVIL, true)
                data.Guilt.RemoveItemFrameList[i] = 0
            end
            data.Guilt.RemoveItems = true
            data.Guilt.CurrentFrame = ty.GAME:GetFrameCount()
            data.Guilt.TempFrame = 1
        end
        data.Guilt.DealsCount = ty.GAME:GetDevilRoomDeals()
        data.Guilt.DevilRoomSpawned = false
        data.Guilt.SoundPlayed = false
    end
end
Guilt:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_LEVEL, Guilt.PostPlayerNewLevel)

function Guilt:PostPlayerUpdate(player)
    local room = ty.GAME:GetRoom()
    local data = ty:GetLibData(player)
    if data.Init and player:HasCollectible(ty.CustomCollectibles.GUILT) then
        if data.Guilt.Effected == -1 then
            ty.GAME:AddDevilRoomDeal()
            ty.GAME:AddDevilRoomDeal()
            data.Guilt.Effected = ty.LEVEL:GetAbsoluteStage()
        end
        if (ty.LEVEL:CanSpawnDevilRoom() and room:GetType() == RoomType.ROOM_BOSS and IsDevilRoomOpened()) or room:GetType() == RoomType.ROOM_DEVIL then
            data.Guilt.DevilRoomSpawned = true
        end
        if not data.Guilt.SoundPlayed and ty.LEVEL:GetCurrentRoomDesc().GridIndex == GridRooms.ROOM_DEVIL_IDX and ty.GAME:GetDevilRoomDeals() >= data.Guilt.DealsCount + 2 then
            ty.SFXMANAGER:Play(SoundEffect.SOUND_SATAN_GROW)
            data.Guilt.SoundPlayed = true
        end
    end
end
Guilt:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Guilt.PostPlayerUpdate)

function Guilt:PostPlayerRender(player)
    local data = ty:GetLibData(player)
    if data.Init and player:HasCollectible(ty.CustomCollectibles.GUILT) then
        if data.Guilt.RemoveItems and ty.GAME:GetFrameCount() >= data.Guilt.CurrentFrame + 16 then
            if #data.Guilt.RemoveItemList == 0 then
                data.Guilt.RemoveItems = false
                data.Guilt.CurrentFrame = 0
                data.Guilt.TempFrame = 0
            else
                if data.Guilt.RemoveItemList[data.Guilt.TempFrame] then
                    local itemPosition = Isaac.WorldToScreen(player.Position - Vector(0, 32))
                    local color = Color(1, 1, 1, (1 - (data.Guilt.RemoveItemFrameList[data.Guilt.TempFrame] / 90)))
                    itemSprite:ReplaceSpritesheet(1, ty.ITEMCONFIG:GetCollectible(data.Guilt.RemoveItemList[data.Guilt.TempFrame]).GfxFileName, true)
                    itemSprite.Color = color
                    itemSprite:SetFrame("Idle", 0)
                    itemPosition.Y = itemPosition.Y - data.Guilt.RemoveItemFrameList[data.Guilt.TempFrame] / 10
                    itemSprite:Render(itemPosition, Vector(0, 0), Vector(0, 0))
                    if data.Guilt.RemoveItemFrameList[data.Guilt.TempFrame] == 0 then
                        player:AnimateSad()
                    end
                    data.Guilt.RemoveItemFrameList[data.Guilt.TempFrame] = data.Guilt.RemoveItemFrameList[data.Guilt.TempFrame] + 1
                    if data.Guilt.RemoveItemFrameList[data.Guilt.TempFrame] == 90 then
                        data.Guilt.RemoveItemList[data.Guilt.TempFrame] = nil
                        data.Guilt.RemoveItemFrameList[data.Guilt.TempFrame] = nil
                        data.Guilt.TempFrame = data.Guilt.TempFrame + 1
                    end
                end
            end
        end
    end
end
Guilt:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, Guilt.PostPlayerRender)

function Guilt:PostUseCard(card, player, useFlags)
    if player:HasCollectible(ty.CustomCollectibles.GUILT) then
        local data = ty:GetLibData(player)
        if ty.LEVEL:GetCurrentRoomDesc().GridIndex == GridRooms.ROOM_DEVIL_IDX then
            data.Guilt.DisableDevilRoom = true
        end
    end
end
Guilt:AddCallback(ModCallbacks.MC_USE_CARD, Guilt.PostUseCard, Card.CARD_CREDIT)

function Guilt:PostNPCInit(npc)
    local room = ty.GAME:GetRoom()
    for _, player in pairs(PlayerManager.GetPlayers()) do
        if player:HasCollectible(ty.CustomCollectibles.GUILT) and ty.LEVEL:GetCurrentRoomDesc().GridIndex == GridRooms.ROOM_DEVIL_IDX and npc.Variant == 1 then
            npc:Remove()
        end
    end
end
Guilt:AddCallback(ModCallbacks.MC_POST_NPC_INIT, Guilt.PostNPCInit, EntityType.ENTITY_FALLEN)

function Guilt:PostDevilCalculate(chance)
    for _, player in pairs(PlayerManager.GetPlayers()) do
        if player:HasCollectible(ty.CustomCollectibles.GUILT) then
            local data = ty:GetLibData(player)
            return chance + math.max(0, (ty.GAME:GetDevilRoomDeals() - 2)) * 0.05
        end
    end
end
Guilt:AddCallback(ModCallbacks.MC_POST_DEVIL_CALCULATE, Guilt.PostDevilCalculate)

return Guilt