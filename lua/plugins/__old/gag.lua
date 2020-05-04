local tPlugin = {}
tPlugin.Name = "Gag"
tPlugin.Author = "Banana Lord"
tPlugin.Type = PLUGIN_TOOL
tPlugin.Icon = "icon16/sound_mute.png"
tPlugin.API = 1
tPlugin.Bulk = true
tPlugin.Gaged = {}
function tPlugin:CanUse(objPl)
	return objPl:IsMod() or objPl:IsVIP()
end

function tPlugin:GetName(objPl)
	if(self.Gaged[objPl:UniqueID()]) then
		return "Un-gag"
	end

	return "Gag"
end

if(SERVER) then
	kontrol:AddLogType("Gag")
	
	kontrol:AddCommand("gag", function(objPl, strCmd, tblArgs)
		if(not IsValid(objPl)) then return end
		if(not tPlugin:CanUse(objPl)) then
			objPl:PrintMessage(HUD_PRINTCONSOLE, "Unknown cmd: "..strCmd)
			return
		end

		if(not tblArgs) then return end

		local objTarget = player.GetByUniqueID(tblArgs[1])
		if(not kontrol:ValidCommand(objPl, objTarget, true)) then return end

		if(not tPlugin.Gaged[objTarget:UniqueID()]) then
			tPlugin.Gaged[objTarget:UniqueID()] = true
			net.Start("kontrol_Gag")
				net.WriteString(objTarget:UniqueID())
			net.Broadcast()

			kontrol:Log({
				["Type"] = KONTROL_LOG_GAG,
				["Message"] = {
					{["Log"] = kontrol:Nick(objPl), ["Chat"] = kontrol:Nick(objPl, false, true, true)},
					{["Log"] = " gaged "},
					{["Log"] = kontrol:Nick(objTarget), ["Chat"] = kontrol:Nick(objTarget, false, true)},
				},
			})
		else
			tPlugin.Gaged[objTarget:UniqueID()] = nil
			net.Start("kontrol_GagExpire")
				net.WriteString(objTarget:UniqueID())
			net.Broadcast()

			kontrol:Log({
				["Type"] = KONTROL_LOG_GAG,
				["Message"] = {
					{["Log"] = kontrol:Nick(objPl), ["Chat"] = kontrol:Nick(objPl, false, true, true)},
					{["Log"] = " un-gaged "},
					{["Log"] = kontrol:Nick(objTarget), ["Chat"] = kontrol:Nick(objTarget, false, true)},
				},
			})
		end
	end)

	util.AddNetworkString("kontrol_GagExpire")
	util.AddNetworkString("kontrol_Gag")
	util.AddNetworkString("kontrol_GagList")

	kontrol:AddHook("PlayerInitialSpawn", "SendGagedPlayers", function(objPl)
		local tblPlayers = table.Copy(tPlugin.Gaged)
		net.Start("kontrol_GagList")
			net.WriteUInt(table.Count(tblPlayers), 32)
			for k,v in pairs(tblPlayers) do
				net.WriteString(k)
			end
		net.Send(objPl)

		if(timer.Exists("gag_expire_"..objPl:UniqueID())) then
			timer.Destroy("gag_expire_"..objPl:UniqueID())
		end
	end)

	kontrol:AddHook("PlayerDisconnected", "GagExpire", function(objPl)
		local strUniqueID = objPl:UniqueID()

		timer.Create("gag_expire_"..strUniqueID, 60 * 5, 1, function()
			tPlugin.Gaged[strUniqueID] = nil

			net.Start("kontrol_GagExpire")
				net.WriteString(strUniqueID)
			net.Broadcast()
		end)
	end)
else
	function tPlugin.Menu(iUID)
		RunConsoleCommand("kontrol_gag", iUID)
	end

	net.Receive("kontrol_GagList", function(iLen)
		local iNum = net.ReadUInt(32)
		local tblPlayers = {}

		for i=1, iNum do
			local strUniqueID = net.ReadString()
			tblPlayers[strUniqueID] = true

			local objPl = player.GetByUniqueID(strUniqueID)
			if(IsValid(objPl) and objPl:IsPlayer()) then
				objPl:SetMuted(true)
			end
		end
	end)

	net.Receive("kontrol_GagExpire", function(iLen)
		local strUniqueID = net.ReadString()

		tPlugin.Gaged[strUniqueID] = nil

		local objPl = player.GetByUniqueID(strUniqueID)
		if(IsValid(objPl) and objPl:IsPlayer()) then
			objPl:SetMuted(false)
		end
	end)

	net.Receive("kontrol_Gag", function(iLen)
		local strUniqueID = net.ReadString()

		tPlugin.Gaged[strUniqueID] = true

		local objPl = player.GetByUniqueID(strUniqueID)
		if(IsValid(objPl) and objPl:IsPlayer()) then
			objPl:SetMuted(true)
		end
	end)
end

kontrol:RegisterPlugin(tPlugin)