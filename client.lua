local isMenuOpen = false

function ToggleMenu()
    isMenuOpen = not isMenuOpen
    SetNuiFocus(isMenuOpen, isMenuOpen)
    if isMenuOpen then
        TriggerServerEvent("AR_Menu:fetchData")
        SendNUIMessage({action = "openMenu"})
    else
        SendNUIMessage({action = "closeMenu"})
    end
end

RegisterCommand("ARMENU", function() ToggleMenu() end, false)
RegisterCommand("armenu", function() ToggleMenu() end, false)

-- Receiving information from the server and sending it to the panel
RegisterNetEvent("AR_Menu:receiveData")
AddEventHandler("AR_Menu:receiveData", function(data)
    SendNUIMessage({
        action = "updateData",
        online = data.online,
        sheriffs = data.sheriffs,
        medics = data.medics,
        justice = data.justice,
        pinkerton = data.pinkerton,
        time = data.time,
        id = data.id,
        fullname = data.fullname
    })
end)

--Get the list of players
RegisterNetEvent("AR_Menu:displayPlayerList")
AddEventHandler("AR_Menu:displayPlayerList", function(players)
    SendNUIMessage({action = "displayPlayers", players = players})
end)

RegisterNUICallback("fetchPlayers", function(data, cb)
    TriggerServerEvent("AR_Menu:requestPlayerList")
    cb('ok')
end)

RegisterNUICallback("exitMenu", function(data, cb)
    ToggleMenu()
    cb('ok')
end)