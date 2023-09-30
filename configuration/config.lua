Config = {}

Config.CheckForUpdates = true --| Check for updates?
Config.IconColor = 'rgba(173, 216, 230, 1)' --| rgba format
Config.Command = 'manageuid' --| Command to open manage menu
Config.Key = '' --| Keymapping

Config.Manage = {
    groups = {
        admin = true
    },

    identifiers = { --| discord, license or discord
        [811603268898652161] = true
    }
}

--| Place here your notification
Config.Notification = function(player, msg)
    if IsDuplicityVersion() then
        TriggerClientEvent('esx:showNotification', player, msg, 'info')
    else
        ESX.ShowNotification(msg)
    end
end

--| Place here your punish actions
Config.PunishPlayer = function(player, reason)
    if not IsDuplicityVersion() then return end
    if Webhook.Settings.punish then
        DiscordLog(player, 'PUNISH', reason, 'punish')
    end

    DropPlayer(player, reason)
end

--| Place here your esx import
--| Change it if you know what you are doing
Config.EsxImport = function()
	if IsDuplicityVersion() then
		return exports.es_extended:getSharedObject()
	else
		return exports.es_extended:getSharedObject()
	end
end