UniqueID, IDUnique = {}, {}

RegisterCommand(Config.Command, function()
    OpenMainMenu()
end, false)
RegisterKeyMapping(Config.Command, Strings.cmd_desc, 'keyboard', Config.Key)
TriggerEvent('chat:addSuggestion', ('/%s'):format(Config.Command), Strings.cmd_desc, {})

RegisterNetEvent('zrx_uniqueid:client:updateAll', function(uid, player)
    if player then
        UniqueID[player] = uid
        IDUnique[uid] = player
    else
        IDUnique[uid] = nil
    end
end)

GetPlayerUIDfromSID = function(player)
    return UniqueID[player] or player
end
exports('GetPlayerUIDfromSID', GetPlayerUIDfromSID)

GetPlayerSIDfromUID = function(uid)
    return IDUnique[uid]
end
exports('GetPlayerSIDfromUID', GetPlayerSIDfromUID)

CreateThread(function()
    local UID_DATA

    while true do
        Wait(30000)

        UID_DATA = lib.callback.await('zrx_uniqueid:server:getUidData', 500)

        for k, data in pairs(UID_DATA) do
            if data.online then
                UniqueID[data.id] = data.uid
                IDUnique[data.uid] = data.id
            end
        end
    end
end)