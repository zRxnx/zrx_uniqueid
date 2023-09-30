ESX, UniqueID = Config.EsxImport(), 0
local NetworkIsPlayerActive = NetworkIsPlayerActive

RegisterCommand(Config.Command, function() OpenMainMenu() end)
RegisterKeyMapping(Config.Command, Strings.cmd_desc, 'keyboard', Config.Key)
TriggerEvent('chat:addSuggestion', ('/%s'):format(Config.Command), Strings.cmd_desc, {})


RegisterNetEvent('zrx_uniqueid:client:getData', function(UID)
    UniqueID = UID
end)

CreateThread(function()
    local success = lib.waitFor(function()
        return NetworkIsPlayerActive(cache.playerId)
    end, 'Timeout', 120000)

    if success then
        UniqueID = lib.callback.await('zrx_uniqueid:server:getData', 500)
    end
end)

exports('GetUID', function()
    return UniqueID
end)