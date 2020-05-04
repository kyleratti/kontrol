local tPlugin = {}
tPlugin.Name = "Bring"
tPlugin.Author = "Banana Lord"
tPlugin.Type = PLUGIN_TOOL
tPlugin.API = 1
tPlugin.Icon = "icon16/arrow_left.png"
function tPlugin:CanUse(objPl)
	if(GAMEMODE:IsDarkRP()) then
		return objPl:IsMod() or objPl:IsVIP()
	elseif(GAMEMODE:IsPERP()) then
		return objPl:IsMod()
	end
end

function tPlugin:ShouldShow(objPl)
	return objPl ~= LocalPlayer()
end

if(SERVER) then
	kontrol:AddLogType("Teleport")
	
	kontrol:AddCommand("bring", function(objPl, strCmd, tblArgs)
		if(not IsValid(objPl)) then return end
		if(not tPlugin:CanUse(objPl)) then
			objPl:PrintMessage(HUD_PRINTCONSOLE, "Unknown cmd: "..strCmd)
			return
		end

		if(not tblArgs) then return end

		local objTarget = player.GetByUniqueID(tblArgs[1])
		if(not kontrol:ValidCommand(objPl, objTarget, false)) then return end

		if(objTarget:GetColor().a ~= 255) then
			objPl:PrintMessage(HUD_PRINTTALK, "There's no where to put you :(!")
			return
		end

		if(objPl:IsVIP() and !objPl:IsMod()) then
			if(objPl.LastTP and CurTime() - objPl.LastTP < 15) then
				objPl:PrintMessage(HUD_PRINTTALK, "Slow down between teleports!")
				return
			end
		end

		local tr = {}
		tr.start = objPl:GetShootPos()
		tr.endpos = objPl:GetShootPos() + objPl:GetAimVector() * 99999
		tr.filter = objPl
		tr = util.TraceLine(tr)

		objTarget:SetPos(tr.HitPos - objPl:GetAimVector() * 50 + Vector(0, 0, 15))

		if(objPl:IsVIP() and !objPl:IsMod()) then
			objPl.LastTP = CurTime()
		end

		kontrol:Log({
			["Type"] = KONTROL_LOG_TELEPORT,
			["Message"] = {
				{["Log"] = kontrol:Nick(objPl), ["Chat"] = kontrol:Nick(objPl, false, true, true)},
				{["Log"] = " brought "},
				{["Log"] = kontrol:Nick(objTarget), ["Chat"] = kontrol:Nick(objTarget, false, true)},
				{["Log"] = " to themself"},
			},
		})
	end)
else
	function tPlugin.Menu(iUID)
		RunConsoleCommand("kontrol_bring", iUID)
	end
end

kontrol:RegisterPlugin(tPlugin)