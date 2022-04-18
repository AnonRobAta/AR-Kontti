ESX = nil TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

function Checkki(source)
    for k, v in pairs(AR.Kontit) do
        local Math = #(GetEntityCoords(GetPlayerPed(source)) - v.Coords)
        if Math > 15.0 then
            return true
        end
    end
    return false
end

RegisterNetEvent("AR-Konttiryöstö:PalkkioTekijälle")
AddEventHandler("AR-Konttiryöstö:PalkkioTekijälle", function()
    local Source = source

    if not Checkki(Source) then DropPlayer(Source, "Ei chekki mennyt putkeen") return end

    local xPlayer = ESX.GetPlayerFromId(Source)
    local Chance, Chance2 = math.random(1, 2), math.random(1, 100)

    local Itemit, Itemit2 = math.random(1, #S_AR.Itemit), math.random(1, #S_AR.Itemit)
    local ItemMaara, ItemMaara2 = math.random(1, 3), math.random(1, 3)

    local Aseet = math.random(1, #S_AR.Aseet)

    xPlayer.addInventoryItem(S_AR.Itemit[Itemit], ItemMaara)

    if Chance == 1 then
        xPlayer.addInventoryItem(S_AR.Itemit[Itemit2], ItemMaara2)
    end

    if Chance2 <= 5 then
        xPlayer.addWeapon(S_AR.Aseet[Aseet], 5)
    end

    TriggerClientEvent("AR-Kontti:ClientJobCheckki", -1, nil, "Onnistui") -- Turhaa serverside checkkiä tehdä
end)

ESX.RegisterServerCallback('AR-Konttiryöstö:Poliiseja',function(source, cb)
    Poliisit = PoliisiCheck()
    cb(Poliisit)
end)

function PoliisiCheck()
    Polliisit = 0
    local xPlayers = ESX.GetPlayers()
    for i=1, #xPlayers, 1 do
        local _source = xPlayers[i]
        local xPlayer = ESX.GetPlayerFromId(_source).job.name
        if xPlayer == 'police' then
            Polliisit = Polliisit + 1
        end
    end
    return Polliisit
end

RegisterNetEvent("AR-Kontti:PoliisiNotify")
AddEventHandler("AR-Kontti:PoliisiNotify", function(Kontti, Tilanne) -- Turhaa serverside checkkiä tehdä
    if Tilanne == "Polliisi" then
        TriggerClientEvent("AR-Kontti:ClientJobCheckki", -1, Kontti, "Poliisi")
    elseif Tilanne == "Keskeytys" then
        TriggerClientEvent("AR-Kontti:ClientJobCheckki", -1, Kontti, "Keskeytetty")
    end
end)

RegisterCommand("uusikontti", function(src, args)
    local Identifiers = GetPlayerIdentifiers(src)
    if WhitelistCheck(S_AR.WhitelistIdentifiers, Identifiers[1]) then
        local Ped = GetPlayerPed(src)
        local GetCord = GetEntityCoords(Ped)
        local path = GetResourcePath(GetCurrentResourceName())
        local Nimi, Aika, CooldownTime = args[1] or "Ei nimeä", args[2] or 20, args[3] or 2
        path = path:gsub('//', '/')..'/Config/Config.lua'
        local file = io.open(path, 'a+')
        local label = '\n\n-- '..Nimi.. '\ntable.insert(AR.Kontit, {Coords = '..GetCord..', Name = "'..Nimi..'", Aika = '..Aika..', Cooldown = false, CooldownTime = '..CooldownTime..'})'
        file:write(label)
        file:close()
    end
end)

function WhitelistCheck(Tab, Value)
    for index, Val in ipairs(Tab) do
        if Val == Value then
            return true
        end
    end
    return false
end