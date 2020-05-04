local tPlugin = {}
tPlugin.Name = "Respawn"
tPlugin.Author = "Banana Lord"
tPlugin.Type = PLUGIN_TOOL
tPlugin.Icon = "icon16/asterisk_orange.png"
tPlugin.API = 1
function tPlugin:CanUse(objPl)
	return objPl:IsMod()
end

if(SERVER) then
	kontrol:AddLogType("Respawn")

	kontrol:AddCommand("respawn", function(objPl, strCmd, tblArgs)
		if(not IsValid(objPl)) then return end
		if(not tPlugin:CanUse(objPl)) then
			objPl:PrintMessage(HUD_PRINTCONSOLE, "Unknown cmd: "..strCmd)
			return
		end

		if(not tblArgs) then return end

		local objTarget = player.GetByUniqueID(tblArgs[1])
		if(not kontrol:ValidCommand(objPl, objTarget, true)) then return end

		objTarget.IgnoreSpawn = true
		objTarget:Spawn()

		kontrol:Log({
			["Type"] = KONTROL_LOG_RESPAWN,
			["Message"] = {
				{["Log"] = kontrol:Nick(objPl), ["Chat"] = kontrol:Nick(objPl, false, true, true)},
				{["Log"] = " respawned "},
				{["Log"] = kontrol:Nick(objTarget), ["Chat"] = kontrol:Nick(objTarget, false, true)},
			},
		})
	end)
else
	function tPlugin.Menu(iUID)
		RunConsoleCommand("kontrol_respawn", iUID)
	end
end

kontrol:RegisterPlugin(tPlugin)