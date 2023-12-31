CORE = exports.zrx_utility:GetUtility()
UniqueID = {}
local NetworkIsPlayerActive = NetworkIsPlayerActive

CORE.Client.RegisterKeyMappingCommand(Config.Command, Strings.cmd_desc, Config.Key, function()
    OpenMainMenu()
end)

RegisterNetEvent('zrx_uniqueid:client:getData', function(UID)
    local k, v = next(UID)

    UniqueID[k] = v
end)

CreateThread(function()
    lib.waitFor(function()
        return NetworkIsPlayerActive(cache.playerId)
    end, 'Timeout', 120000)

    TriggerServerEvent('zrx_uniqueid:server:updateData')
end)

exports('GetUID', function(player)
    return UniqueID?[player] or UniqueID?[cache.serverId]
end)