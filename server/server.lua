---@diagnostic disable: cast-local-type, need-check-nil
CORE = exports.zrx_utility:GetUtility()
PLAYER_CACHE, FETCHED, COOLDOWN, LOC_DATA, LOADED = {}, {}, {}, {}, {}
UniqueID, IDUnique = {}, {}
local GetPlayers = GetPlayers
local GetPlayerName = GetPlayerName

CreateThread(function()
    if Config.CheckForUpdates then
        CORE.Server.CheckVersion('zrx_uniqueid')
    end

    MySQL.Sync.execute([[
        CREATE Table IF NOT EXISTS `zrx_uniqueid` (
            `identifier` varchar(255) DEFAULT NULL,
            `uid` int(11) NOT NULL AUTO_INCREMENT,
            PRIMARY KEY (`uid`)
        ) ENGINE=InnoDB;
    ]])

    for i, player in pairs(GetPlayers()) do
        player = tonumber(player)
        PLAYER_CACHE[player] = CORE.Server.GetPlayerCache(player)

        if not LOADED[player] then
            Player.Load(player)
        end
    end
end)

AddEventHandler('playerDropped', function()
    if UniqueID[source] then
        IDUnique[UniqueID[source]] = nil
    end
end)

RegisterNetEvent('zrx_uniqueid:server:updateData', function()
    local player = source
    if LOADED[player] then return end
    PLAYER_CACHE[player] = CORE.Server.GetPlayerCache(player)

    Player.Load(player)
end)

lib.callback.register('zrx_uniqueid:server:isPlayerAllowed', function(player)
    return Player.IsAllowed(player)
end)

lib.callback.register('zrx_uniqueid:server:getUidData', function(player)
    if not Player.IsAllowed(player) then
        return Config.PunishPlayer(player, 'Tried to trigger "zrx_uniqueid:server:getUidData"')
    end

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
            name = GetPlayerName(IDUnique[data.uid]) or 'INVALID'
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
    if not Player.IsAllowed(source) then
        return Config.PunishPlayer(source, 'Tried to trigger "zrx_uniqueid:server:changeUniqueID"')
    end

    if Webhook.Links.change:len() > 0 then
        local message = ([[
            The player changed a UniqueID

            Old UniqueID: **%s**
            New UniqueID: **%s**
        ]]):format(oldUID, newUID)

        CORE.Server.DiscordLog(source, 'CHANGE', message, Webhook.Links.change)
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