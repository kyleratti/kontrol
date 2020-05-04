local tPlugin = {}
tPlugin.Name = "Spectate/Unspectate"
tPlugin.Author = "Banana Lord"
tPlugin.Type = PLUGIN_TOOL
tPlugin.Icon = "icon16/eye.png"
tPlugin.API = 1
function tPlugin:CanUse(objPl)
	return false -- not ready
end

function tPlugin:ShouldShow(objPl)
	return false
end

if(SERVER) then
	kontrol:AddLogType("Spectate")

	kontrol:AddCommand("spectate", function(objPl, strCmd, tblArgs)
		if(not IsValid(objPl)) then return end
		if(not tPlugin:CanUse(objPl)) then
			objPl:PrintMessage(HUD_PRINTCONSOLE, "Unknown cmd: "..strCmd)
			return
		end

		if(not tblArgs) then return end

		local objTarget = player.GetByUniqueID(tblArgs[1])
		if(not kontrol:ValidCommand(objPl, objTarget)) then return end

		if(not objPl:Alive()) then
			objPl:Spawn()
		end

		if(objPl:InVehicle()) then
			objPl:ExitVehicle()
		end

		if(GAMEMODE:IsDarkRP()) then
			if(objTarget.Spec) then
				objPl:PrintMessage(HUD_PRINTTALK, objTarget:Nick().." is spectating!")
				return
			elseif(objPl.ASS_Spec) then
				objPl:Spectate(OBS_MODE_NONE)
				objPl:UnSpectate()
				objPl:Spawn()
				objPl:SetColor(255, 255, 255, 255)
				timer.Simple(.1, function()
					if(objPl.ASS_Spec.Pos) then
						objPl:SetPos(objPl.ASS_Spec.Pos)
						if(objPl.ASS_Spec.Angles) then
							objPl:SetEyeAngles(objPl.ASS_Spec.Angles)
						end
					end
					if(objPl.ASS_Spec.Weapons) then
						for k,v in pairs(objPl.ASS_Spec.Weapons) do
							if(not objPl:HasWeapon(v)) then
								objPl:Give(v)
							end
						end
					end
					if(objPl.ASS_Spec.Ammo) then
						for k,v in pairs(objPl.ASS_Spec.Ammo) do
							objPl:GiveAmmo(k, v, false)
						end
					end
					objPl:SelectWeapon(objPl.ASS_Spec.SelectedWeapon or objPl:GetInfo("cl_defaultweapon") or "keys")
					objPl.ASS_Spec = nil
					kontrol:Log(KONTROL_LOG_SPECTATE, "%s stopped spectating", objPl, true, {})
				end)
				return				
			end
		end

		if(GAMEMODE:IsDarkRP()) then
			objPl.ASS_Spec = {}
			objPl.ASS_Spec.Player = objTarget
			objPl.ASS_Spec.Pos = objPl:GetPos()
			objPl.ASS_Spec.Angles = objPl:GetAngles()
			objPl.ASS_Spec.Ammo = {}
			objPl.ASS_Spec.Ammo["smg"] = objPl:GetAmmoCount("smg")
			objPl.ASS_Spec.Ammo["pistol"] = objPl:GetAmmoCount("pistol")
			objPl.ASS_Spec.Ammo["buckshot"] = objPl:GetAmmoCount("buckshot")
			objPl.ASS_Spec.Weapons = {}
			objPl.ASS_Spec.SelectedWeapon = ""
			if(objPl:Alive()) then
				if(IsValid(objPl:GetActiveWeapon())) then
					objPl.ASS_Spec.SelectedWeapon = objPl:GetActiveWeapon():GetClass()
				end
			end

			if(objPl:Alive()) then
				for k,v in pairs(objPl:GetWeapons()) do
					table.insert(objPl.ASS_Spec.Weapons, v:GetClass())
				end
			end

			objPl:StripWeapons()
			objPl:Spectate(OBS_MODE_CHASE)
			objPl:SpectateEntity(objTarget)
			objPl:SetMoveType(MOVETYPE_OBSERVER)
			objPl:SetColor(255, 255, 255, 0)
		elseif(GAMEMODE:IsPERP()) then
			if IsValid(Player:GetVehicle()) then Player:ExitVehicle() end

			objPl:StripMains()
			objPl:StripWeapons()
			objPl.Spectating = {Victim = objTarget, Position = objPl:GetPos(), Angle = objPl:EyeAngles(), Health = objPl:Health(), Armour = objPl:Armor()}
			objPl:Spectate(OBS_MODE_CHASE)
			objPl:SpectateEntity(objTarget)
			objPl:SetMoveType(MOVETYPE_OBSERVER)

			umsg.Start("perp_spectate", objPl)
				umsg.Entity(objTarget)
			umsg.End()

			objPl:SetColor(Color(0, 0, 0, 0))
			objPl:SetNoDraw(true)
			objPl:DrawWorldModel(false)

			objPl.KontrolSpec = true
			objPl:ChatPrint("Press SPACE to exit spectator mode")
		end

		kontrol:Log(KONTROL_LOG_SPECTATE, "%s began spectating "..kontrol:Nick(objTarget), objPl, true, {objTarget})
	end)

	kontrol:AddHook("CanPlayerSuicide", "NoSuicide", function(objPl)
		if(objPl.ASS_Spec) then
			return false
		end
	end)

	kontrol:AddHook("PlayerDisconnected", "Spectate_Disconnect", function(objPl)
		for k,v in pairs(player.GetAll()) do
			if(v:GetObserverTarget() == objPl) then
				v:ConCommand("kontrol_spectate")
			end
		end
	end)
else
	function tPlugin.Menu(iUID)
		RunConsoleCommand("kontrol_spectate", iUID)
	end
end

kontrol:RegisterPlugin(tPlugin)