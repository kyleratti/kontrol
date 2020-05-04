local tPlugin = {}
tPlugin.Name = "Rocket"
tPlugin.Author = "Banana Lord"
tPlugin.Type = PLUGIN_PUNISH
tPlugin.Icon = "icon16/bomb.png"
tPlugin.API = 1
function tPlugin:CanUse(objPl)
	return objPl:IsMod()
end

if(SERVER) then
	kontrol:AddLogType("Rocket")

	kontrol:AddCommand("rocket", function(objPl, strCmd, tblArgs)
		if(not IsValid(objPl)) then return end
		if(not tPlugin:CanUse(objPl)) then
			objPl:PrintMessage(HUD_PRINTCONSOLE, "Unknown cmd: "..strCmd)
			return
		end

		if(not tblArgs) then return end

		local objTarget = player.GetByUniqueID(tblArgs[1])
		if(not kontrol:ValidCommand(objPl, objTarget, true)) then return end

		if(not IsValid(objTarget) or !objTarget:Alive()) then return end

		objTarget:SetMoveType(MOVETYPE_WALK)
		objTarget:SetVelocity(Vector(0, 0, 2048))

		timer.Simple(3, function()
			if(not IsValid(objTarget)) then return end
			local pos = objTarget:GetPos()

			local eff = EffectData()
			eff:SetOrigin(pos)
			eff:SetStart(pos)
			eff:SetMagnitude(512)
			eff:SetScale(128)

			util.Effect("Explosion", eff)
			
			timer.Simple(0.1, function()
				if(IsValid(objTarget) and objTarget:Alive()) then
					objTarget:Kill()
				end
			end)
		end)

		kontrol:Log({
			["Type"] = KONTROL_LOG_ROCKET,
			["Message"] = {
				{["Log"] = kontrol:Nick(objPl), ["Chat"] = kontrol:Nick(objPl, false, true, true)},
				{["Log"] = " rocketed "},
				{["Log"] = kontrol:Nick(objTarget), ["Chat"] = kontrol:Nick(objTarget, false, true)},
			},
		})
	end)
else
	function tPlugin.Menu(iUID)
		RunConsoleCommand("kontrol_rocket", iUID)
	end
end

kontrol:RegisterPlugin(tPlugin)