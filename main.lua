local DATA_FOLDER = 'data'
local POSTAL_FILE = DATA_FOLDER .. '/postals.json'
local CITY_FILE = DATA_FOLDER .. '/cities.json'
local COUNTY_FILE = DATA_FOLDER .. '/counties.json'

local playerLocationData = {}

local function loadData(fileName)
    local file = LoadResourceFile(GetCurrentResourceName(), fileName)
    if file then
        local data = json.decode(file)
        if data then
            print("Loaded " .. fileName .. " successfully with " .. #data .. " entries.")
            return data
        else
            print("[Error] JSON decoding failed for " .. fileName)
            return {}
        end
    else
        print("[Error] Failed to load " .. fileName)
        return {}
    end
end

local postals, cities, counties = loadData(POSTAL_FILE), loadData(CITY_FILE), loadData(COUNTY_FILE)

local function calculateDistance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

local function getNearestLocation(coords, locations)
    local nearest = nil
    local shortestDistance = math.huge
    for _, location in ipairs(locations) do
        local distance = calculateDistance(coords.x, coords.y, location.x, location.y)
        if distance < shortestDistance then
            nearest = location
            shortestDistance = distance
        end
    end
    return nearest
end

RegisterNetEvent('ImperialLocation:updateNearest')
AddEventHandler('ImperialLocation:updateNearest', function(playerCoords, shouldDisplay)
    local src = source
    local nearestPostal = getNearestLocation(playerCoords, postals)
    local nearestCity = getNearestLocation(playerCoords, cities)
    local nearestCounty = getNearestLocation(playerCoords, counties)

    playerLocationData[src] = {
        postal = nearestPostal,
        city = nearestCity,
        county = nearestCounty
    }

    TriggerClientEvent('ImperialLocation:receiveNearest', src, nearestPostal, nearestCity, nearestCounty)

     if shouldDisplay then
        TriggerClientEvent('ImperialLocation:PrintNearest', src, nearestPostal, nearestCity, nearestCounty)
    end
end)

RegisterCommand("debugLocationData", function(src)
    print("^3[IMPERIAL DEBUG]^7 Dumping all player location data:")
    for playerId, data in pairs(playerLocationData) do
        print(("Player %s:"):format(playerId))
        print("  Postal:", data.postal and json.encode(data.postal.code) or "None")
        print("  City:  ", data.city and json.encode(data.city.city) or "None")
        print("  County:", data.county and json.encode(data.county.county) or "None")
    end
end, true)

exports('getPostal', function(playerId)
    return playerLocationData[playerId] and playerLocationData[playerId].postal.code or "Unkown"
end)

exports('getCity', function(playerId)
    return playerLocationData[playerId] and playerLocationData[playerId].city.city or "Unkown"
end)

exports('getCounty', function(playerId)
    return playerLocationData[playerId] and playerLocationData[playerId].county.county or "Unkown"
end)

AddEventHandler('playerDropped', function()
    playerLocationData[source] = nil
end)

