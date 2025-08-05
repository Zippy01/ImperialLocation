local currentPostal, currentCity, currentCounty

local function updateLocationData()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    TriggerServerEvent('ImperialLocation:updateNearest', {x = playerCoords.x, y = playerCoords.y})
end

Citizen.CreateThread(function()
    while true do
        updateLocationData()
        Citizen.Wait(Config.Frequency)
    end
end)

RegisterCommand("getlocation", function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    TriggerServerEvent('ImperialLocation:updateNearest', {x = playerCoords.x, y = playerCoords.y})
end, false)

RegisterNetEvent('ImperialLocation:PrintNearest')
AddEventHandler('ImperialLocation:PrintNearest', function(nearestPostal, nearestCity, nearestCounty)
    local postalText = nearestPostal and nearestPostal.code or "None"
    local cityText = nearestCity and nearestCity.city or "None"
    local countyText = nearestCounty and nearestCounty.county or "None"
    TriggerEvent('chat:addMessage', {
        color = {255, 0, 0},
        multiline = true,
        args = {"Me", "Nearest Postal: " .. postalText .. ", City: " .. cityText .. ", County: " .. countyText}
    })
end)

RegisterNetEvent('ImperialLocation:receiveNearest')
AddEventHandler('ImperialLocation:receiveNearest', function(nearestPostal, nearestCity, nearestCounty)
    currentPostal = nearestPostal and nearestPostal.code or "None"
    if Config.UseCustomCities then
        currentCity = nearestCity and nearestCity.city or "None"
    else
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        currentCity = Zones[GetNameOfZone(playerCoords.x, playerCoords.y, playerCoords.z)] or "None"
    end
    currentCounty = nearestCounty and nearestCounty.county or "None"
end)

exports('getPostal', function()
    return currentPostal
end)

exports('getCity', function()
    return currentCity
end)

exports('getCounty', function()
    return currentCounty
end)