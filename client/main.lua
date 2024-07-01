QBCore = nil
local hasShot = false
local ignoreShooting = false

Citizen.CreateThread(function()
    while QBCore == nil do
        TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)
        Citizen.Wait(200)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        ped = PlayerPedId()
        if IsPedShooting(ped) then
            local currentWeapon = GetSelectedPedWeapon(ped)
            for _,k in pairs(Config.weaponChecklist) do
                if currentWeapon == k then
                    ignoreShooting = true
                    break
                end
            end
            
            if not ignoreShooting then
                TriggerServerEvent('GSR:SetGSR', timer)
                hasShot = true
                ignoreShooting = false
                Citizen.Wait(Config.gsrUpdate)
            end
			ignoreShooting = false
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Wait(2000)
        if Config.waterClean and hasShot then
            ped = PlayerPedId()
            if IsEntityInWater(ped) then
				QBCore.Functions.Progressbar("barut_temizle", "Gunpowder is Cleaned, Stay in the Water..", Config.waterCleanTime, false, true, {
						disableMovement = false,
						disableCarMovement = false,
						disableMouse = false,
						disableCombat = false,
					}, {}, {}, {}, function()
						if IsEntityInWater(ped) then
							hasShot = false
							TriggerServerEvent('GSR:Remove')
							QBCore.Functions.Notify('Wash all Gunshot Residue off you', "success")
						else
							QBCore.Functions.Notify('You left the water too early and did not wash off gunshot residue', "error")
						end
					end, function()
						QBCore.Functions.Notify('you failed!', "error")
				end)
				-- Citizen.Wait(Config.waterCleanTime)
            end
        end
    end
end)

function status()
    if hasShot then
        QBCore.Functions.TriggerCallback('GSR:Status', function(cb)
            if not cb then
                hasShot = false
            end
        end)
    end
end

function updateStatus()
    status()
    SetTimeout(Config.gsrUpdateStatus, updateStatus)
end

updateStatus()
