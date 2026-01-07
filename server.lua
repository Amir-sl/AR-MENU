local VorpCore = nil

-----------------------------------------------------------------------
-- ⚙️ CONFIGURATION
-----------------------------------------------------------------------
local DISCORD_WEBHOOK = "YOUR_WEBHOOK_HERE" 
local ID_FILE = "log_id.txt" 
local UPDATE_INTERVAL = 60000 -- 1 Minute

-----------------------------------------------------------------------
-- 💾 ID MANAGEMENT
-----------------------------------------------------------------------
local function GetSavedID()
    return LoadResourceFile(GetCurrentResourceName(), ID_FILE)
end

local function SaveID(id)
    SaveResourceFile(GetCurrentResourceName(), ID_FILE, tostring(id), -1)
end

-----------------------------------------------------------------------
-- 📡 DISCORD LIVE STATUS LOGIC
-----------------------------------------------------------------------
function UpdateDiscordStatus()
    if not VorpCore then return end

    -- Using pcall to prevent the entire thread from stopping if an error occurs
    pcall(function()
        local players = GetPlayers()
        local onlinePlayers = #players
        local playerListText = "" 
        local totalSheriffs, totalMedics = 0, 0
        local CURRENT_ID = GetSavedID()
        
        for _, playerId in ipairs(players) do
            local pUser = VorpCore.getUser(playerId)
            if pUser and pUser.getUsedCharacter then
                local char = pUser.getUsedCharacter
                if char then
                    local job = tonumber(char.job) and "citizen" or tostring(char.job or "citizen"):lower()
                    local jobIcon = "👤"
                    
                    if job == 'sheriff' or job == 'police' then 
                        jobIcon = "🤠"; totalSheriffs = totalSheriffs + 1
                    elseif job == 'medic' or job == 'doctor' or job == 'ems' then 
                        jobIcon = "🚑"; totalMedics = totalMedics + 1 
                    end
                    
                    local name = (char.firstname or "Unknown") .. " " .. (char.lastname or "")
                    playerListText = playerListText .. jobIcon .. " **" .. name .. "** | `ID: " .. playerId .. "`\n"
                end
            end
        end

        if playerListText == "" then playerListText = "❌ No citizens currently in the state" end

        local embed = {{
            ["title"] = "🌵 SERVER LIVE STATUS 🌵",
            ["color"] = 15105570,
            ["fields"] = {
                {["name"] = "👥 Population", ["value"] = "`" .. onlinePlayers .. " Online`", ["inline"] = true},
                {["name"] = "⭐ Law Enforcement", ["value"] = "`" .. totalSheriffs .. " Active`", ["inline"] = true},
                {["name"] = "🩺 Medical Staff", ["value"] = "`" .. totalMedics .. " Active`", ["inline"] = true},
                {["name"] = "📜 Active Citizens List", ["value"] = playerListText, ["inline"] = false},
            },
            ["footer"] = { ["text"] = "Last Sync: " .. os.date("%H:%M:%S") }
        }}

        local payload = json.encode({embeds = embed})
        local headers = { ['Content-Type'] = 'application/json' }

        if not CURRENT_ID or CURRENT_ID == "" then
            PerformHttpRequest(DISCORD_WEBHOOK .. "?wait=true", function(err, text, headers)
                if err == 200 or err == 201 then
                    local data = json.decode(text)
                    if data and data.id then SaveID(data.id) end
                end
            end, 'POST', payload, headers)
        else
            PerformHttpRequest(DISCORD_WEBHOOK .. "/messages/" .. CURRENT_ID, function(err, text, headers)
                if err == 404 then 
                    SaveID("") -- Reset if message deleted
                end
            end, 'PATCH', payload, headers)
        end
    end)
end

-----------------------------------------------------------------------
-- ⏳ INITIALIZATION THREAD (Safe Loop)
-----------------------------------------------------------------------
Citizen.CreateThread(function()
    -- Wait for VorpCore
    while not VorpCore do
        TriggerEvent("getCore", function(core) VorpCore = core end)
        Citizen.Wait(2000) 
    end
    
    print("^2[AR_Menu]^7 Core Linked. Service starting...")
    Citizen.Wait(10000) 

    while true do
        -- Wrapped in a separate thread to ensure one fail doesn't stop the loop
        Citizen.CreateThread(function()
            UpdateDiscordStatus()
        end)
        Citizen.Wait(UPDATE_INTERVAL)
    end
end)

-----------------------------------------------------------------------
-- 🎮 IN-GAME MENU EVENTS
-----------------------------------------------------------------------
RegisterServerEvent("AR_Menu:fetchData")
AddEventHandler("AR_Menu:fetchData", function()
    local _source = source
    if not VorpCore then return end

    local players = GetPlayers()
    local sheriffs, medics, justice, pinkerton = 0, 0, 0, 0
    local charName = "Unknown"
    
    local User = VorpCore.getUser(_source)
    if User and User.getUsedCharacter then 
        charName = (User.getUsedCharacter.firstname or "Unknown") .. " " .. (User.getUsedCharacter.lastname or "") 
    end

    for _, playerId in ipairs(players) do
        local pUser = VorpCore.getUser(playerId)
        if pUser and pUser.getUsedCharacter then
            local job = tostring(pUser.getUsedCharacter.job or "citizen"):lower()
            if job == 'sheriff' or job == 'police' then sheriffs = sheriffs + 1
            elseif job == 'medic' or job == 'doctor' or job == 'ems' then medics = medics + 1
            elseif job == 'justice' or job == 'judge' then justice = justice + 1
            elseif job == 'pinkerton' then pinkerton = pinkerton + 1 end
        end
    end
    
    TriggerClientEvent("AR_Menu:receiveData", _source, {
        online = #players, 
        sheriffs = sheriffs, 
        medics = medics, 
        justice = justice, 
        pinkerton = pinkerton, 
        time = os.date("%H:%M"), 
        id = _source, 
        fullname = charName
    })
end)

RegisterServerEvent("AR_Menu:requestPlayerList")
AddEventHandler("AR_Menu:requestPlayerList", function()
    local _source = source
    if not VorpCore then return end
    
    local players = {}
    for _, playerId in ipairs(GetPlayers()) do
        local User = VorpCore.getUser(playerId)
        if User and User.getUsedCharacter then
            table.insert(players, {
                id = playerId, 
                name = (User.getUsedCharacter.firstname or "Unknown") .. " " .. (User.getUsedCharacter.lastname or ""), 
                job = User.getUsedCharacter.job or "Citizen", 
                ping = GetPlayerPing(playerId)
            })
        end
    end
    TriggerClientEvent("AR_Menu:displayPlayerList", _source, players)
end)