local isSpectating = false
local lastCoords = nil

RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('GetPlayersData', function(data, cb)
	ESX.TriggerServerCallback("RAGE_SpectateMenu:GetPlayers", function(players)
		return cb({
			message = 'playersList',
			playersObject = players
		})
	end)
end)


RegisterNUICallback('SpectatePlayer', function(data, cb)
	if GetPlayerServerId(PlayerId()) == data.playerId then
		return cb({
			method = 'self',
			message = Config.SelfSpectateMessage
		})
	else
		startSpectate(data.playerId)
		return cb('ok')
	end
end)

RegisterNUICallback('KickPlayer', function(data, cb)
	if GetPlayerServerId(PlayerId()) == data.playerId then
		return cb({
			method = "self",
			message = Config.KickSelfMessage
		})
	else
		kickPlayer(data.playerId)
		Wait(1000)
		return cb({
			method = "ok",
			message = Config.KickPlayerMessage
		})
	end
end)

function startSpectate(targetPlayerId)
    if not isSpectating then
		local localPed = PlayerPedId()
		lastCoords = GetEntityCoords(localPed)
		ESX.TriggerServerCallback("RAGE_SpectateMenu:GetPlayerCoords", function(coords)
			RequestCollisionAtCoord(coords)
			SetEntityVisible(localPed, false)
			SetEntityCoords(localPed, coords + vector3(0, 0, 10))
			FreezeEntityPosition(localPed, true)
			Wait(1500)
			SetEntityCoords(localPed, coords - vector3(0, 0, 10))

			local targetPed = GetPlayerPed(GetPlayerFromServerId(targetPlayerId))
			NetworkSetInSpectatorMode(true, targetPed)
			isSpectating = true
			spectateThred(localPed)
		end, targetPlayerId)
    end
end

function stopSpectate(localPed)
    if isSpectating then
		RequestCollisionAtCoord(lastCoords)
		NetworkSetInSpectatorMode(false, localPed)
		FreezeEntityPosition(localPed, false)
		SetEntityCoords(localPed, lastCoords)
		SetEntityVisible(localPed, true)
		SendNUIMessage({
			action = "StopSpec"
		})
        currentPlayer = nil
        isSpectating = false
		lastCoords = nil
    end
end

function kickPlayer(targetPlayerId)
	TriggerServerEvent("RAGE_SpectateMenu:KickPlayer", targetPlayerId)
end

RegisterNetEvent('RAGE_SpectateMenu:OpenMenu')
AddEventHandler('RAGE_SpectateMenu:OpenMenu', function()
	SendNUIMessage({
		action = "ShowMenu"
	})
	SetNuiFocus(true, true)
end)

function spectateThred(localPed)
	Citizen.CreateThread(function()
		while isSpectating do
			Citizen.Wait(0)
			if IsControlJustReleased(0, Config.StopSpecKey) then
				stopSpectate(localPed)
			end
		end
	end)
end