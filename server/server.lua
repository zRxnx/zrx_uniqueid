ESX, PLAYER_CACHE, FETCHED, COOLDOWN, LOC_DATA, LOADED = Config.EsxImport(), {}, {}, {}, {}, {}
UniqueID, IDUnique = {}, {}
local GetPlayers = GetPlayers
local GetPlayerName = GetPlayerName

CreateThread(function()
    MySQL.Sync.execute([[
        CREATE Table IF NOT EXISTS `zrx_uniqueid` (
            `identifier` varchar(255) DEFAULT NULL,
            `uid` int(11) NOT NULL AUTO_INCREMENT,
            PRIMARY KEY (`uid`)
        ) ENGINE=InnoDB;
    ]])

    for i, data in pairs(GetPlayers()) do
        data = tonumber(data)
        PLAYER_CACHE[data] = GetPlayerData(data)

        Player.Load(data)
    end
end)

AddEventHandler('playerDropped', function()
    if UniqueID[source] then
        IDUnique[UniqueID[source]] = nil
    end
end)

lib.callback.register('zrx_uniqueid:server:getData', function(source)
    if LOADED[source] then
        return Config.PunishPlayer(source, 'Tried to trigger "zrx_uniqueid:server:getData"')
    end

    LOADED[source] = true
    PLAYER_CACHE[source] = GetPlayerData(source)

    return Player.Load(source)
end)

lib.callback.register('zrx_uniqueid:server:isPlayerAllowed', function(source)
    return Player.IsAllowed(source)
end)

lib.callback.register('zrx_uniqueid:server:getUidData', function(source)
    if not Player.IsAllowed(source) then
        return Config.PunishPlayer(source, 'Tried to trigger "zrx_uniqueid:server:getUidData"')
    end

    if not Player.IsAllowed(source) then
        return {}
    end

    local DATA = {}
    local response = MySQL.query.await('SELECT * FROM `zrx_uniqueid`')

    for i, data in pairs(response) do
        DATA[#DATA + 1] = {
            uid = data.uid,
            online = not not IDUnique[data.uid],
            id = IDUnique[data.uid] or 0,
            name = GetPlayerName(IDUnique[data.uid]) or 'INVALID'
        }
    end

    return DATA
end)

lib.callback.register('zrx_uniqueid:server:checkUniqueID', function(source, uid)
    if not Player.IsAllowed(source) then
        return Config.PunishPlayer(source, 'Tried to trigger "zrx_uniqueid:server:checkUniqueID"')
    end

    local response = MySQL.query.await('SELECT `identifier` FROM `zrx_uniqueid` WHERE `uid` = ?', {
        uid
    })

    if response[1]?.uid then
        return false
    end

    return true
end)

RegisterNetEvent('zrx_uniqueid:server:changeUniqueID', function(oldUID, newUID)
    if not Player.IsAllowed(source) then
        return Config.PunishPlayer(source, 'Tried to trigger "zrx_uniqueid:server:changeUniqueID"')
    end

    if Webhook.Settings.change then
        DiscordLog(source, 'CHANGE', ('Player %s (%s) change the UID from %s to %s'):format(GetPlayerName(source), source, oldUID, newUID), 'change')
    end

    MySQL.update.await('UPDATE zrx_uniqueid SET uid = ? WHERE uid = ?', {
        newUID, oldUID
    })

    if IDUnique[oldUID] then
        Player.Load(IDUnique[oldUID])
        IDUnique[oldUID] = nil
    end
end)

exports('GetUID', function(player)
    return UniqueID[player]
end)

exports('GetID', function(uid)
    return IDUnique[uid]
end)

exports('ChangeUID', function(oldUID, newUID)
    MySQL.update.await('UPDATE zrx_uniqueid SET uid = ? WHERE uid = ?', {
        newUID, oldUID
    })

    if IDUnique[oldUID] then
        Player.Load(IDUnique[oldUID])
        IDUnique[oldUID] = nil
    end
end)

exports('hasCooldown', function(player)
    return not not COOLDOWN[PLAYER_CACHE[player].identifier]
end)