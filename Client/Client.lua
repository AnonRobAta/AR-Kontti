local Ped, KonttiRyostoKaynnissa, CrowBar, ESX, PlayerData, Blip = nil, false, nil, nil, {}, nil
Citizen.CreateThread(function() while ESX == nil do TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end) Citizen.Wait(0) end while ESX.GetPlayerData().job == nil do Citizen.Wait(10)end PlayerData = ESX.GetPlayerData() end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
end)

function PlayerLoopCheck(EntityCoords)
    if KonttiRyostoKaynnissa then return false, 1200 end
    for Line, Ans in pairs(AR.Kontit) do
        local Math = #(EntityCoords - Ans.Coords)
        if Math < AR.DrawDistance then
            if not GetSelectedPedWeapon(Ped) == CrowBar then return false, 600 end
            return true, 0, Math, Ans.Coords, Ans.Aika, Ans.Cooldown, Ans.CooldownTime
        end
    end
    return false, 1200
end

RegisterNetEvent("AR-Kontti:ClientJobCheckki")
AddEventHandler("AR-Kontti:ClientJobCheckki", function(Koordit, Tilanne)
    PlayerData = ESX.GetPlayerData()
    print( PlayerData.job.name)
    if not PlayerData.job and PlayerData.job.name == 'police' then return end
    if Tilanne == "Poliisi" then
        SendText("Konttiryöstön hälytys laukaistu!")
        RemoveBlip(Blip)
        Blip = AddBlipForCoord(Koordit)
        SetBlipSprite(Blip, 306)
        SetBlipScale(Blip, 0.7)
        SetBlipColour(Blip, 4)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName('K0nttiryöstö : Hälytys laukaistu!')
        EndTextCommandSetBlipName(Blip)
    elseif Tilanne == "Keskeytetty" then
        SendText("Konttiryöstö keskeytetty!")
        RemoveBlip(Blip)
    elseif Tilanne == "Onnistui" then
        SendText("Konttiryöstö onnistui!")
        RemoveBlip(Blip)
    end
end)

Citizen.CreateThread(function()
    TriggerEvent('chat:addSuggestion', '/uusikontti', 'Advanced deveille :D - AR', {
        {name="Kontin-nimi", help="Laita nimi tai älä ihsm"},
        {name="Kontinryöstöaika", help="Sekunteina"},
        {name="KontinCooldown", help="Minuuteina"},
    })

    repeat
        CrowBar = GetHashKey("WEAPON_CROWBAR")
        Citizen.Wait(250)
    until CrowBar ~= nil

    repeat
        Ped = PlayerPedId()
        Citizen.Wait(250)
    until Ped ~= nil

    while true and Ped ~= nil do
        local EntityCoords = GetEntityCoords(Ped)
        local Bool, Time, Lasku, Coords, Aika, CooldownCooldown, CdAika = PlayerLoopCheck(EntityCoords)
        if Bool and not CooldownCooldown then
            DrawMarker(1, Coords, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 0.5, 255, 0, 0, 100, false, true, 2, false, false, false, false)
            if Lasku < 1.5 then
                SendText("Paina [E] aloittaaksesi konttiryöstön.")
                if IsControlJustReleased(0, 46) then
                    Time = 5700 -- "ANTISPAM"
                    ESX.TriggerServerCallback('AR-Konttiryöstö:Poliiseja', function(Polliiseja)
                        if Polliiseja >= AR.MinimiPoliisi then
                            TriggerServerEvent('AR-Kontti:PoliisiNotify', Coords, "Polliisi")
                            AlotappasKontti(Aika, Coords, CdAika)
                        else
                            ESX.ShowNotification('Ei tarpeeksi poliiseja!')
                        end
                    end)
                end
            end
        end
        Citizen.Wait(Time)
    end
end)

function AlotappasKontti(Aika, Coords, CdAika)
    local Anim = AR.Anims
    local ADict = AR.AnimDict
    KonttiRyostoKaynnissa = true
    if not KonttiRyostoKaynnissa then return end
    for k, v in pairs(AR.Kontit) do
        if v.Coords == Coords then
            v.Cooldown = true
        end
    end
    Aika = Aika*1000
    TriggerEvent("mythic_progbar:client:progress", {
        name = "Konttiryöstö",
        duration = Aika,
        label = "Avataan konttia...",
        useWhileDead = false,
        canCancel = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            animDict = ADict,
            anim = Anim,
        },
    }, function(Success)
        ClearPedTasks(Ped)
        if not Success then
            TriggerServerEvent('AR-Konttiryöstö:PalkkioTekijälle', Coords)
        else
            TriggerServerEvent('AR-Kontti:PoliisiNotify', nil, "Keskeytys")
        end
    end)
    KonttiRyostoKaynnissa = false
    CooldownShittii(CdAika, Coords)
end

function CooldownShittii(Aika, Coordinates)
    Citizen.CreateThread(function()
        Aika = Aika*1000*60
        Citizen.Wait(Aika)
        for k, v in pairs(AR.Kontit) do
            if v.Coords == Coordinates then
                v.Cooldown = false
            end
        end
    end)
end

function SendText(Viesti)
    SetTextFont(1)
	SetNotificationTextEntry('STRING')
	AddTextComponentSubstringPlayerName(Viesti)
	DrawNotification(false, true)
end