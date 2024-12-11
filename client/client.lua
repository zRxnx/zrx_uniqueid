CORE = exports.zrx_utility:GetUtility()

CORE.Client.RegisterKeyMappingCommand(Config.Command, Strings.cmd_desc, Config.Key, function()
    OpenMainMenu()
end)

GetPlayerUIDfromSID = function(player)
    return lib.callback.await('zrx_uniqueid:server:getPlayerUIDfromSID', 500, player)
end
exports('GetPlayerUIDfromSID', GetPlayerUIDfromSID)

GetPlayerSIDfromUID = function(player)
    return lib.callback.await('zrx_uniqueid:server:getPlayerSIDfromUID', 500, player)
end
exports('GetPlayerSIDfromUID', GetPlayerSIDfromUID)