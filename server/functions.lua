local TriggerClientEvent = TriggerClientEvent

Player = {
    Load = function(player)
        LOADED[player] = true
        local identifier = PLAYER_CACHE[player].license

        ::continue::
        local response = MySQL.query.await('SELECT `uid` FROM `zrx_uniqueid` WHERE `identifier` = ?', {
            identifier
        })

        if response[1]?.uid then
            UniqueID[player] = response[1].uid
            IDUnique[response[1].uid] = player

            if Webhook.Links.load:len() > 0 then
                local message = ([[
                    The player loaded their UniqueID
    
                    UniqueID: **%s**
                ]]):format(UniqueID[player])

                CORE.Server.DiscordLog(player, 'LOAD', message, Webhook.Links.load)
            end

            TriggerClientEvent('zrx_uniqueid:client:getData', -1, { player = response[1].uid })
            return response[1].uid
        end

        MySQL.insert.await('INSERT INTO `zrx_uniqueid` (identifier) VALUES (?)', {
            identifier
        })

        goto continue
    end,

    IsAllowed = function(player)
        local xPlayer = CORE.Bridge.getPlayerObject(player)

        if Config.Manage.groups[xPlayer.group] then
            return true
        end

        if Config.Manage.identifiers[PLAYER_CACHE[player].discord] or Config.Manage.identifiers[PLAYER_CACHE[player].license] or Config.Manage.identifiers[PLAYER_CACHE[player].fivem] then
            return true
        end

        return false
    end
}