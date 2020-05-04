local tPlugin = {}
tPlugin.Name = "Revive"
tPlugin.Author = "Banana Lord"
tPlugin.Type = PLUGIN_TOOL
tPlugin.Icon = "icon16/arrow_up.png"
tPlugin.Bulk = true
tPlugin.API = 1
function tPlugin:CanUse(objPl)
	return objPl:IsMod()
end

function tPlugin:ShouldShow(objPl)
	return !objPl:Alive()
end

if(SERVER) then
	kontrol:AddLogType("Respawn")

	kontrol:AddCommand("revive", function(objPl, strCmd, tblArgs)
		if(not IsValid(objPl)) then return end
		if(not tPlugin:CanUse(objPl)) then
			objPl:PrintMessage(HUD_PRINTCONSOLE, "Unknown cmd: "..strCmd)
			return
		end

		if(not tblArgs) then return end

		local objTarget = player.GetByUniqueID(tblArgs[1])
		if(not kontrol:ValidCommand(objPl, objTarget, true, true)) then return end
	
		if(objTarget:Alive()) then return end

		if(GAMEMODE:IsDarkRP()) then
			objTarget:Revive(100)
		elseif(GAMEMODE:IsPERP()) then
			local pos = objTarget:GetPos()
			objTarget.DontFixCripple = true -- if player is mayor then it'll "demote" them without this, and dont fix broken legs :P
			objTarget:Spawn()
			objTarget:SetPos(pos)
	
			if(objTarget.Ammo) then
				for k,v in pairs(objTarget.Ammo) do
					objTarget:GiveAmmo(v, k)
				end

				objTarget.Ammo = nil
			end

			GAMEMODE:Notify(objTarget, "An admin has revived you. A Reminder: This still counts as a death.")
		end

		kontrol:Log({
				["Type"] = KONTROL_LOG_RESPAWN,
				["Message"] = {
					{["Log"] = kontrol:Nick(objPl), ["Chat"] = kontrol:Nick(objPl, false, true, true)},
					{["Log"] = " revived "},
					{["Log"] = kontrol:Nick(objTarget), ["Chat"] = kontrol:Nick(objTarget, false, true)},
				},
			})
	end)
else
	function tPlugin.Menu(iUID)
		RunConsoleCommand("kontrol_revive", iUID)
	end
end

kontrol:RegisterPlugin(tPlugin)