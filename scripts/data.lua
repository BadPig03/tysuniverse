function ty:GetLibData(entity, temp)
    temp = temp or false
    local dataName = ty.DataName
    if temp then
        dataName = dataName..ty.TempDataName
    end
    local data = entity:GetData()
    data[dataName] = data[dataName] or {}
    return data[dataName]
end

function ty:SetLibData(entity, source, temp)
    temp = temp or false
    local entData = entity:GetData()
    local dataName = ty.DataName
    if temp then
        dataName = dataName..ty.TempDataName
    end
    entData[dataName] = source
end