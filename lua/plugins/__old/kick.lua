local tPlugin = {}
tPlugin.Name = "Kick"
tPlugin.Author = "Banana Lord"
tPlugin.Type = PLUGIN_PUNISH
tPlugin.Icon = "icon16/door_out.png"
tPlugin.API = 1
function tPlugin:CanUse(objPl)
	return objPl:IsMod()
end

if(SERVER) then
	kontrol:AddLogType("Kick_Ban")
	
	concommand.Add("kontrol_kick", function(objPl, strCmd, tblArgs)
		if(not IsValid(objPl)) then return end
		if(not tPlugin:CanUse(objPl)) then
			objPl:PrintMessage(HUD_PRINTCONSOLE, "Unknown cmd: "..strCmd)
			return
		end

		if(not tblArgs) then return end

		local objTarget = player.GetByUniqueID(tblArgs[1])
		if(not kontrol:ValidCommand(objPl, objTarget, true)) then return end

		local strReason = "No reason specified"
		table.remove(tblArgs, 1)
		if(tblArgs) then
			strReason = table.concat(tblArgs, " ")
		end

		kontrol:Log({
			["Type"] = KONTROL_LOG_KICK_BAN,
			["Message"] = {
				{["Log"] = kontrol:Nick(objPl), ["Chat"] = kontrol:Nick(objPl, false, true, true)},
				{["Log"] = " kicked "},
				{["Log"] = kontrol:Nick(objTarget), ["Chat"] = kontrol:Nick(objTarget, false, true)},
				{["Log"] = strReason, ["Chat"] = {" (", colorx["Lime"], strReason, color_white, ")"}},
			},
		})

		gatekeeper.Drop(objTarget:UserID(), "Kicked by "..objPl:Nick().." ("..strReason..")")
	end)
else
	function tPlugin.Menu(strUniqueID)
		local objTarget = player.GetByUniqueID(strUniqueID)

		local pMenu = vgui.Create("KFrame2")
		pMenu:SetSize(300, 87)
		pMenu:SetPos(ScrW() / 2 - 150, ScrH() / 2 - 43)
		pMenu:SetTitle("Kick "..objTarget:Nick())
		pMenu:SetDraggable(true)
		pMenu:ShowCloseButton(true)
		pMenu:SetSizable(false)
		pMenu:SetScreenLock(true)
		pMenu:MakePopup()
		
		local pReason = vgui.Create("DTextEntry", pMenu)
		pReason:SetSize(250, 20)
		pReason:SetPos(10, 32)
		pReason:SetValue("Consider this a warning...")

		local pReasons = vgui.Create("KButton", pMenu)
		pReasons:SetSize(25, 20)
		pReasons:SetPos(15 + pReason:GetWide(), 32.5)
		pReasons:SetText(">")
		function pReasons:DoClick()
			local pSR = DermaMenu()
			for k,v in pairs(kontrol.ban_reasons) do
				pSR:AddOption(v, function()
					pReason:SetValue(v)
				end)
			end
			pSR:Open()
		end

		local pAccept = vgui.Create("KButton", pMenu)
		pAccept:SetSize(pMenu:GetWide() - 20, 20)
		pAccept:SetPos(10, pMenu:GetTall() - pAccept:GetTall() - 10)
		pAccept:SetText("Kick "..objTarget:Nick())
		function pAccept:DoClick()
			local sReason = pReason:GetValue()
			kontrol:AddBanReason(sReason)
			RunConsoleCommand("kontrol_kick", strUniqueID, sReason)
			pMenu:Close()
		end
	end
end

kontrol:RegisterPlugin(tPlugin)