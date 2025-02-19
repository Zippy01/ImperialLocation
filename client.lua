local currentPostal, currentCity, currentCounty

local function updateLocationData()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    TriggerServerEvent('aNearestLocations', {x = playerCoords.x, y = playerCoords.y})
end

Citizen.CreateThread(function()
    while true do
        updateLocationData()
        Citizen.Wait(500) 
    end
end)

RegisterCommand("getlocation", function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    TriggerServerEvent('requestNearestLocations', {x = playerCoords.x, y = playerCoords.y})
end, false)

RegisterNetEvent('receiveNearestLocations')
AddEventHandler('receiveNearestLocations', function(nearestPostal, nearestCity, nearestCounty)
    local postalText = nearestPostal and nearestPostal.code or "None"
    local cityText = nearestCity and nearestCity.city or "None"
    local countyText = nearestCounty and nearestCounty.county or "None"
    TriggerEvent('chat:addMessage', {
        color = {255, 0, 0},
        multiline = true,
        args = {"Me", "Nearest Postal: " .. postalText .. ", City: " .. cityText .. ", County: " .. countyText}
    })
end)

RegisterNetEvent('rNearestLocations')
AddEventHandler('rNearestLocations', function(nearestPostal, nearestCity, nearestCounty)
    currentPostal = nearestPostal and nearestPostal.code or "None"
    currentCity = nearestCity and nearestCity.city or "None"
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