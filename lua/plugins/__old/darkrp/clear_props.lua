local tPlugin = {}
tPlugin.Name = "Clear Props"
tPlugin.Author = "Banana Lord"
tPlugin.Type = PLUGIN_TOOL
tPlugin.Icon = "icon16/building_delete.png"
tPlugin.API = 1
tPlugin.Muted = {}
function tPlugin:CanUse(objPl)
	return objPl:IsMod()
end

if(SERVER) then
	kontrol:AddLogType("Admin")

	kontrol:AddCommand("clearprops", function(objPl, strCmd, tblArgs)
		if(not IsValid(objPl)) then return end
		if(not tPlugin:CanUse(objPl)) then
			objPl:PrintMessage(HUD_PRINTCONSOLE, "Unknown cmd: "..strCmd)
			return
		end

		if(not tblArgs) then return end

		local objTarget = player.GetByUniqueID(tblArgs[1])
		if(not kontrol:ValidCommand(objPl, objTarget, true)) then return end

		frank.PP.ClearProps(objTarget:UniqueID())

		kontrol:Log({
			["Type"] = KONTROL_LOG_ADMIN,
			["Message"] = {
				{["Log"] = kontrol:Nick(objPl), ["Chat"] = kontrol:Nick(objPl, false, true, true)},
				{["Log"] = " cleared all props owned by "},
				{["Log"] = kontrol:Nick(objTarget), ["Chat"] = kontrol:Nick(objTarget, false, true)},
			},
		})
	end)
else
	function tPlugin.Menu(iUID)
		RunConsoleCommand("kontrol_clearprops", iUID)
	end
end

kontrol:RegisterPlugin(tPlugin)