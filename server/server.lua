---@diagnostic disable: cast-local-type, need-check-nil
UniqueID, IDUnique = {}, {}

CreateThread(function()
    lib.versionCheck('zrxnx/zrx_uniqueid')

    MySQL.Sync.execute([[
        CREATE Table IF NOT EXISTS `zrx_uniqueid` (
            `identifier` varchar(50) DEFAULT NULL,
            `uid` int(100) NOT NULL AUTO_INCREMENT,
            PRIMARY KEY (`uid`)
        ) ENGINE=InnoDB;
    ]])

    Wait(1000)

    for player, state in pairs(ZRX_UTIL.getPlayers()) do
        ManagePlayer(player).load()
    end
end)

RegisterNetEvent('esx:playerLoaded', function(player)
    ManagePlayer(player).load()
end)

AddEventHandler('playerDropped', function()
    local license = GetPlayerIdentifierByType(source, 'license'):gsub('license:', '')

    if UniqueID[license] then
        IDUnique[UniqueID[license]] = nil

        TriggerClientEvent('zrx_uniqueid:client:update', -1, UniqueID[license])
    end
end)

AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    ManagePlayer(source).load()
end)

lib.callback.register('zrx_uniqueid:server:isPlayerAllowed', function(player)
    print('zrx_uniqueid:server:isPlayerAllowed')
    return ManagePlayer(player).isAllowed()
end)

lib.callback.register('zrx_uniqueid:server:getPlayerUIDfromSID', function(player, id)
    print('zrx_uniqueid:server:getPlayerUIDfromSID')
    return ManagePlayer(id).load()
end)

lib.callback.register('zrx_uniqueid:server:getPlayerSIDfromUID', function(player, uid)
    print('zrx_uniqueid:server:getPlayerSIDfromUID')
    return IDUnique[uid]
end)

lib.callback.register('zrx_uniqueid:server:getUidData', function(player)
    local DATA = {}
    local response = MySQL.query.await('SELECT * FROM `zrx_uniqueid`')

    for i, data in pairs(response) do
        DATA[#DATA + 1] = {
            uid = data.uid,
            online = not not IDUnique[data.uid],
            id = IDUnique[data.uid] or 0,
        }
    end

    return DATA
end)

lib.callback.register('zrx_uniqueid:server:checkUniqueID', function(player, uid)
    if not ManagePlayer(player).isAllowed() then
        return
    end

    print(player, uid)

    local response = MySQL.query.await('SELECT `identifier` FROM `zrx_uniqueid` WHERE `uid` = ?', {
        uid
    })

    print(json.encode(response, { indent = true }))
 
    if response[1]?.identifier then
        return true
    else
        return false
    end
end)

RegisterNetEvent('zrx_uniqueid:server:changeUniqueID', function(oldUID, newUID)
    local player = source

    if not ManagePlayer(player).isAllowed() then
        return
    end

    ManagePlayer(player).changeUID(oldUID, newUID)
end)

exports('GetPlayerUIDfromSID', function(player)
    return Player(player).state['zrx_uniqueid:uid']
end)

exports('GetPlayerSIDfromUID', function(uid)
    return IDUnique[uid]
end)

exports('ChangePlayerUID', function(player, oldUID, newUID)
    return ManagePlayer(player).changeUID(oldUID, newUID)
end)