OpenMainMenu = function()
    local MENU = {}
    local isPlayerAllowed = lib.callback.await('zrx_uniqueid:server:isPlayerAllowed', 500)
    local UID_DATA = lib.callback.await('zrx_uniqueid:server:getUidData', 500)
    local index = 0

    if not isPlayerAllowed then
        return CORE.Bridge.notification(Strings.no_perms)
    end

    MENU[#MENU + 1] = {
        title = Strings.search_title,
        description = Strings.search_desc,
        arrow = true,
        icon = 'fa-solid fa-magnifying-glass',
        iconColor = Config.IconColor,
        onSelect = function(args)
            local input = lib.inputDialog(Strings.search_title, {
                {
                    type = 'number',
                    label = Strings.search_desc,
                    description = Strings.search_desc2,
                    required = true,
                    default = 1,
                    min = 1,
                },
            })

            if not input then
                CORE.Bridge.notification(Strings.not_fill)
                return OpenMainMenu()
            end

            local response = lib.callback.await('zrx_uniqueid:server:checkUniqueID', 500)

            if not response then
                CORE.Bridge.notification(Strings.search_no)
                return OpenMainMenu()
            end

            for i, data in pairs(UID_DATA) do
                if data.uid == input[1] then
                    index = i
                    break
                end
            end

            if index == 0 then
                CORE.Bridge.notification(Strings.search_no)
                return OpenMainMenu()
            end

            OpenManageMenu({
                uid = input[1],
                online = UID_DATA[index].online,
                id = UID_DATA[index].id,
                name = UID_DATA[index].name
            })
        end
    }

    for i, data in pairs(UID_DATA) do
        MENU[#MENU + 1] = {
            title = (Strings.view_title):format(data.uid),
            description = Strings.view_desc,
            arrow = true,
            icon = 'fa-solid fa-user',
            iconColor = data.online and 'rgba(0, 255, 0, 1)' or 'rgba(255, 0, 0, 1)',
            metadata = {
                { label = Strings.metadata_name, value = data.name },
                { label = Strings.metadata_sid, value = data.id },
                { label = Strings.metadata_online, value = data.online and Strings.metadata_online_yes or Strings.metadata_online_no },
            },
            args = {
                uid = data.uid,
                online = data.online,
                id = data.id,
                name = data.name
            },
            onSelect = function(args)
                OpenManageMenu(args)
            end
        }
    end

    CORE.Client.CreateMenu({
        id = 'zrx_uniqueid:menu:main',
        title = Strings.menu_main,
    }, MENU, Config.Menu.type ~= 'menu', Config.Menu.postition)
end

OpenManageMenu = function(data)
    local MENU = {}
    local isPlayerAllowed = lib.callback.await('zrx_uniqueid:server:isPlayerAllowed', 500)

    if not isPlayerAllowed then
        return CORE.Bridge.notification(Strings.no_perms)
    end

    MENU[#MENU + 1] = {
        title = Strings.manage_data_title,
        description = (Strings.manage_data_desc):format(data.name, data.id, data.uid),
        arrow = false,
        icon = 'fa-solid fa-user',
        iconColor = data.online and 'rgba(0, 255, 0, 1)' or 'rgba(255, 0, 0, 1)',
        readOnly = true,
    }

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
                    label = (Strings.alert_label):format(data.uid),
                    description = Strings.alert_desc,
                    required = true,
                    default = 1,
                    min = 1,
                },
            })

            if not input then
                CORE.Bridge.notification(Strings.not_fill)
                return OpenManageMenu(data)
            end

            local response = lib.callback.await('zrx_uniqueid:server:checkUniqueID', 500)

            if not response then
                CORE.Bridge.notification(Strings.already_in_use)
                return OpenManageMenu(data)
            end

            TriggerServerEvent('zrx_uniqueid:server:changeUniqueID', data.uid, input[1])
        end
    }

    CORE.Client.CreateMenu({
        id = 'zrx_uniqueid:manage:main',
        title = Strings.menu_manage,
        menu = 'zrx_uniqueid:menu:main',
    }, MENU, Config.Menu.type ~= 'menu', Config.Menu.postition)
end