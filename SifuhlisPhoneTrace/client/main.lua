local tracking = false
local blip = nil  -- Store the blip to remove it properly


-- Event triggered by the server to request the current player's location
RegisterNetEvent('phone:requestPlayerLocation', function(trackingPlayerId)
    -- Get the current player's coordinates (target player)
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)


    -- Send the coordinates back to the server
    TriggerServerEvent('phone:sendPlayerLocation', trackingPlayerId, coords)
end)

-- Play sound when the player is being tracked
RegisterNetEvent('phone:playTrackingSound')
AddEventHandler('phone:playTrackingSound', function()
    -- Play a sound here (you can customize the sound as needed)
    PlaySoundFrontend(-1, "TIMER_STOP", "HUD_MINI_GAME_SOUNDSET", true)  -- random gta noises, too lazy to write a html document to handle custom sounds.
end)

-- Event triggered by the server to update the tracked player's location on the map (on the tracking player's client)
RegisterNetEvent('phone:updatePlayerLocation', function(coords)

    if tracking then

        -- Remove old blip if it exists
        if blip then
            RemoveBlip(blip)
        end

        -- Create a new blip on the map at the target player's location
        blip = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipSprite(blip, 161)  -- Set a relevant blip icon (you can customize this)
        SetBlipScale(blip, 1.0)   -- Blip size
        SetBlipColour(blip, 1)    -- Blip color (red for tracking)

        -- Set the blip name
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Tracked Player")
        EndTextCommandSetBlipName(blip)
    else
        print("Tracking is not active on this player.")
    end
end)

-- Event triggered by the server to start tracking a player
RegisterNetEvent('phone:trackPlayer', function()
    tracking = true  -- Set tracking to true when this event is triggered
    TriggerEvent('QBCore:Notify', "Started tracking the target.", "success")
end)

-- Stop tracking on command from the server
RegisterNetEvent('phone:stopTracking', function()
    if blip then
        RemoveBlip(blip)
        blip = nil
    end
    tracking = false
    print("Tracking stopped and blip removed.")
    TriggerEvent('QBCore:Notify', "Stopped tracking.", "success")
end)

-- Command for manually stopping the tracking (for testing purposes)
RegisterCommand("stopTracking", function()
    TriggerEvent('phone:stopTracking')
end, false)
