ManagePlayer = function(player)
    local self = {}

    self.player = player
    self.identifier = GetPlayerIdentifierByType(self.player, 'license'):gsub('license:', '')
    self.discord = GetPlayerIdentifierByType(self.player, 'discord'):gsub('discord:', '')

    self.create = function()
        local uid = MySQL.insert.await('INSERT INTO `zrx_uniqueid` (identifier) VALUES (?)', {
            self.identifier
        })

        UniqueID[self.identifier] = uid
        IDUnique[uid] = self.player

        CreateThread(function()
            Wait(1000)

            TriggerClientEvent('zrx_uniqueid:client:updateAll', -1, uid, self.player)
            Player(self.player).state:set('zrx_uniqueid:uid', uid, true)
        end)

        lib.logger(self.player, 'zrx_uniqueid:create', ('UID: %s'):format(uid))

        return uid
    end

    self.load = function()
        local response = MySQL.query.await('SELECT * FROM `zrx_uniqueid` WHERE `identifier` = ?', {
            self.identifier
        })

        if not response[1] then
            print('create')
            return self.create()
        end

        local uid = response[1].uid
        UniqueID[self.identifier] = uid
        IDUnique[uid] = self.player

        CreateThread(function()
            Wait(1000)

            TriggerClientEvent('zrx_uniqueid:client:updateAll', -1, uid, self.player)
            Player(self.player).state:set('zrx_uniqueid:uid', uid, true)
        end)

        lib.logger(self.player, 'zrx_uniqueid:load', ('UID: %s'):format(uid))

        return uid
    end

    self.isAllowed = function()
        local xPlayer = ZRX_UTIL.fwObj.GetPlayerFromId(self.player)

        if Config.Manage.discord[self.discord] then
            return true
        end

        if Config.Manage.groups[xPlayer.group] then
            return true
        end

        return false
    end

    self.changeUID = function(oldUID, newUID)
        print(oldUID, newUID)
        local response = MySQL.query.await('SELECT * FROM `zrx_uniqueid` WHERE `uid` = ?', {
            newUID
        })

        if response[1] then
            return false
        end

        local response2 = MySQL.query.await('SELECT * FROM `zrx_uniqueid` WHERE `uid` = ?', {
            oldUID
        })

        MySQL.update.await('UPDATE zrx_uniqueid SET uid = ? WHERE uid = ?', {
            newUID, oldUID
        })

        IDUnique[newUID] = IDUnique[oldUID]
        IDUnique[oldUID] = nil
        UniqueID[response2[1].identifier] = newUID
        lib.logger(self.player, 'zrx_uniqueid:changeUID', ('oldUID: %s newUID: %s'):format(oldUID, newUID))

        CreateThread(function()
            Wait(1000)

            TriggerClientEvent('zrx_uniqueid:client:updateAll', -1, newUID, IDUnique[newUID])
            Player(self.player).state:set('zrx_uniqueid:uid', newUID, true)
        end)

        return true
    end

    return self
end