local tPlugin = {}
tPlugin.Name = "Demote"
tPlugin.Author = "Banana Lord"
tPlugin.Type = PLUGIN_PUNISH
tPlugin.Icon = "icon16/cancel.png"
tPlugin.API = 1
function tPlugin:CanUse(objPl)
	return objPl:IsMod()
end

function tPlugin:ShouldShow(objPl)
	return objPl:Team() ~= TEAM_CITIZEN
end

if(SERVER) then
	kontrol:AddLogType("Admin")

	kontrol:AddCommand("demote", function(objPl, strCmd, tblArgs)
		if(not IsValid(objPl)) then return end
		if(not tPlugin:CanUse(objPl)) then
			objPl:PrintMessage(HUD_PRINTCONSOLE, "Unknown cmd: "..strCmd)
			return
		end

		if(not tblArgs) then return end

		local objTarget = player.GetByUniqueID(tblArgs[1])
		if(not kontrol:ValidCommand(objPl, objTarget, true)) then return end

		if(objTarget:Team() == TEAM_CITIZEN) then
			objPl:PrintMessage(HUD_PRINTTALK, objTarget:Nick().." is already a citizen!")
			return
		end

		table.remove(tblArgs, 1)
		local strReason = "No reason specified"
		if(#tblArgs > 0) then
			strReason = table.concat(tblArgs, " ")
		end

		objTarget:TeamBan()
		if(objTarget:Alive()) then
			objTarget:ChangeTeam(TEAM_CITIZEN, true)
			if(RPArrestedPlayers[objTarget:SteamID()]) then
				objTarget:Arrest()
			end
		else
			objTarget.demotedWhileDead = true
		end

		kontrol:Log({
			["Type"] = KONTROL_LOG_ADMIN,
			["Message"] = {
				{["Log"] = kontrol:Nick(objPl), ["Chat"] = kontrol:Nick(objPl, false, true, true)},
				{["Log"] = " demoted "},
				{["Log"] = kontrol:Nick(objTarget), ["Chat"] = kontrol:Nick(objTarget, false, true)},
				{["Log"] = " ("..strReason..")", ["Chat"] = {color_white, " (", colorx["Lime"], strReason, color_white, ")"}},
			},
		})
	end)
else
	function tPlugin.Menu(iUID)
		local objPl = player.GetByUniqueID(iUID)

		if(objPl:Team() == TEAM_CITIZEN) then
			LocalPlayer():PrintMessage(HUD_PRINTTALK, objPl:Nick().." is already a citizen!")
			return
		end

		local pMenu = vgui.Create("KFrame")
		pMenu:SetSize(150, 112 / 1.3)
		pMenu:Center()
		pMenu:SetTitle("Demote "..objPl:Nick())
		pMenu:SetDraggable(true)
		pMenu:ShowCloseButton(true)
		pMenu:SetSizable(false)
		pMenu:SetScreenLock(true)
		pMenu:MakePopup()
		function pMenu:Think()
			if(not self:HasFocus()) then
				self:RequestFocus()
			end
		end

		local pReason = vgui.Create("DTextEntry", pMenu)
		pReason:SetSize(pMenu:GetWide() - 20, 20)
		pReason:SetPos(10, 32)
		pReason:SetValue("")

		local pAccept = vgui.Create("KButton", pMenu)
		pAccept:SetSize(pMenu:GetWide() - 20, 20)
		pAccept:SetPos(10, pMenu:GetTall() - pAccept:GetTall() - 10)
		pAccept:SetText("Demote "..objPl:Nick())
		pAccept:SetDisabled(true)
		function pAccept:DoClick()
			if(not pAccept:GetDisabled()) then
				RunConsoleCommand("kontrol_demote", iUID, pReason:GetValue())
				pMenu:Close()
			end
		end

		function pReason:OnTextChanged()
			local txt = string.Trim(pReason:GetValue())
			if(#txt >= 1) then
				pAccept:SetDisabled(false)
			else
				pAccept:SetDisabled(true)
			end
		end
	end
end

kontrol:RegisterPlugin(tPlugin)