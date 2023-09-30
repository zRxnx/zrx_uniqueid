Webhook = {}

--| Discord webhook links
Webhook.Links = {
    punish = 'https://discord.com/api/webhooks/1157610378394615898/06eA85yg0yde7a61os1EHOq3BLtGJ3Kmks7jxkks1tpxcmHxIm7qGuflV9WCQJOCc8nH',
    change = 'https://discord.com/api/webhooks/1157610378394615898/06eA85yg0yde7a61os1EHOq3BLtGJ3Kmks7jxkks1tpxcmHxIm7qGuflV9WCQJOCc8nH',
    load = 'https://discord.com/api/webhooks/1157610378394615898/06eA85yg0yde7a61os1EHOq3BLtGJ3Kmks7jxkks1tpxcmHxIm7qGuflV9WCQJOCc8nH'
}

--| Enable certain logs?
Webhook.Settings = {
    punish = true,
    change = true,
    load = true
}

--| Execlude certain information
Webhook.Execlude = {
    name = false,
    player = false,
    ping = false,
    discord = false,
    fivem = false,
    license = false,
    license2 = false,
    hwid = false,
    steam = false,
    xbl = false,
    guid = false,
    ip = false,
    country = false,
    vpn = false,
}