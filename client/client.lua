CORE = exports.zrx_utility:GetUtility()
UniqueID = 0
local NetworkIsPlayerActive = NetworkIsPlayerActive

CORE.Client.RegisterKeyMappingCommand(Config.Command, Strings.cmd_desc, Config.Key, function()
    OpenMainMenu()
end)

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