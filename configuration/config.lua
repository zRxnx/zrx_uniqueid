Config = {}

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

    discord = { --| discord, license or discord
        [811603268898652161] = true
    }
}

Config.Notify = function(player, msg, title, type, color, time)
    if IsDuplicityVersion() then
        TriggerClientEvent('ox_lib:notify', player, {
            title = title,
            description = msg,
            type = type,
            duration = time,
            style = {
                color = color
            }
        })
    else
        lib.notify({
            title = title,
            description = msg,
            type = type,
            duration = time,
            style = {
                color = color
            }
        })
    end
end