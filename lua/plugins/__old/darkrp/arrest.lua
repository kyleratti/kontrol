local tPlugin = {}
tPlugin.Name = "Arrest/Unarrest"
tPlugin.Author = "Banana Lord"
tPlugin.Type = PLUGIN_PUNISH
tPlugin.Icon = "icon16/lock.png"
tPlugin.API = 1
function tPlugin:CanUse(objPl)
	return objPl:IsMod()
end

if(SERVER) then
	local objLog = kontrol:AddLogType("Arrest")

	kontrol:AddCommand("arrest", function(objPl, strCmd, tblArgs)
		if(not IsValid(objPl)) then return end
		if(not tPlugin:CanUse(objPl)) then
			objPl:PrintMessage(HUD_PRINTCONSOLE, "Unknown cmd: "..strCmd)
			return
		end

		if(not tblArgs) then return end

		local objTarget = player.GetByUniqueID(tblArgs[1])
		if(not kontrol:ValidCommand(objPl, objTarget, true)) then return end

		local bArrest = true

		if(objTarget:IsArrested()) then
			objTarget:Unarrest()
			bArrest = false
		else
			objTarget:Arrest(120, false)
		end

		kontrol:Log({
			["Type"] = objLog,
			["Message"] = {
				{["Log"] = kontrol:Nick(objPl), ["Chat"] = kontrol:Nick(objPl, false, true, true)},
				{["Log"] = " "..(!bArrest and "un-" or "").."arrested "},
				{["Log"] = kontrol:Nick(objTarget), ["Chat"] = kontrol:Nick(objTarget, false, true)},
			},
		})
	end)
else
	function tPlugin.Menu(iUID)
		RunConsoleCommand("kontrol_arrest", iUID)
	end
end

kontrol:RegisterPlugin(tPlugin)