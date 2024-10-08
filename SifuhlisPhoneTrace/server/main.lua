local QBCore = exports['qb-core']:GetCoreObject()
local trackedPhones = {}

-- Function to get player by phone number from their inventory
function GetPlayerByPhoneNumber(phoneNumber)
    local players = QBCore.Functions.GetPlayers()  -- Get all active players
    for _, playerId in ipairs(players) do
        local Player = QBCore.Functions.GetPlayer(playerId)
        if Player then
            -- Check the player's inventory for the phone item
            local inventory = Player.PlayerData.items
            if inventory then
                for _, item in pairs(inventory) do
                    if item.name == "phone" and item.info and item.info.phoneNumber == phoneNumber then
                        return Player
                    end
                end
            end
        end
    end
    return nil  -- Return nil if no player found with the given phone number
end


-- Function to check if the player has the "taptracekit" item
function HasTapTraceKit(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        local inventory = Player.PlayerData.items
        if inventory then
            for _, item in pairs(inventory) do
                if item.name == "taptracekit" then
                    return true
                end
            end
        end
    end
    return false
end


-- Function to notify target player with a 1-100 chance
function NotifyTargetPlayer(targetPlayerId)
    local chance = math.random(1, 100)  -- Generate a random number between 1 and 100

    -- 40% chance to notify the target player
    if chance <= 40 then  -- Adjust the chance threshold here
        TriggerClientEvent('QBCore:Notify', targetPlayerId, "You are being tracked!", "error")
        print("Notified target player with ID: " .. targetPlayerId)
    else
        print("Target player was not notified of tracking.")
    end
end

-- Tracking command
QBCore.Commands.Add("track", "Track a phone number (Police Only)", {{name="number", help="Phone number to track"}}, false, function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then
        TriggerClientEvent('QBCore:Notify', source, "Player not found.", "error")
        return
    end

    if Player.PlayerData.job.name ~= 'police' then
        TriggerClientEvent('QBCore:Notify', source, "You do not have permission to track phone numbers.", "error")
        return
    end
	
	-- Check if the player has the tap trace kit
    if not HasTapTraceKit(source) then
        TriggerClientEvent('QBCore:Notify', source, "You need a Tap Trace Kit to track phones.", "error")
        return
    end

    local phoneNumber = args[1]
    if phoneNumber then
        local TargetPlayer = GetPlayerByPhoneNumber(phoneNumber)
        if TargetPlayer then
            local targetPlayerId = TargetPlayer.PlayerData.source
            trackedPhones[source] = targetPlayerId

            -- Notify tracking player
            TriggerClientEvent('QBCore:Notify', source, "Tracking player with ID: " .. targetPlayerId, "success")
			
			-- Notify the target player that they are being tracked
            NotifyTargetPlayer(targetPlayerId)
			
			
            -- Start tracking event on the tracking player's client
            TriggerClientEvent('phone:trackPlayer', source)

            -- Request location from target player periodically
            Citizen.CreateThread(function()
                while trackedPhones[source] == targetPlayerId do
                    print("Requesting location from target player ID: " .. targetPlayerId)
                    TriggerClientEvent('phone:requestPlayerLocation', targetPlayerId, source)  -- Request location from target player
                    Citizen.Wait(15000)  -- Update every 30 seconds
                end
            end)
        else
            TriggerClientEvent('QBCore:Notify', source, "Phone number not found or player offline.", "error")
        end
    else
        TriggerClientEvent('QBCore:Notify', source, "You need to provide a phone number.", "error")
    end
end)


QBCore.Commands.Add("stoptrack", "Stop tracking the phone number", {}, false, function(source)
    if trackedPhones[source] then
        trackedPhones[source] = nil
        TriggerClientEvent('phone:stopTracking', source)
        TriggerClientEvent('QBCore:Notify', source, "Stopped tracking.", "success")
    else
        TriggerClientEvent('QBCore:Notify', source, "You are not tracking anyone.", "error")
    end
end)

-- Event to handle location relay from the target to the tracking player
RegisterNetEvent('phone:sendPlayerLocation', function(trackingPlayerId, coords)
    print("Relaying target player's coordinates to tracking player ID: " .. trackingPlayerId)
    TriggerClientEvent('phone:updatePlayerLocation', trackingPlayerId, coords)
end)

