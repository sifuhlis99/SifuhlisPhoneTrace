local tracking = false
local blip = nil  -- Store the blip to remove it properly


-- Event triggered by the server to request the current player's location
RegisterNetEvent('phone:requestPlayerLocation', function(trackingPlayerId)
    -- Get the current player's coordinates (target player)
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)

    -- Debug: Print the target player's coordinates
    print(string.format("Sending target player location: x=%f, y=%f, z=%f", coords.x, coords.y, coords.z))

    -- Send the coordinates back to the server
    TriggerServerEvent('phone:sendPlayerLocation', trackingPlayerId, coords)
end)

-- Event triggered by the server to update the tracked player's location on the map (on the tracking player's client)
RegisterNetEvent('phone:updatePlayerLocation', function(coords)
    -- Debug: Check if tracking is active
    print("Checking if tracking is active: ", tracking)

    if tracking then
        -- Debug: Print received coordinates on tracking player's side
        print(string.format("Received target player location: x=%f, y=%f, z=%f", coords.x, coords.y, coords.z))

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
    print("Tracking event triggered, setting tracking to true")
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
