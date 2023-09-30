local TriggerServerEvent = TriggerServerEvent

OpenMainMenu = function()
    local MENU = {}
    local isPlayerAllowed = lib.callback.await('zrx_uniqueid:server:isPlayerAllowed', 500)
    local UID_DATA = lib.callback.await('zrx_uniqueid:server:getUidData', 500)

    if not isPlayerAllowed then
        return Config.Notification(nil, Strings.no_perms)
    end

    for i, data in pairs(UID_DATA) do
        MENU[#MENU + 1] = {
            title = (Strings.view_title):format(data),
            description = Strings.view_desc,
            arrow = true,
            icon = 'fa-solid fa-user',
            iconColor = Config.IconColor,
            args = {
                uid = data
            },
            onSelect = function(args)
                OpenManageMenu(args.uid)
            end
        }
    end

    lib.registerContext({
        id = 'zrx_uniqueid:menu:main',
        title = Strings.menu_main,
        options = MENU,
    })

    lib.showContext('zrx_uniqueid:menu:main')
end

OpenManageMenu = function(uid)
    local MENU = {}
    local isPlayerAllowed = lib.callback.await('zrx_uniqueid:server:isPlayerAllowed', 500)

    if not isPlayerAllowed then
        return Config.Notification(nil, Strings.no_perms)
    end

    MENU[#MENU + 1] = {
        title = Strings.manage_title,
        description = Strings.manage_desc,
        arrow = true,
        icon = 'fa-solid fa-user',
        iconColor = Config.IconColor,
        onSelect = function()
            local input = lib.inputDialog(Strings.alert_title, {
                {
                    type = 'number',
                    label = (Strings.alert_label):format(uid),
                    description = Strings.alert_desc,
                    required = true,
                    min = 1,
                    max = 999999999
                },
            })

            if not input then
                Config.Notification(nil, Strings.not_fill)
                return OpenManageMenu(uid)
            end

            local response = lib.callback.await('zrx_uniqueid:server:checkUniqueID', 500)

            if not response then
                Config.Notification(nil, Strings.already_in_use)
                return OpenManageMenu(uid)
            end

            TriggerServerEvent('zrx_uniqueid:server:changeUniqueID', uid, input)
        end
    }

    lib.registerContext({
        id = 'zrx_uniqueid:manage:main',
        title = Strings.menu_manage,
        menu = 'zrx_uniqueid:menu:main',
        options = MENU,
    })

    lib.showContext('zrx_uniqueid:manage:main')
end