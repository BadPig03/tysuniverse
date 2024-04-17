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

function ty:GetTableCopyFrom(origin)
	if type(origin) ~= "table" then
		return origin
	end
	local new = {}
	for key, value in pairs(origin) do
		local vType = type(value)
		if vType == "table" then
			new[key] = ty:GetTableCopyFrom(value)
		else
			new[key] = value
		end
	end
	return new
end

function ty:IsValueInTable(origin, value)
    if origin == nil or value == nil then
        return false
    end
	for index, item in pairs(origin) do
		if value == item then
			return true
		end
	end
	return false
end

function ty:RemoveValueInTable(origin, value)
    if origin == nil or value == nil then
        return
    end
	for index, item in pairs(origin) do
		if value == item then
			table.remove(origin, index)
		end
	end
end