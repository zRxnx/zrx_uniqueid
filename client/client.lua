CORE = exports.zrx_utility:GetUtility()
UniqueID = {}

CORE.Client.RegisterKeyMappingCommand(Config.Command, Strings.cmd_desc, Config.Key, function()
    OpenMainMenu()
end)

RegisterNetEvent('zrx_uniqueid:client:getData', function(player, uid)
    UniqueID[player] = uid
end)

exports('GetUID', function(player)
    return UniqueID?[player] or UniqueID?[cache.serverId]
end)