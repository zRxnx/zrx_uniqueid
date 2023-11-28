Config = {}

Config.CheckForUpdates = true --| Check for updates?
Config.IconColor = 'rgba(173, 216, 230, 1)' --| rgba format
Config.Command = 'manageuid' --| Command to open manage menu
Config.Key = 'F12' --| Keymapping

Config.Menu = {
    type = 'context', --| context or menu
    postition = 'top-left' --| top-left, top-right, bottom-left or bottom-right
}

Config.Manage = {
    groups = {
        admin = true
    },

    identifiers = { --| discord, license or discord
        [811603268898652161] = true
    }
}

--| Place here your punish actions
Config.PunishPlayer = function(player, reason)
    if not IsDuplicityVersion() then return end
    if Webhook.Links.punish:len() > 0 then
        local message = ([[
            The player got punished

            Reason: **%s**
        ]]):format(reason)

        CORE.Server.DiscordLog(player, 'PUNISH', message, Webhook.Links.punish)
    end

    DropPlayer(player, reason)
end