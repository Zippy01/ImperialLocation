local DATA_FOLDER = 'data'
local POSTAL_FILE = DATA_FOLDER .. '/postals.json'
local CITY_FILE = DATA_FOLDER .. '/cities.json'
local COUNTY_FILE = DATA_FOLDER .. '/counties.json'

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

RegisterNetEvent('requestNearestLocations')
AddEventHandler('requestNearestLocations', function(playerCoords)
    local src = source
    local nearestPostal = getNearestLocation(playerCoords, postals)
    local nearestCity = getNearestLocation(playerCoords, cities)
    local nearestCounty = getNearestLocation(playerCoords, counties)

    TriggerClientEvent('receiveNearestLocations', src, nearestPostal, nearestCity, nearestCounty)
end)

RegisterNetEvent('aNearestLocations')
AddEventHandler('aNearestLocations', function(playerCoords)
    local src = source
    local nearestPostal = getNearestLocation(playerCoords, postals)
    local nearestCity = getNearestLocation(playerCoords, cities)
    local nearestCounty = getNearestLocation(playerCoords, counties)

    TriggerClientEvent('rNearestLocations', src, nearestPostal, nearestCity, nearestCounty)
end)