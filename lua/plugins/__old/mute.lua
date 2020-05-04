local tPlugin = {}
tPlugin.Name = "Mute/Unmute"
tPlugin.Author = "Banana Lord"
tPlugin.Type = PLUGIN_TOOL
tPlugin.Icon = "icon16/comment_delete.png"
tPlugin.API = 1
tPlugin.Muted = {}
function tPlugin:CanUse(objPl)
	return objPl:IsMod()
end

if(SERVER) then
	kontrol:AddLogType("Mute")
	
	kontrol:AddCommand("mute", function(objPl, strCmd, tblArgs)
		if(not IsValid(objPl)) then return end
		if(not tPlugin:CanUse(objPl)) then
			objPl:PrintMessage(HUD_PRINTCONSOLE, "Unknown cmd: "..strCmd)
			return
		end

		if(not tblArgs) then return end

		local objTarget = player.GetByUniqueID(tblArgs[1])
		if(not kontrol:ValidCommand(objPl, objTarget, true)) then return end

		if(not tPlugin.Muted[objTarget:UniqueID()]) then
			tPlugin.Muted[objTarget:UniqueID()] = true

			kontrol:Log({
				["Type"] = KONTROL_LOG_MUTE,
				["Message"] = {
					{["Log"] = kontrol:Nick(objPl), ["Chat"] = kontrol:Nick(objPl, false, true, true)},
					{["Log"] = " muted "},
					{["Log"] = kontrol:Nick(objTarget), ["Chat"] = kontrol:Nick(objTarget, false, true)},
				},
			})
		else
			tPlugin.Muted[objTarget:UniqueID()] = nil

			kontrol:Log({
				["Type"] = KONTROL_LOG_MUTE,
				["Message"] = {
					{["Log"] = kontrol:Nick(objPl), ["Chat"] = kontrol:Nick(objPl, false, true, true)},
					{["Log"] = " un-muted "},
					{["Log"] = kontrol:Nick(objTarget), ["Chat"] = kontrol:Nick(objTarget, false, true)},
				},
			})
		end
	end)

	kontrol:AddHook("PlayerSay", -128, function(objPl, sMsg)
		if(tPlugin.Muted[objPl:UniqueID()]) then
			objPl:PrintMessage(HUD_PRINTTALK, "You can't talk while muted!")
			return ""
		end
	end)
else
	function tPlugin.Menu(iUID)
		RunConsoleCommand("kontrol_mute", iUID)
	end
end

kontrol:RegisterPlugin(tPlugin)