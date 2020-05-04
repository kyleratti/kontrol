class "Kick" extends "Plugin" {
	public {
		__construct = function(self, strName, iType)
			self.Plugin(strName, iType)
		end;

		canPlayerUse = function(self, objPl)
			return objPl:isMod()
		end;

		canTarget = function(self, objPl, objTarget)
			if(objPl == objTarget or (not IsValid(objPl) and IsValid(objTarget))) then
				return true
			end

			return objPl:isMod()
		end;

		-- server

		onServerLoad = function(self)
			kontrol.log.add("KickBan")

			kontrol.commands.add("kick", function(objPl, strCmd, tblArgs)
				if(not self:canRunCommand(objPl, strCmd, tblArgs)) then return end

				local objTarget = player.GetByUniqueID(tblArgs[1])

				if(not objTarget or not IsValid(objTarget)) then
					objPl:sendMessage(true, colorx.red, "Player not found")
					return false
				end

				if(not self:canTarget(objPl, objTarget)) then
					objPl:sendMessage(true, colorx.red, "You aren't permitted to do that to ", kontrol.getNick(objTarget, {["colors"] = true}))
					return false
				end

				table.remove(tblArgs, 1)

				local strReason = "No reason specified"

				if(tblArgs and #tblArgs > 0) then
					strReason = table.concat(tblArgs, " ")
				end

				kontrol.log.add(kontrol.log.get("KickBan"), {
					["message"] = {
						{["log"] = kontrol.getNick(objPl), ["chat"] = kontrol.getNick(objPl, {["colors"] = true, ["simple"] = true})},
						{["log"] = " kicked "},
						{["log"] = kontrol.getNick(objTarget), ["chat"] = kontrol.getNick(objTarget, {["colors"] = true})},
						{["log"] = strReason, ["chat"] = {" (", colorx.lime, strReason, color_white, ")"}},
					}
				})

				objTarget:Kick("Kicked by "..objPl:Nick().." ("..strReason..")")
			end)
		end;

		-- client

		onClientLoad = function(self)
			self:setIcon("door_out")
		end;

		onMenuClick = function(self, objPl)
			local iUniqueID = objPl:UniqueID()

			local pMenu = vgui.Create("KFrame2")
			pMenu:SetSize(300, 87)
			pMenu:SetPos(ScrW() / 2 - 150, ScrH() / 2 - 43)
			pMenu:SetTitle("Kick "..objPl:Nick())
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

				for k,v in pairs(kontrol.banReasons) do
					pSR:AddOption(v, function()
						pReason:SetValue(v)
					end)
				end

				pSR:Open()
			end

			local pAccept = vgui.Create("KButton", pMenu)
			pAccept:SetSize(pMenu:GetWide() - 20, 20)
			pAccept:SetPos(10, pMenu:GetTall() - pAccept:GetTall() - 10)
			pAccept:SetText("Kick "..objPl:Nick())
			function pAccept:DoClick()
				local strReason = pReason:GetValue()

				kontrol:AddBanReason(strReason)
				RunConsoleCommand("kontrol_kick", iUniqueID, strReason)
				pMenu:Close()
			end
		end;
	};
}

kontrol.plugins.add(Kick.new("Kick", kontrol.PLUGIN_PUNISH))