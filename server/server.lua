---@diagnostic disable: cast-local-type, need-check-nil
CORE = exports.zrx_utility:GetUtility()
PLAYER_CACHE, FETCHED, COOLDOWN, LOC_DATA, LOADED = {}, {}, {}, {}, {}
UniqueID, IDUnique, UIDName = {}, {}, {}

CreateThread(function()
    if Config.CheckForUpdates then
        CORE.Server.CheckVersion('zrx_uniqueid')
    end

    MySQL.Sync.execute([[
        CREATE Table IF NOT EXISTS `zrx_uniqueid` (
            `identifier` varchar(255) DEFAULT NULL,
            `uid` int(11) NOT NULL AUTO_INCREMENT,
            `name` varchar(255) DEFAULT NULL,
            PRIMARY KEY (`uid`)
        ) ENGINE=InnoDB;
    ]])

    local response = MySQL.query.await('SELECT `uid`, `name` FROM `zrx_uniqueid`', {})

    for k, row in pairs(response) do
        UIDName[row.uid] = row.name
    end

    for i, player in pairs(GetPlayers()) do
        player = tonumber(player)
        PLAYER_CACHE[player] = CORE.Server.GetPlayerCache(player)

        if not LOADED[player] then
            Player.Load(player)
        end
    end
end)

RegisterNetEvent('zrx_utility:bridge:playerLoaded', function(player)
    if LOADED[player] then return end
    PLAYER_CACHE[player] = CORE.Server.GetPlayerCache(player)

    Player.Load(player)
end)

AddEventHandler('playerDropped', function()
    if UniqueID[source] then
        IDUnique[UniqueID[source]] = nil

        TriggerClientEvent('zrx_uniqueid:client:update', -1, UniqueID[source])
    end
end)

lib.callback.register('zrx_uniqueid:server:isPlayerAllowed', function(player)
    return Player.IsAllowed(player)
end)

lib.callback.register('zrx_uniqueid:server:getPlayerUIDfromSID', function(player, id)
    return UniqueID[id]
end)

lib.callback.register('zrx_uniqueid:server:getPlayerSIDfromUID', function(player, uid)
    return IDUnique[uid]
end)

lib.callback.register('zrx_uniqueid:server:getUidData', function(player)
    if not Player.IsAllowed(player) then
        return {}
    end

    local DATA = {}
    local response = MySQL.query.await('SELECT * FROM `zrx_uniqueid`')

    for i, data in pairs(response) do
        DATA[#DATA + 1] = {
            uid = data.uid,
            online = not not IDUnique[data.uid],
            id = IDUnique[data.uid] or 0,
            name = UIDName[data.uid] or 'NO DATA'
        }
    end

    return DATA
end)

lib.callback.register('zrx_uniqueid:server:checkUniqueID', function(player, uid)
    if not Player.IsAllowed(player) then
        return Config.PunishPlayer(player, 'Tried to trigger "zrx_uniqueid:server:checkUniqueID"')
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
    Player.ChangeUID(source, oldUID, newUID)
end)

exports('GetPlayerUIDfromSID', function(player)
    return UniqueID[player]
end)

exports('GetPlayerSIDfromUID', function(uid)
    return IDUnique[uid]
end)

exports('ChangePlayerUID', function(oldUID, newUID)
    return Player.ChangeUID(source, oldUID, newUID)
end)

exports('hasCooldown', function(player)
    return not not COOLDOWN[PLAYER_CACHE[player].identifier]
end)