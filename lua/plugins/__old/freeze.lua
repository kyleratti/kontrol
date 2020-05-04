local tPlugin = {}
tPlugin.Name = "Freeze/Melt"
tPlugin.Author = "Banana Lord"
tPlugin.Type = PLUGIN_TOOL
tPlugin.Icon = "icon16/lock.png"
tPlugin.API = 1
--tPlugin.Bulk = true
tPlugin.Frozen = {}
function tPlugin:CanUse(objPl)
	return objPl:IsMod()
end

if(SERVER) then
	kontrol:AddLogType("Freeze")
	
	kontrol:AddCommand("freeze", function(objPl, strCmd, tblArgs)
		if(not IsValid(objPl)) then return end
		if(not tPlugin:CanUse(objPl)) then
			objPl:PrintMessage(HUD_PRINTCONSOLE, "Unknown cmd: "..strCmd)
			return
		end

		if(not tblArgs) then return end

		local objTarget = player.GetByUniqueID(tblArgs[1])
		if(not kontrol:ValidCommand(objPl, objTarget, true)) then return end

		if(not tPlugin.Frozen[objTarget:UniqueID()]) then
			if(not objTarget:Alive()) then
				objTarget:Spawn()
			end
			
			tPlugin.Frozen[objTarget:UniqueID()] = true
			objTarget:Freeze(true)

			kontrol:Log({
				["Type"] = KONTROL_LOG_FREEZE,
				["Message"] = {
					{["Log"] = kontrol:Nick(objPl), ["Chat"] = kontrol:Nick(objPl, false, true, true)},
					{["Log"] = " froze "},
					{["Log"] = kontrol:Nick(objTarget), ["Chat"] = kontrol:Nick(objTarget, false, true)},
				},
			})
		else
			tPlugin.Frozen[objTarget:UniqueID()] = nil
			objTarget:Freeze(false)
			
			kontrol:Log({
				["Type"] = KONTROL_LOG_FREEZE,
				["Message"] = {
					{["Log"] = kontrol:Nick(objPl), ["Chat"] = kontrol:Nick(objPl, false, true, true)},
					{["Log"] = " melted "},
					{["Log"] = kontrol:Nick(objTarget), ["Chat"] = kontrol:Nick(objTarget, false, true)},
				},
			})
		end
	end)

	kontrol:AddHook("PlayerSpawnObject", "Freeze_StopSpawn", function(objPl)
		if(tPlugin.Frozen[objPl:UniqueID()]) then
			return false
		end
	end)

	kontrol:AddHook("PlayerInitialSpawn", "Freeze_SpawnCheck", function(objPl)
		if(tPlugin.Frozen[objPl:UniqueID()]) then
			objPl:PrintMessage(HUD_PRINTTALK, "You can't rejoin to escape being frozen bud )")
			objPl:Freeze(true)
		end
	end)

	kontrol:AddHook("CanPlayerSuicide", "Freeze_StopSuicide", function(objPl)
		if(tPlugin.Frozen[objPl:UniqueID()]) then
			return false
		end
	end)

	kontrol:AddHook("PlayerShouldTakeDamage", "Freeze_StopDamage", function(objPl)
		if(tPlugin.Frozen[objPl:UniqueID()]) then
			return false
		end
	end)

	kontrol:AddHook("PlayerDisconnected", "Freeze_RemovePlayer", function(objPl)
		if(tPlugin.Frozen[objPl:UniqueID()]) then
			tPlugin.Frozen[objPl:UniqueID()] = nil
		end
	end)
else
	function tPlugin.Menu(iUID)
		RunConsoleCommand("kontrol_freeze", iUID)
	end
end

kontrol:RegisterPlugin(tPlugin)