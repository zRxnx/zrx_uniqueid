---@diagnostic disable: undefined-global, redundant-value
Player = {
    Load = function(player)
        LOADED[player] = true
        local identifier = PLAYER_CACHE[player].license

        ::continue::
        local response = MySQL.query.await('SELECT `uid`, `name` FROM `zrx_uniqueid` WHERE `identifier` = ?', {
            identifier
        })

        if response[1]?.uid then
            UniqueID[player] = response[1].uid
            IDUnique[response[1].uid] = player
            UIDName[response[1].uid] = response[1].name or PLAYER_CACHE[player].name

            if Webhook.Links.load:len() > 0 then
                local message = ([[
                    The player loaded their UniqueID
    
                    UniqueID: **%s**
                ]]):format(UniqueID[player])

                CORE.Server.DiscordLog(player, 'LOAD', message, Webhook.Links.load)
            end

            TriggerClientEvent('zrx_uniqueid:client:update', -1, response[1].uid, player)

            return response[1].uid
        end

        MySQL.insert.await('INSERT INTO `zrx_uniqueid` (identifier, name) VALUES (?, ?)', {
            identifier, PLAYER_CACHE[player].name
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
    end,

    ChangeUID = function(player, oldUID, newUID)
        if not IsDuplicityVersion() and not Player.IsAllowed(player) then
            return Config.PunishPlayer(player, 'Tried to trigger "zrx_uniqueid:server:changeUniqueID"')
        end

        if Webhook.Links.change:len() > 0 then
            local message = ([[
                The player changed a UniqueID
    
                Old UniqueID: **%s**
                New UniqueID: **%s**
            ]]):format(oldUID, newUID)

            CORE.Server.DiscordLog(player, 'CHANGE', message, Webhook.Links.change)
        end

        local response = MySQL.query.await('SELECT `uid`, `name` FROM `zrx_uniqueid` WHERE `uid` = ?', {
            newUID
        })

        if response[1] then
            CORE.Bridge.notification(player, Strings.already_in_use, Strings.uniqueid, 'error')
            return false
        end

        MySQL.update.await('UPDATE zrx_uniqueid SET uid = ? WHERE uid = ?', {
            newUID, oldUID
        })

        CORE.Bridge.notification(player, Strings.success_changed, Strings.uniqueid, 'success')

        if IDUnique[oldUID] then
            Player.Load(IDUnique[oldUID])
            IDUnique[oldUID] = nil
        end

        CORE.Bridge.notification(IDUnique[newUID], Strings.success_changed_target, Strings.uniqueid, 'success')

        return true
    end
}