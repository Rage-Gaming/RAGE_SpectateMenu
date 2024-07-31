ESX.RegisterServerCallback("RAGE_SpectateMenu:GetPlayers", function(source, cb)
    local onlinePlayers = {}
    local xPlayers = ESX.GetExtendedPlayers()
    for _, xPlayer in pairs(xPlayers) do
		table.insert(onlinePlayers, {
			id = xPlayer.source,
			name = xPlayer.getName(),
			group = xPlayer.getGroup(),
			job = xPlayer.job.name
		})
    end

    cb(onlinePlayers)
end)

ESX.RegisterServerCallback("RAGE_SpectateMenu:GetPlayerCoords", function(source, cb, serverId)
	local xPlayer = ESX.GetPlayerFromId(source)

	if not xPlayer then
		return cb(false)
	end

	local targetPed = GetPlayerPed(serverId)
	if targetPed <= 0 or not Config.AllowedGroups[xPlayer.getGroup()] then
		return cb(false)
	end
	cb(GetEntityCoords(targetPed))
end)

RegisterCommand(Config.SpectateMenuCommand, function(player)
	local xPlayer = ESX.GetPlayerFromId(player)
	if not Config.AllowedGroups[xPlayer.getGroup()] then
		return xPlayer.showNotification("You are not allowed to do this")
	end

	TriggerClientEvent("RAGE_SpectateMenu:OpenMenu", player)
end)

RegisterNetEvent('RAGE_SpectateMenu:KickPlayer')
AddEventHandler('RAGE_SpectateMenu:KickPlayer', function(player)
	DropPlayer(player, Config.KickMessage)
end)