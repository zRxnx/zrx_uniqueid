CORE = exports.zrx_utility:GetUtility()
UniqueID, IDUnique = {}, {}

CORE.Client.RegisterKeyMappingCommand(Config.Command, Strings.cmd_desc, Config.Key, function()
    OpenMainMenu()
end)

RegisterNetEvent('zrx_uniqueid:client:update', function(uid, player)
    if player then
        UniqueID[player] = uid
        IDUnique[uid] = player
    else
        IDUnique[uid] = nil
    end
end)

GetPlayerUIDfromSID = function(player)
    return UniqueID[player] or lib.callback.await('zrx_uniqueid:server:getPlayerUIDfromSID', 500, player)
end
exports('GetPlayerUIDfromSID', GetPlayerUIDfromSID)

GetPlayerSIDfromUID = function(player)
    return IDUnique[player] or lib.callback.await('zrx_uniqueid:server:getPlayerSIDfromUID', 500, player)
end
exports('GetPlayerSIDfromUID', GetPlayerSIDfromUID)